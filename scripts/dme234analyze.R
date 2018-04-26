
# MAKE SURE TO SWITCH THIS OVER TO A SUB DIR OF TMP in the MAIN PAPER DIR

library(tidyverse)
library(stringr)

datapath <- "tmp/dme234"
outpath <- "data/dme234"

AllFiles <- tibble(
    FileName=list.files(path=datapath,full.names=T
      ,pattern=".*(correctedStrainObservations)|(uniqueStrainObservations)|(strainObservations)|(counts.txt)|(tabulated)|(wrongStrain)$")) %>%
  mutate(BaseName=sub("reps\\..*","reps",basename(FileName)),
    TailName=sub(".*reps\\.","",basename(FileName))) %>%
  separate(BaseName,sep="_",
    into=c("fd","seed","samples","reads","Mutations","Rep"),
    remove=F)%>%
  select(-fd,-seed,-samples,-reads)%>%
  mutate(Rep=(sub("reps","",Rep)),
    Mutations=as.numeric(sub("mutations","",Mutations)),
    Chopped=ifelse(grepl("chopped_pass",TailName),T,F),
    Demuxed=NA,Tool=NA,Barcode=NA,Parameter=NA,DedupMethod=NA,
    Real=ifelse(grepl("real_",TailName),T,F))%>%
  mutate(Demuxed=ifelse(grepl("demux_[ACTG]+",TailName),
      "picky",Demuxed),
    Demuxed=ifelse(grepl("chopped_pass.fastq.barnone",TailName),
      "barnone",Demuxed),
    Demuxed=ifelse(grepl("fastq.barnoneNoDemux_",TailName),
       "none",Demuxed),
    Demuxed=ifelse(grepl("demux_all",TailName),
       "none",Demuxed) ) %>%
  mutate(Tool=ifelse(grepl("barnone",FileName),"barnone",Tool),
    Tool=ifelse(grepl("bwa",FileName),"bwa",Tool),
    Tool=ifelse(grepl("real",FileName),"real",Tool))%>%
  mutate(Barcode=ifelse(grepl("real_",TailName),
      sub(".*real_([ACTG]+)\\..*","\\1",TailName),Barcode),
    Barcode=ifelse(grepl("demux_[ACTG]+",TailName),
      sub(".*demux_([ACTG]+)\\..*","\\1",TailName),Barcode))%>%
  mutate(
    DedupMethod=ifelse(grepl("correctedStrainObservations",TailName),"saturation",DedupMethod),
    DedupMethod=ifelse(grepl("uniqueStrainObservations",TailName),"unique",DedupMethod),
    Dedup=ifelse(grepl("(corrected)|(unique)|(dedup)",TailName),T,F),
    Parameter=ifelse(grepl("bwa",TailName),
      sub(".*bwa_(\\d+)\\..*","\\1",TailName),Parameter),
    Parameter=ifelse(grepl("barnone",TailName),
      sub(".*barnone((NoDemux)|(PickyDemux))?_(\\d+)\\..*","\\4",TailName),
      Parameter))

print("got files")

SampleSheets <- tibble(FileName=list.files(path=datapath,full.names=T)) %>%
  filter(grepl("SampleSheet",FileName)) %>%
  mutate(BaseName=sub("reps\\..*","reps",basename(FileName)))%>%
  rowwise()%>%
  mutate(RawFile=list(read_csv(FileName))) %>% unnest()%>%
  ungroup() %>%select(BaseName,Sample,SampleBarcodeUsed) %>%
  nest(Sample,SampleBarcodeUsed,.key="Used")%>%ungroup()

print("read in sample sheets")

RealObs <- AllFiles %>% filter(Real) %>% group_by(FileName)%>%
  mutate(Data=map(FileName,function(x){
    z<-trimws(read_lines(x));
    return(tibble(R=z)%>%
      separate(R,c("Counts","Strain"),"\\s"))}))%>%ungroup()

RealTotalObs <- RealObs %>% group_by(BaseName) %>% unnest() %>%
  group_by(BaseName,Strain,Mutations,Rep,
    Chopped,Demuxed,Tool,Parameter,Dedup,Real) %>% 
  summarize(Counts=sum(as.numeric(Counts)))%>%
  ungroup()%>%mutate(Barcode="",FileName="",TailName="")%>%
  group_by(BaseName,FileName,Mutations,Rep,TailName,Barcode,
    Chopped,Demuxed,Tool,Parameter,Dedup,Real) %>% 
  nest(Counts,Strain,.key="Data")%>%
  select(FileName,BaseName,Mutations,Rep,TailName,Chopped,Demuxed,
    Tool,Barcode,Parameter, Dedup, Real,Data)%>%ungroup()

print("read in real obs")

Bwa <- AllFiles %>% 
  filter(Tool=="bwa",!Real,!grepl("wrongStrain",FileName)) %>% 
  group_by(FileName)%>%
  mutate(Data=map(FileName,function(x){
    z<-trimws(read_lines(x));
    return(tibble(R=z)%>%
  separate(R,c("Counts","Strain"),"\\s"))}))%>%ungroup()

print("read in bwa")

BarnoneNoD <- AllFiles %>% filter(!Real&Tool=="barnone"&
    (!is.na(Barcode)|Demuxed=="none"))%>%
  group_by(FileName) %>%
  mutate(Data=map(FileName,function(x){
    z <- read_tsv(x)%>%mutate(Counts=UP)%>%select(Counts,Strain)%>%
      filter(Counts>0)
    return((z))}))%>%ungroup()

