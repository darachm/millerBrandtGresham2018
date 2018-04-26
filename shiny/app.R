
library(shiny)
library(tidyverse)
library(stringr)
library(ggrepel)

load("appdata/NameIDList.RData")
load("appdata/dme211datarForModeling_modelNorm.RData")
load("appdata/dme211fitModels_modelNorm.RData")
load("appdata/dme211datarForModeling_directNorm.RData")
load("appdata/dme211fitModels_directNorm.RData")

datar <- list()
datar[["modeled"]] <- datarForModeling
datar[["direct"]] <- datarForModelingDirect
models <- list()
models[["modeled"]] <- modelzAltNorm
models[["direct"]] <- modelz

getNamesDme211 <- function(
    gene_string="YKR039W MEP2 TPS1 TPS2 HTA1 GUA1 IMD2 IMD3 IMD4"
    ,dataModels=list(datar,models)
    ,whichOne="modeled"
    ) {
  thisDatar <- dataModels[[1]][[whichOne]]
  thisModels <- dataModels[[2]][[whichOne]]
  gene_list <- str_split(gene_string,"\\s+")[[1]]
  gene_list <- gene_list[grepl("\\S",gene_list)]
  systematic_list <- sapply(gene_list,function(x){
    x <- str_to_upper(x)
    ifelse(x%in%names(renameCommonToSystematic)
      ,renameCommonToSystematic[x]
      ,x)
     })
  error_list <- systematic_list[!(systematic_list%in%thisDatar$Systematic)]
  systematic_list <- setdiff(systematic_list,error_list)
  return(list(error_list,systematic_list))
}
#getNamesDme211("pyk1 gap1")

multiPlotter <- function(
    gene_string="YKR039W MEP2 TPS1 TPS2 HTA1 GUA1 IMD2 IMD3 IMD4"
    ,dataModels=list(datar,models)
    ,whichOne="modeled"
    ) {
  thisDatar <- dataModels[[1]][[whichOne]]
  thisModels <- dataModels[[2]][[whichOne]]
  gene_list <- getNamesDme211(gene_string)
  systematic_list <- gene_list[[2]]
  if (length(systematic_list)==0) return(NULL)
  plotDatar <- subset(thisDatar,Systematic%in%systematic_list) %>% 
    as_tibble %>%
    group_by(Systematic,Common)%>%
    select_(switch(whichOne,direct="NormedDirect",modeled="NormedModel")
        ,"Minutes","Treated","Treatment","Systematic","Common")%>%
    rename_(MeasuredSignal=switch(whichOne
        ,direct="NormedDirect",modeled="NormedModel"))%>%
    nest%>%
    mutate(ThisModel=thisModels[Systematic])%>%
    mutate(FittedValues=map(ThisModel,function(x){
        as_tibble(data.frame(x$model,ModeledSignal=exp(fitted.values(x))))
      }))%>%
    mutate(Parameters=map(ThisModel,function(x){
        as_tibble(summary(x)$coefficients)%>%
          mutate(Variables=c("Intercept","BasalRate","ChangeRate"))
      }))%>%
    mutate(Common=factor(renameSystematicToCommon[Systematic]))%>%
    mutate(Name=factor(Systematic,levels=systematic_list))%>%
    arrange(suppressWarnings(as.numeric(Name))) %>%
    mutate(Common=factor(Common,levels=unique(Common)))%>%
#    mutate(FacetText=expression(paste(italic(Common),", ",Systematic)))%>%
    mutate(ParameterBoxX=8,ParameterBoxY=unlist(map(Parameters,function(x){
      x[1,1]-1})))%>%
    mutate(ParameterBoxText=unlist(map(Parameters,function(x){
        paste("Slope\nPre-upshift = ",signif(x[2,1],3)
          ,"\nPost-upshift = ",signif((x[2,1]+x[3,1]),3)
          ,"\n Fold-change = ",signif((x[2,1]+x[3,1])/x[2,1],3))})))
  g<-ggplot()+
    theme_bw()+
    geom_label(data=plotDatar%>%
        select(Systematic,Common,ParameterBoxX
          ,ParameterBoxY,ParameterBoxText)
      ,aes(x=ParameterBoxX,y=ParameterBoxY,label=ParameterBoxText)
      ,size=3)+
    geom_line(data=plotDatar%>%select(Systematic,Common,FittedValues)%>%unnest
      ,aes(x=Minutes+12.5,y=log(ModeledSignal),linetype=Treated))+
    geom_point(data=plotDatar%>%select(Systematic,Common,data)%>%
        unnest%>%filter(MeasuredSignal!=0)
      ,aes(x=Minutes,y=log(MeasuredSignal),col=Treatment))+
    facet_wrap(~Common,ncol=3)+
    ylab("log( normalized abundance )")+
    xlab("Minutes after uracil chase")+
    geom_vline(xintercept=12.5,linetype="dotted")+
#    annotate(geom="text",label="glutamine addition",x=12,y=0,angle=90,size=2,col="gray30")+
    scale_color_discrete("",labels=c(w="Mock (water)",q="Glutamine"))+
    scale_linetype_discrete("",labels=c(`FALSE`="Pre-upshift"
      ,`TRUE`="Post-upshift"))+
    theme(legend.position="top",strip.text=element_text(face="italic"))
  return(g)
}
multiPlotter("YKR039W MEP2 GUA1 HTA1")

