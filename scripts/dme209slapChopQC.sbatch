#!/bin/bash

IFS=' ' read -r -a FILEZ <<< ${FILESTRING}
i=${FILEZ[${SLURM_ARRAY_TASK_ID}-1]}

module purge
module load ${R}

echo
echo "==="
echo "Gonna do QC on ${i}";

cat ${i} | gawk -F"	" '{print $2"	"$3"	"$4"	"$5}' | \
  Rscript -e "library(tidyverse); \
    stdin<-read_tsv(file('stdin'),col_names=F)%>%map(table);\
    g<-map(stdin,function(x){list(bins=names(x),\
        counts=as.vector(x))})%>%\
      tibble(tables=.)%>%mutate(variable=names(tables))%>%\
      group_by(variable)%>%\
      mutate(counts=list(tables[[1]][[2]]),\
        bins=list(tables[[1]][[1]]))%>%\
      select(-tables)%>%unnest()%>%ungroup()%>%\
      mutate(logcounts=log10(counts))%>%\
      gather(logornot,counts,counts,logcounts)%>%\
      mutate(bins=as.numeric(as.character(bins)))%>%\
      ggplot()+aes(x=bins,y=counts)+\
      geom_bar(stat='identity',width=0.75)+\
      facet_wrap(~variable+logornot,scales='free',ncol=2)+\
      scale_x_continuous(breaks=seq(-.99,99.99,1))+ylab('');\
      ggsave('"${i}".QC.png',g,width=7,height=7)"

echo "Done SLAPCHOPPING ${i}"
echo "==="
echo

eval ${LOG_TASKRAN}