print("read in barnone no d")

BarnoneD <- AllFiles %>% 
  filter(!Real&Demuxed=="barnone"&is.na(Barcode)) %>% 
  group_by(FileName) %>%
  right_join(SampleSheets,by="BaseName")%>%
  mutate(RawFile=map2(FileName,Used,function(x,y){
    z <- read_tsv(x)%>%gather(Sample,Counts,-Strain)%>%
      filter(Counts>0)%>%separate(Sample,c("Sample","Tag"))%>%
      filter(Tag=="UP")%>%select(-Tag)%>%
      nest(Counts,Strain,.key="Data")%>%
      right_join(y,by="Sample")
    return((z))}))%>%
  select(-Used)%>%unnest() %>%
  mutate(Barcode=SampleBarcodeUsed)%>%
  select(-SampleBarcodeUsed,-Sample)%>%ungroup()

print("read in barnone d")

BigData <- bind_rows(RealObs,RealTotalObs,Bwa,BarnoneD,BarnoneNoD)

print("bigdata")

# Not demultiplexed comparison
ndc <- BigData %>% 
  filter(Barcode==""|is.na(Barcode)) %>%
  select(BaseName,Mutations,Rep,Tool,Parameter,
    Dedup,DedupMethod,Real,Data)
ndcd <- right_join(
  ndc%>%filter(Real,Dedup)%>%select(-Tool,-Parameter,-Real,-Dedup,-DedupMethod),
  ndc%>%filter(!Real)%>%select(-Real),
  by=c("BaseName","Rep","Mutations"))
NoDemuxComparison<- ndcd %>% 
  group_by(Mutations,Rep,Dedup,Parameter,Tool) %>%
  mutate(CombinedData=map2(Data.x,Data.y,function(x,y) {
      z<-full_join(x,y,by="Strain")%>% mutate(
          Counts.x=ifelse(is.na(Counts.x),0,as.numeric(Counts.x)),
          Counts.y=ifelse(is.na(Counts.y),0,as.numeric(Counts.y)))
      return(z)
      }))%>%select(-Data.x,-Data.y)%>%
  mutate(PearsonCor=map(CombinedData,function(z) {
    return(cor(z$Counts.x,z$Counts.y,use="complete.obs",method="pearson"))
    }))%>%
  mutate(SpearmanCor=map(CombinedData,function(z) {
    return(cor(z$Counts.x,z$Counts.y,use="complete.obs",method="spearman"))
    }))%>%
  mutate(MSE=map(CombinedData,function(z) {
    return(mean( (z$Counts.x-z$Counts.y)^2 ,na.rm=T))
    }))%>%select(-CombinedData)%>%ungroup()%>%unnest()

print("no demux comparison build")

# demuxed comparison
dc <- BigData %>% filter(Barcode!=""&!is.na(Barcode)) %>% 
  select(BaseName,Mutations,Rep,Tool,Parameter,Barcode,
    Dedup,DedupMethod,Real,Data,Demuxed)
dcd <- right_join(
  dc%>%filter(Real,Dedup)%>%select(-Tool,-Parameter,-Real,-Dedup,-DedupMethod,-Demuxed),
  dc%>%filter(!Real)%>%select(-Real),
  by=c("BaseName","Rep","Mutations","Barcode"))
DemuxComparison<- dcd %>% 
  group_by(Mutations,Rep,Dedup,DedupMethod,Parameter,Tool,Barcode,Demuxed) %>%
  mutate(CombinedData=map2(Data.x,Data.y,function(x,y) {
      z<-full_join(x,y,by="Strain")%>% mutate(
          Counts.x=ifelse(is.na(Counts.x),0,as.numeric(Counts.x)),
          Counts.y=ifelse(is.na(Counts.y),0,as.numeric(Counts.y)))
      return(z)
      }))%>%select(-Data.x,-Data.y)%>%
  mutate(PearsonCor=map(CombinedData,function(z) {
    return(cor(z$Counts.x,z$Counts.y,use="complete.obs",method="pearson"))
    }))%>%
  mutate(SpearmanCor=map(CombinedData,function(z) {
    return(cor(z$Counts.x,z$Counts.y,use="complete.obs",method="spearman"))
    }))%>%
  mutate(MSE=map(CombinedData,function(z) {
    return(mean( (z$Counts.x-z$Counts.y)^2 ,na.rm=T))
    }))%>%select(-CombinedData)%>%ungroup()%>%unnest()

print("demux comparison build")

#do precision bit

WrongStrains <- AllFiles%>%filter(grepl("wrongStrain",FileName))%>%
    group_by(FileName)%>%
    mutate(
      Incorrect=as.numeric(sub("\\s.*","",trimws(system(
        str_c("wc -l ",FileName),intern=T)))),
      OutOf=    as.numeric(sub("\\s.*","",trimws(system(
        str_c("wc -l ",sub("\\.dedup","",sub("\\.wrongStrain","",FileName))),
          intern=T))))
      )

print("precision build")

save(list=c("DemuxComparison","NoDemuxComparison","WrongStrains")
  ,file=str_c(outpath,"/dme234plottingObject.RData"))