#####

load("appdata/NameIDList.RData")
load("appdata/dme209modelingDat.RData") 
load("appdata/dme209_modelsToConsider.RData")
load("appdata/dme209_filteredFits.RData")

commonGAP1breaks <- c(.75,1.5,3,6,12,24,48)*1e3
dme209pdat_spread <- modelingdat %>% 
  filter(Metric=="EstInput",FACSGate!="input") %>%
  dplyr::select(-Metric,-Signal,-PropSignal) %>%
  unite(Key,BiologicalReplicate,Shifted,MeanSignalInBin,FACSGate
    ,PCRreplicate,UpperBound,LowerBound) %>%
  spread(Key,PsuedoEvents,fill=0) %>%
  gather(Key,PsuedoEvents,-Strain,-Common) %>% 
  separate(Key,into=c("BiologicalReplicate","Shifted"
    ,"MeanSignalInBin","FACSGate","PCRreplicate"
    ,"UpperBound","LowerBound"),"_") %>% 
  dplyr::select(-PCRreplicate) 
dme209pdat <- dme209pdat_spread %>%
  group_by(Strain,Common,Shifted,BiologicalReplicate,FACSGate)%>%
#  nest(LowerBound,UpperBound,.key="gatez")%>%
  mutate(MeanPsuedoEvents=mean(PsuedoEvents,na.rm=T))%>%
  group_by(Strain,Common,Shifted,BiologicalReplicate)%>%
  mutate(NormMeanPsuedoEvents=MeanPsuedoEvents/sum(unique(MeanPsuedoEvents),na.rm=T))%>%
  ungroup()%>%
  mutate(Name=str_c(tolower(Common),"Δ")
    ,MeanSignalInBin=as.numeric(MeanSignalInBin))%>%
  distinct%>%arrange(Shifted)

getNamesDme209 <- function(
    gene_string="HIs3 gAP1 Dal80"
    ,dataModels=list(datar,models)
    ,whichOne="modeled"
   ) {
  thisDatar <- dme209pdat
  gene_list <- str_split(gene_string,"\\s+")[[1]]
  gene_list <- gene_list[grepl("\\S",gene_list)]
  systematic_list <- sapply(gene_list,function(x){
    x <- str_to_upper(x)
    ifelse(x%in%names(renameCommonToSystematic)
      ,renameCommonToSystematic[x]
      ,x)
     })
  error_list <- systematic_list[!(systematic_list%in%thisDatar$Strain)]
  systematic_list <- setdiff(systematic_list,error_list)
  return(list(error_list,systematic_list))
}
#getNamesDme209("pyk1 gap1 his3 YKR039W ykr034w")

fig4techRepsplotter <- function(toPlot="err",smoother=T) {
  gene_list <- getNamesDme209(toPlot)
  systematic_list <- gene_list[[2]]
  if (length(systematic_list)==0) return(NULL)
  z<-dme209pdat %>% 
    filter(Strain%in%systematic_list) %>%
    mutate(LabelName=str_c(Name,", ",Shifted)) 
  gatez <- z %>% dplyr::select(FACSGate,LabelName,UpperBound,LowerBound) %>%
    mutate(UpperBound=as.numeric(UpperBound)
      ,LowerBound=as.numeric(LowerBound))
  g<-z%>%
    ggplot()+theme_classic()+
    facet_wrap(~LabelName,dir="v",nrow=2,scales="free_y")+
    aes(x=MeanSignalInBin,y=PsuedoEvents,col=BiologicalReplicate)+
    scale_x_log10(breaks=commonGAP1breaks)+
    coord_cartesian(xlim=c(1000,19.2e3))+
    geom_vline(data=gatez,col="gray",aes(xintercept=UpperBound))+
    geom_vline(data=gatez,col="gray",aes(xintercept=LowerBound))+
    xlab("GAP1 FISH signal (a.u.)")+
    scale_y_continuous(limits=c(0,NA))+
    ylab("Mutant strain abundance in bin\n( normalized mean psuedoevents)")+
    geom_hline(yintercept=0)+theme(axis.line.x=element_blank())+
#    scale_color_manual(values=c#bPalette)+
    guides(col=F)#+ ggtitle("All independent technical replicates of the \nmutant abundance estimate")
  if (smoother) {
    return(g +
      stat_smooth(aes(group=Name),span=10,se=F,linetype="dashed",col="grey60")+
      geom_point()
      )
  } else {
    return(g + geom_point() )
  }
}
#fig4techRepsplotter("HIS3 GAP1 DAL80")
#fig4techRepsplotter()

boundslist <- modelingdat %>% 
  dplyr::select(Shifted,FACSGate,LowerBound,UpperBound) %>%
  distinct%>%filter(FACSGate!="input")%>%
  mutate(GateIndex=c(p2=1,p3=2,p4=3,p5=4
    ,p6=1,p7=2,p8=3,p9=4)[as.character(FACSGate)]
    ) %>% 
  group_by(Shifted,GateIndex)%>%
  summarize(BoundsVector=list(
      c(LowerBound=LowerBound,UpperBound=UpperBound)
      )
    ) %>%
  group_by(Shifted) %>%
  arrange(GateIndex)%>%
  summarize(GateList=list(BoundsVector)) %>%
  ungroup()%>%
  summarize(ShiftList=list(setNames(GateList,nm=Shifted))) %>%
  pull(ShiftList) %>% unlist(recursive=F)

pintervalNormal <- function(gate,bounds,fitparm1,fitparm2) {
  return(
    pnorm(log(bounds[["UpperBound"]])
      ,mean=fitparm1,sd=fitparm2
      ) 
    -
    pnorm(log(bounds[["LowerBound"]])
      ,mean=fitparm1,sd=fitparm2
      ) 
    )
}

fig4modelFitsplotter <- function(toPlot="err") {
  gene_list <- getNamesDme209(toPlot)
  systematic_list <- gene_list[[2]]
  if (length(systematic_list)==0) return(NULL)
  z<-dme209pdat %>% 
    dplyr::select(-PsuedoEvents)%>%distinct%>%
    filter(Strain%in%systematic_list) %>%
    group_by(Strain,Common,Shifted,FACSGate,Name)%>%
    mutate(MeanMeanPsuedoEvents=mean(MeanPsuedoEvents)
      ,MeanMeanSignalInBin=mean(MeanSignalInBin))%>%
    group_by(Strain,Common,Shifted,Name)%>%
    mutate(NormMeanMeanPsuedoEvents=MeanMeanPsuedoEvents/sum(unique(MeanMeanPsuedoEvents)))%>%
    left_join(filteredFits%>%select(Strain,LabelName)%>%distinct,by="Strain")%>%
    arrange(desc(Shifted))%>%
    mutate(LabelName=str_c(Name,", ",Shifted)) %>%
#    mutate(LabelName=str_c(Name,", ",ifelse(Shifted=="Shifted","post-shift","pre-shift"))) %>%
#    mutate(LabelName=factor(LabelName))%>%
    left_join(
      modelsToConsider%>%
        filter(BiologicalReplicate=="Pooled")%>%
        dplyr::select(Strain,Shifted,LogMiddle,LogSpread)
      ,by=c("Strain","Shifted")
      )%>%
    group_by(Strain,Shifted,FACSGate)%>%
    mutate(
      GateIndex=recode(FACSGate,p2=1,p3=2,p4=3,p5=4,p6=1,p7=2,p8=3,p9=4)
      ,sketch=list(data.frame(
          x=log(mean(MeanSignalInBin))
          ,y=pintervalNormal(NULL
            ,boundslist[Shifted][[1]][GateIndex][[1]]
            ,LogMiddle,LogSpread)
          )
        )
      )%>%
    mutate(LabelName=str_replace(LabelName,"Shifted","Post-upshift"))%>%
    mutate(LabelName=str_replace(LabelName,"PreShift","Pre-upshift"))
  gatez <- z %>% dplyr::select(FACSGate,LabelName,UpperBound,LowerBound) %>%
    mutate(UpperBound=as.numeric(UpperBound)
      ,LowerBound=as.numeric(LowerBound))
  g<-z%>%
    ggplot()+theme_classic()+
    facet_wrap(~LabelName,dir="v",nrow=2,scales="free_y")+
    aes(x=MeanSignalInBin,y=NormMeanPsuedoEvents,col=BiologicalReplicate)+
    scale_x_log10(breaks=commonGAP1breaks)+
    coord_cartesian(xlim=c(1000,19.2e3))+
    geom_vline(data=gatez,col="gray",aes(xintercept=UpperBound))+
    geom_vline(data=gatez,col="gray",aes(xintercept=LowerBound))+
    xlab("GAP1 FISH signal (a.u.)")+
    scale_y_continuous(limits=c(0,NA))+
    ylab("Mutant strain abundance in gate\n( normalized mean pseudoevents)")+
    geom_hline(yintercept=0)+
    theme(axis.line.x=element_blank()
      ,axis.text.x=element_text(angle=90))+
    guides(col=F)+
    geom_point(data=z%>%unnest,aes(x=exp(x),y=y),col="black",shape=16,size=2.5)+
    geom_line(data=z%>%unnest,aes(x=exp(x),y=y),col="black",linetype="dashed")+
    geom_point() #+ ggtitle("Averaged pseudoevents estimate, within biological replicates, \nfit model in black")
  return(g)
}
#fig4modelFitsplotter("HIS3 GAP1 DAL80 GAT1")

filteredFits <- filteredFits %>% 
  mutate(LabelName=str_c(tolower(Common),"Δ"))

gbaser <- filteredFits %>% 
  mutate(Shifted=relevel(factor(Shifted),"Shifted"))%>%
#  mutate(Shifted=relevel(factor(Shifted),"PreShift"))%>%
  ggplot()+theme_classic()+
  aes(x=Shifted,y=exp(LogMiddle))+
  scale_y_log10(breaks=commonGAP1breaks)+
  ylab("Mean GAP1 signal (a.u.)")+
  geom_violin(adjust=0.2)+
  xlab(NULL)+
#  scale_x_discrete(labels=c(PreShift="Pre-upshift",
#      Shifted="Post-upshift")
  scale_x_discrete(labels=c(PreShift="Pre-upshift"
        ,Shifted="Post-upshift")
    )+
  theme(legend.position="bottom")+coord_flip()
gbaser

violinPlotter <- function(genes="err") {
  gene_list <- getNamesDme209(genes)
  systematic_list <- gene_list[[2]]
  if (length(systematic_list)==0) return(NULL)
  thispdat <- filteredFits %>% filter(Strain%in%systematic_list)
  outputViolin <- gbaser+
    scale_color_discrete("")+
    geom_point(data=thispdat%>%dplyr::select(Shifted,LogMiddle,LabelName)%>%distinct
      ,aes(col=LabelName))+
    geom_line(data=thispdat%>%dplyr::select(Shifted,Strain,LogMiddle,LabelName)%>%distinct
      ,aes(col=LabelName,group=Strain))+
    geom_text_repel(data=thispdat%>%filter(Shifted=="PreShift")%>%
        dplyr::select(Shifted,LogMiddle,LabelName)%>%distinct
      ,aes(label=LabelName),nudge_x=0.3,nudge_y=0.0,segment.color="grey50") #+ ggtitle("Violin plot of all means from fit distributions, \nwith line connecting means between two timepoints")
  return(outputViolin)
}
#violinPlotter("gap1 his3 ykr034w")

#####

ui <- fluidPage(titlePanel("\"Systematic identification of factors mediating accelerated mRNA
degradation in response to changes in environmental nitrogen.\"")
  ,fluidRow(column(1,""),column(6,p("This webpage provides 
    visualizations of data reported in the paper Miller, Brandt, 
    and Gresham 2018.")))
  ,hr()
  ,tabsetPanel(tabPanel("mRNA stability measurements"
      ,sidebarLayout(sidebarPanel(helpText("
A 4-thiouracil label-chase and RNAseq was used to assess stability 
of each transcript upon a nitrogen upshift. A culture was labeled
in nitrogen limiting conditions, then label was chased with the 
addition of 40-fold excess uracil. This was interrupted at 12.5
minutes by the addition of glutamine, and compared to the same
experiment but with the addition of water. Accelerated degradation
is apparent as an increase in the rate of degradation 
(steeper slope) upon addition of glutamine.
")
          ,hr()
          ,textInput(inputId="gene_ids_dme211"
            ,label=h3("Enter gene names (systematic or common),
for example: YKR039W hta1 hAc1 Tps2 GUA1 IMD2 IMD3 IMD4")
            ,placeholder="Enter gene names here"
            )
          ,radioButtons(inputId="normalization_dme211"
            ,label=h3("Normalization procedure (modeled recommended, see Appendix 1 pg. 8 for detailed explanation of the options)")
            ,choices = list("Modeled based"=1
              ,"Within sample"=2)
            ,selected = 1)
          ,width=3
          )
        ,mainPanel(fluidRow(textOutput("genez_report_dme211"))
          ,fluidRow(p("The y-axis is the natural log of labeled RNA 
            abundance normalized to spike-ins, and the x-axis is 
            minutes after uracil chase began. 
            The vertical dotted line indicates the addition of
            glutamine or water (mock).
            Degradation rates are modeled
            by the solid black line and the dashed line.
            A change in slope after the addition of glutamine 
            indicates a change in mRNA stability."))
          ,fluidRow(plotOutput("mainPlot_dme211",inline=TRUE))
#          ,fluidRow(plotOutput("mainPlot_dme211"))
          )
    
        )
      )
    ,tabPanel("BFF analysis of factors controlling GAP1 mRNA dynamics"
      ,sidebarLayout(sidebarPanel(helpText("
We estimated
the abundance of GAP1 mRNA in each mutant in the pool at two 
timepoints (induced by nitrogen-limitation and 10 minutes after 
triggering repression with the addition of glutamine).")
        ,hr()
        ,textInput(inputId="gene_ids_dme209"
          ,label=h3("Gene deletion strains to plot (systematic or common name), for example: YKR039W his3 DAL80")
          ,placeholder="Enter gene-deletions here"
          )
        ,width=3
        )
        ,mainPanel(fluidRow(textOutput("genez_report_dme209"))
          ,fluidRow(p("Note that the x-axis is the same for all
            these plots."))
          ,fluidRow(p("The
            violin plot in black lines depicts the distribution of
            GAP1 expression for all mutants. 
            Points are the estimate for each strain in the 
            pre-upshift and post-upshift conditions connected
            by a line for visualization purposes.
            "))
          ,fluidRow(plotOutput("violin_dme209"))
          ,fluidRow(p("
            Distribution of mutant abundances across the four gates
            of GAP1 abundance, pre-upshift and post-upshift.
            Black points connected by dashed lines are the
            fit of the log-normal model.
            "))
          ,fluidRow(plotOutput("modelFits_dme209"))
#          ,fluidRow(p("
#            To make these pseudo-events estimates, first the
#            proportion of the mutant in each sample had to be
#            estimated and averaged. Here are a similar metric without
#            averaging between technical (PCR) replcates of the
#            library preparation. A dashed line is loess smoothed 
#            through the data.
#            "))
#          ,fluidRow(plotOutput("technicalReps_dme209"))
          )
        )
      )
    )
  )

calcPlotWidth  <- function(n) { min(length(n)*350,1051) }
calcPlotHeight <- function(n) { ceiling(length(n)/3)*350 }

server <- function(input, output) {
  plotWidth <- reactive({  calcPlotWidth(getNamesDme211(input$gene_ids_dme211)[[2]]) })
  plotHeight<- reactive({ calcPlotHeight(getNamesDme211(input$gene_ids_dme211)[[2]]) })
  output$mainPlot_dme211 <- renderPlot({
    multiPlotter(input$gene_ids_dme211
      ,dataModels=list(datar,models)
      ,whichOne=switch(input$normalization_dme211
        ,`1`="modeled",`2`="direct")
      )
    }
    ,width=plotWidth
    ,height=plotHeight
    )
  output$genez_report_dme211 <- renderText({
    name_list <- getNamesDme211(input$gene_ids_dme211)
    returnString <- ""
    if (length(name_list[[1]])) { 
      returnString <- str_c(returnString,"This application couldn't recognize or find data for "
        ,str_c(name_list[[1]],collapse=", "),".\n")
    } 
    if (length(name_list[[2]])) { 
      returnString <- str_c(returnString,"This application could recognize "
        ,str_c(name_list[[2]],collapse=", "),", plotting below:")
    } 
    returnString <- str_c(returnString)
    return(returnString)
    })
  output$genez_report_dme209 <- renderText({
    name_list <- getNamesDme209(input$gene_ids_dme209)
    returnString <- ""
    if (length(name_list[[1]])) { 
      returnString <- str_c(returnString,"This application could't recognize or find data for "
        ,str_c(name_list[[1]],collapse=", "),".\n")
    } 
    if (length(name_list[[2]])) { 
      returnString <- str_c(returnString,"This application could recognize "
        ,str_c(name_list[[2]],collapse=", "),", plotting below:")
    } 
    return(returnString)
    })
  output$violin_dme209 <- renderPlot({
    violinPlotter(input$gene_ids_dme209)
    })
  output$modelFits_dme209 <- renderPlot({
    fig4modelFitsplotter(input$gene_ids_dme209)
    })
  output$technicalReps_dme209 <- renderPlot({
    fig4techRepsplotter(input$gene_ids_dme209,smoother=T)
    })
}

shinyApp(ui = ui, server = server)

