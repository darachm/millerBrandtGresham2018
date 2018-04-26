# This is the Makefile. This is supposed to allow you to use the GNU
# `make` program to more easily repeat analyses associated with this
# paper, and regenerate papers and figures.
#
# This does not handle HPC jobs, so it just uses the files downstream
# of those analyses.
#
# ATTENTION
#
# You probably want to download the zip files for data, html_reports,
# and tmp, then type:
#
# "make unzip"
#
# and then
#
# "make all"
#
# If you really want to unzip all the fastq and microscopy data,
# then obtain those zips and do:
#
# "make unzip_all"

#
#
# Preliminaries
#
#

.SECONDARY: data/% tmp/% html_reports/% output/%

# This makes lists for handling different names and things, and is 
# saved as a RData so I can load it and go.
tmp/NameIDList.RData \
  html_reports/makingLists.html \
  : scripts/makingLists.Rmd \
  data/SGD_features_170601.tab
	mkdir -p tmp output html_reports plos_submission
	Rscript --vanilla -e "rmarkdown::render('$<',output_file='../html_reports/$(basename $(notdir $<)).html')"

#
#
#
# FIGURE 1
#
#
#

#files_Figure1 =

# Incorporating the data from the MBoC paper, Airoldi et al 2016
tmp/airoldiEtAl2016MBoCTableS7.RData \
  tmp/airoldiEtAl2016MBoCTableS7Melty.RData \
  html_reports/readingInAiroldiEtAl2016Microarrays.html \
  : \
  scripts/readingInAiroldiEtAl2016Microarrays.Rmd \
  data/airoldiEtAl2016MBoC/TableS7.csv
	mkdir -p tmp output html_reports plos_submission
	Rscript --vanilla -e "rmarkdown::render('$<',output_file='../html_reports/$(basename $(notdir $<)).html')"

# Doing PCA on those microarrays to look at the broad patterns of reprogramming
tmp/airoldiPCAanalysis.RData \
  output/Figure1_Table_GSEofGOtermsAgainstPCcorrelation.csv \
  output/Figure1_Table_PCAresults.csv \
  output/Figure1_S_higherComponents.un.tiff \
  html_reports/microarrayPCA.html \
  : \
  scripts/microarrayPCA.Rmd tmp/airoldiEtAl2016MBoCTableS7.RData \
  data/sgd_go_slim_171013.txt data/sgd_go_terms_171013.txt \
  tmp/NameIDList.RData
	mkdir -p tmp output html_reports plos_submission
	Rscript --vanilla -e "rmarkdown::render('$<',output_file='../html_reports/$(basename $(notdir $<)).html')"

# The coulter counter upshift, lag in upshift in population growth
tmp/coulterCounterData.RData \
  html_reports/coulterCounterUpshift.html \
  :\
  scripts/coulterCounterUpshift.Rmd data/dme152coulterCounterUpshift
	mkdir -p tmp output html_reports plos_submission
	Rscript --vanilla -e "rmarkdown::render('$<',output_file='../html_reports/$(basename $(notdir $<)).html')"

# Make the figure
output/Figure1.un.tiff \
  output/Figure1_S_longTermPCA.un.tiff \
  output/Figure1_S_timeplot.un.tiff \
  html_reports/Figure1.html \
  : \
  scripts/Figure1.Rmd tmp/airoldiPCAanalysis.RData \
  tmp/coulterCounterData.RData 
	mkdir -p tmp output html_reports plos_submission
	Rscript --vanilla -e "rmarkdown::render('$<',output_file='../html_reports/$(basename $(notdir $<)).html')"

#
#
#
# FIGURE 2
#
#
#

# The 4tU label chase experiment is called dme211. 
# This required HPC work, and
# because I don't have a nice script to run it all and 
# makefiles don't play nice # with dependencies submission, 
# I tried that and it just gets too # complicated for me. 
# Maybe there's a nice solution out there, I didn't find it.
# Anyways, that requires:
#   /data/cgsb/gencore/out/Gresham/2017-01-06_HGGNWBGX2/new/ 
# which is the folder of the raw FASTQs, demultiplexed correctly 
#   /home/dhm267/ref/bnspk4ecolMG1655saccerR64/ 
# which is the reference file of yeast + the 4 Neymotin-produced
# in-vitro spikeins + ecoli because we tried to spike that in
# (and didn't get diddly-squat reads out) this is called BES here
# locally in the data/ directory,
#   data/dme211/dme211barcodeIndex.csv 
# the demultiplexing barcode index
#   data/dme211/sampleSheet.csv 
# the samples we ran
#   data/dme211/trumiseqAdapters.csv
# and the trumiseq adapter designs and numbers
#
# First, we trimmed using this script to get the right trimmer, then
# trim using `cutadapt`
#   sbatch scripts/dme211trimming.sbatch
# Then we used this batch script to align using tophat using 
# optimized parameters (not shown, but was on three replicate 
# in-silico datasets simulated with Flux Simulator)
#   sbatch scripts/dme211aligning.sbatch
# Then we filtered reads on quality above 20, matches of 50, and
# used `umi_tools` with this script to ID PCR duplicates.
#   sbatch scripts/dme211deduping.sbatch
# Then we fed this into `htseq-count` script to count reads per
# genomic feature.
#   sbatch scripts/dme211counting.sbatch
# Once done, then these are saved to a folder in 
#   data/dme211/*htseqcounts.txt
# and they are downloaded for local work.

# dme211 local work - here we read in the data and output 
# normalized data for modeling
tmp/dme211normalizedData.RData tmp/dme211datarForModeling.RData \
  tmp/dme211datarForModelingDirect.RData \
  tmp/dme211ms.RData \
  output/Figure2_Table_RawCountsTableForPulseChase.csv \
  output/Figure2_Table_PulseChaseDataNormalizedDirectAndFiltered.csv \
  output/Figure2_Table_PulseChaseDataNormalizedByModel.csv \
  html_reports/dme211importAndQC.html \
  :\
  scripts/dme211importAndQC.Rmd data/dme211/ tmp/NameIDList.RData \
  data/BES/BES.gff
	mkdir -p tmp output html_reports plos_submission
	Rscript --vanilla -e "rmarkdown::render('$<',output_file='../html_reports/$(basename $(notdir $<)).html')"

# Here we fit log-linear models to everything
tmp/dme211fitMaudz.RData tmp/dme211fitMaudzAltNorm.RData \
  tmp/dme211fitModelsDirect.RData tmp/dme211fitModels.RData \
  html_reports/dme211modeling.html \
  : \
  scripts/dme211modeling.Rmd tmp/NameIDList.RData \
  tmp/dme211normalizedData.RData \
  tmp/dme211datarForModeling.RData \
  tmp/dme211datarForModelingDirect.RData 
	mkdir -p tmp output html_reports plos_submission
	Rscript --vanilla -e "rmarkdown::render('$<',output_file='../html_reports/$(basename $(notdir $<)).html')"

# Here we look at the modeling, and identify which of the 
# transcripts we think are bonafide degraders.
tmp/dme211bonafideDegraders.RData \
  html_reports/dme211labelingDynamics.html \
  : \
  scripts/dme211labelingDynamics.Rmd \
  tmp/NameIDList.RData \
  tmp/dme211normalizedData.RData tmp/dme211datarForModeling.RData \
  tmp/dme211datarForModelingDirect.RData \
  tmp/dme211fitMaudzAltNorm.RData tmp/dme211fitMaudz.RData \
  tmp/dme211normalizedData.RData tmp/NameIDList.RData 
	mkdir -p tmp output html_reports plos_submission
	Rscript --vanilla -e "rmarkdown::render('$<',output_file='../html_reports/$(basename $(notdir $<)).html')"

# For the below cis-elements analysis to run right, you need a variety
# of tools:
#   - FIRE, TEISER from Tavazoie's lab
#   - #ATS from morris lab
#   - Vienna RNA fold
#   - bedtools
#   - DECOD
#   - MEME suite
#
# If you want to re-run each of these analyses, you should install
# all of the packages. For some of them, they are locally installed,
# ie in the scripts directory.
# DECOD setup
#scripts/DECOD/DECOD-20111024.jar \
#  : \
#  scripts/DECOD-V1.01-20111024.zip
#	mkdir -p scripts/DECOD
#	cp scripts/DECOD-V1.01-20111024.zip scripts/DECOD
#	cd scripts/DECOD && unzip $(notdir $<)
#	touch scripts/DECOD/DECOD-20111024.jar

tmp/dme211decayvsdynamics.RData \
  tmp/dme211modelingResultTable.RData \
  tmp/dme211modelingResultTableDirect.RData \
  output/Figure2_Table_PulseChaseModelingResultTable_ModelNormalization.csv \
  output/Figure2_Table_PulseChaseModelingResultTable_DirectNormalization.csv \
  output/Figure2_S_globalComparisons.un.tiff \
  output/Figure2_Table_AcceleratedDegradationTranscripts_EnrichedGOandKEGGterms.csv \
  output/Figure2_Table_AcceleratedDegradationTranscriptsDirectNormalization_EnrichedGOandKEGGterms.csv \
  output/Figure2_S_comparisonToESR.un.tiff \
  output/Figure2_S_lengthAndCodons.un.tiff \
  output/Table1_pulseChaseSummaryStatistics.csv \
  output/Figure2_S_averageMotifsPerSection.un.tiff \
  output/Table1.tex \
  html_reports/dme211analysis.html \
  : \
  scripts/dme211analysis.Rmd tmp/NameIDList.RData \
  tmp/dme211datarForModeling.RData \
  tmp/dme211bonafideDegraders.RData \
  scripts/DECOD/DECOD-20111024.jar \
  data/godard2007ncrModified.csv \
  data/airoldiEtAl2016MBoC/TableS5.csv \
  data/brauer2008tableS1.csv \
  data/mitchell2013suppTable3Tier1.csv \
  data/mitchell2013suppTable3Tier2.csv \
  data/williams2014localizationAnnotation.txt \
  data/khong2017sup2yeastSGtxtome.csv \
  data/sgd_171019.gff \
  data/pelechano2013S1tifs.txt \
  data/freeberg2014table10.csv \
  tmp/dme211fitModelsDirect.RData tmp/dme211fitModels.RData \
  tmp/dme211fitMaudz.RData tmp/dme211fitMaudzAltNorm.RData
	mkdir -p tmp output html_reports plos_submission
	Rscript --vanilla -e "rmarkdown::render('$<',output_file='../html_reports/$(basename $(notdir $<)).html')"

output/Figure2.un.tiff \
  output/Figure2_S_sixExamplesOfDestabilizationWithoutRepression.un.tiff \
  output/Figure2_S_justDestabilizedDecayvsDynamics.un.tiff \
  html_reports/Figure2.html \
  :\
  scripts/Figure2.Rmd tmp/NameIDList.RData \
  tmp/dme211datarForModeling.RData \
  tmp/dme211fitModels.RData \
  tmp/dme211modelingResultTable.RData \
  tmp/dme211decayvsdynamics.RData \
  tmp/airoldiEtAl2016MBoCTableS7Melty.RData
	mkdir -p tmp output html_reports plos_submission
	Rscript --vanilla -e "rmarkdown::render('$<',output_file='../html_reports/$(basename $(notdir $<)).html')"

#
#
#FIGURE 3 is the method, and validation
#
#

# dme161 - was to check if the FACS and microscopy line up with the
# qPCR
tmp/dme161gatez.RData tmp/dme161flowdata.RData\
  html_reports/dme161analyzingFACS.html \
  :\
  scripts/dme161analyzingFACS.Rmd data/dme161
	mkdir -p tmp output html_reports plos_submission
	Rscript --vanilla -e "rmarkdown::render('$<',output_file='../html_reports/$(basename $(notdir $<)).html')"

# dme141 - was to check if gap1 delete abrogates the flow signal
output/Figure3_S_gap1deleteControl.un.tiff \
  html_reports/dme141analyzingFlow.html \
  : \
  scripts/dme141analyzingFlow.Rmd data/dme141
	mkdir -p tmp output html_reports plos_submission
	Rscript --vanilla -e "rmarkdown::render('$<',output_file='../html_reports/$(basename $(notdir $<)).html')"

# Making the actual figure
output/Figure3.un.tiff \
  html_reports/Figure3.html \
  :\
  scripts/Figure3.Rmd tmp/dme161flowdata.RData \
  tmp/dme161gatez.RData \
  data/dme161/microscopy/exp161f6manualQuant.tab \
  data/dme161/microscopy/exp161f6/representativeImages/*tif
	mkdir -p tmp output html_reports plos_submission
	Rscript --vanilla -e "rmarkdown::render('$<',output_file='../html_reports/$(basename $(notdir $<)).html')"

#
#
#FIGURE 4 is the BFF/FFS measurement results
#
#

### dme209 quantification
# This was processesed using the dme209*sbatch scripts, kicked along
# by using the dme209stoker.sh script to submit jobs.
# Read that script for how to tweak steps in there.
# Part of that pipeline is to use umi_tools, but we actually don't
# for the final modeling. So make sure it makes the non-umi_tool'd
# files too. It should from this version.

### dme209facs
tmp/dme209FACSgatez.RData tmp/Figure4facs.RData \
  tmp/dme209flowCytometry.RData\
  html_reports/dme209analyzeFACS.html \
  : \
  scripts/dme209analyzeFACS.Rmd data/dme209/facs
	mkdir -p tmp output html_reports plos_submission
	Rscript --vanilla -e "rmarkdown::render('$<',output_file='../html_reports/$(basename $(notdir $<)).html')"

# dme209seq import, QC, and filter the sequencing data
tmp/dme209modelingDat.RData \
  output/Figure4_Table_BFFcountsAndGateSettingsFACS.csv \
  output/Figure4_S_umiSaturationCurve.un.tiff \
  output/Figure4_S_PCAonFilteredQCdData.un.tiff \
  output/Figure4_S_GClengthBiasBarcodes.un.tiff \
  output/Figure4_Table_BFFinputData.csv \
  html_reports/dme209importQCformat.html \
  : \
  scripts/dme209importQCformat.Rmd data/dme209 \
  tmp/dme209FACSgatez.RData tmp/NameIDList.RData
	ulimit -s 65546 && Rscript --vanilla -e "rmarkdown::render('$<',output_file='../html_reports/$(basename $(notdir $<)).html')"

# dme209 do the modeling on the filtered data
tmp/dme209_modelsToConsider.RData\
  output/Figure4_Table_BFFmodelingData.csv \
  html_reports/dme209modeling.html \
  : \
  scripts/dme209modeling.Rmd \
  tmp/dme209modelingDat.RData tmp/NameIDList.RData 
	mkdir -p tmp output html_reports plos_submission
	Rscript --vanilla -e "rmarkdown::render('$<',output_file='../html_reports/$(basename $(notdir $<)).html')"

# dme209 analyze the fits, pick the models which look reliable
tmp/dme209_filteredFits.RData tmp/dme209_rankingList.RData\
  output/Figure4_Table_BFFallFitModels.csv \
  output/Figure4_Table_BFFfilteredPooledModels.csv \
  output/Figure4_Table_GSEanalysisOfBFFresults.csv \
  output/Figure4_S_PreShiftPredictingPostShiftLM.un.tiff \
  html_reports/dme209analysis.html \
  : \
  scripts/dme209analysis.Rmd tmp/dme209_modelsToConsider.RData \
  data/oliveria2015sciSigSuppS9.csv \
  data/cispbpRNAyeast171110.csv \
  data/sgd_go_full_171013.txt \
  tmp/dme209modelingDat.RData tmp/dme211modelingResultTable.RData \
  tmp/NameIDList.RData
	mkdir -p tmp output html_reports plos_submission
	Rscript --vanilla -e "rmarkdown::render('$<',output_file='../html_reports/$(basename $(notdir $<)).html')"

# Making the actual figure
output/Figure4.un.tiff \
  html_reports/Figure4.html \
  :\
  scripts/Figure4.Rmd tmp/NameIDList.RData \
  tmp/dme209modelingDat.RData tmp/dme209_modelsToConsider.RData \
  tmp/dme209_rankingList.RData \
  tmp/Figure4facs.RData tmp/dme209_filteredFits.RData
	mkdir -p tmp output html_reports plos_submission
	Rscript --vanilla -e "rmarkdown::render('$<',output_file='../html_reports/$(basename $(notdir $<)).html')"

#
#
# FIGURE 5
#
#

# Making the actual figure, we just read qPCR stuff directly
output/Figure5.un.tiff \
  output/Figure5_S_sulfateAssimilation.un.tiff \
  output/Figure5_S_negGluconeogenesis.un.tiff \
  output/Figure4_S_poorlyQuantifiedStrains.un.tiff \
  output/Figure5_S_bothutr.un.tiff \
  html_reports/Figure5.html \
  :\
  scripts/Figure5.Rmd \
  tmp/dme209modelingDat.RData tmp/dme209_modelsToConsider.RData  \
  tmp/NameIDList.RData  \
  tmp/dme209modelingDat.RData tmp/dme209_modelsToConsider.RData \
   tmp/dme209_filteredFits.RData tmp/dme209_rankingList.RData
	mkdir -p tmp output html_reports plos_submission
	Rscript --vanilla -e "rmarkdown::render('$<',output_file='../html_reports/$(basename $(notdir $<)).html')"

# Microscopy was captured as DV stacks, then max projected with this:
# cd data/microscopy/dme238dme240/ && ../../../scripts/ijdme238dme240maxProj.sh *dv && cd ../../../
output/Figure5_S_pbodyMicroscopy.un.tiff \
  : scripts/pbodyMicroscopy.Rmd data/dme238dme240
	mkdir -p tmp output html_reports plos_submission
	Rscript --vanilla -e "rmarkdown::render('$<',output_file='../html_reports/$(basename $(notdir $<)).html')"

#
#
# Supplementary material, the two protocols and detailed writeups
#
#


output/Figure2_Supplementary_Writeup.pdf \
  html_reports/fig2_supplementary.html \
  : \
  scripts/fig2_supplementary.Rmd \
  scripts/preamble-latex.tex \
  tmp/dme211ms.RData \
  tmp/NameIDList.RData  \
  tmp/dme211normalizedData.RData tmp/dme211datarForModeling.RData \
  tmp/dme211datarForModelingDirect.RData \
  tmp/dme211fitMaudzAltNorm.RData tmp/dme211fitMaudz.RData \
  tmp/dme211normalizedData.RData 
	mkdir -p tmp output html_reports plos_submission
	Rscript --vanilla -e "rmarkdown::render('$<',output_file='../output/Figure2_Supplementary_Writeup.pdf',output_dir='output/')"

# Method schematics
tmp/%schematic.pdf: scripts/%schematic.md
	pandoc -o $@ $<

output/Figure4_S_umiSaturationCurve.png: output/Figure4_S_umiSaturationCurve.tiff
	convert $< $@

output/Figure4_Supplementary_Writeup.pdf \
  html_reports/fig4_supplementary.html \
  : \
  scripts/fig4_supplementary.Rmd \
  scripts/preamble-latex.tex \
  tmp/sobaseqPCRschematic.pdf \
  output/Figure4_S_umiSaturationCurve.png \
  data/dme234/dme234plottingObject.RData
	mkdir -p tmp output html_reports plos_submission
	Rscript --vanilla -e "rmarkdown::render('$<',output_file='../output/Figure4_Supplementary_Writeup.pdf',output_dir='output/')"

# dme234 in silico evaluation of bioinformatics for the FFS thingy
#   On a `sbatch` running core, you can use the 
#   `scripts/dme234stoker.sh` scripts to submit jobs automatically
#   to make this run. You may have to tweak it to get the job
#   order and available CPUs to run right.

#
#
# the shiny-ing
#
#

shiny = shiny/appdata/NameIDList.RData \
  shiny/appdata/dme211datarForModeling_modelNorm.RData \
  shiny/appdata/dme211fitModels_modelNorm.RData \
  shiny/appdata/dme211datarForModeling_directNorm.RData \
  shiny/appdata/dme211fitModels_directNorm.RData \
  shiny/appdata/dme209modelingDat.RData \
  shiny/appdata/dme209_modelsToConsider.RData \
  shiny/appdata/dme209_filteredFits.RData \
  shiny/app.R

shiny/appdata/NameIDList.RData \
  shiny/appdata/dme211datarForModeling_modelNorm.RData \
  shiny/appdata/dme211fitModels_modelNorm.RData \
  shiny/appdata/dme211datarForModeling_directNorm.RData \
  shiny/appdata/dme211fitModels_directNorm.RData \
  : \
      tmp/NameIDList.RData \
      tmp/dme211datarForModeling.RData \
      tmp/dme211fitModels.RData \
      tmp/dme211datarForModelingDirect.RData \
      tmp/dme211fitModelsDirect.RData
	mkdir -p shiny/appdata
	cp tmp/NameIDList.RData shiny/appdata/NameIDList.RData
	cp tmp/dme211datarForModeling.RData shiny/appdata/dme211datarForModeling_modelNorm.RData
	cp tmp/dme211fitModels.RData shiny/appdata/dme211fitModels_modelNorm.RData
	cp tmp/dme211datarForModelingDirect.RData shiny/appdata/dme211datarForModeling_directNorm.RData
	cp tmp/dme211fitModelsDirect.RData shiny/appdata/dme211fitModels_directNorm.RData

shiny/appdata/dme209modelingDat.RData \
shiny/appdata/dme209_modelsToConsider.RData \
shiny/appdata/dme209_filteredFits.RData \
  : \
      tmp/dme209modelingDat.RData \
      tmp/dme209_modelsToConsider.RData \
      tmp/dme209_filteredFits.RData
	cp tmp/dme209modelingDat.RData shiny/appdata/dme209modelingDat.RData 
	cp tmp/dme209_modelsToConsider.RData shiny/appdata/dme209_modelsToConsider.RData 
	cp tmp/dme209_filteredFits.RData shiny/appdata/dme209_filteredFits.RData 

#
#
# make paper
#
#

figure1 = output/Figure1.tiff \
  output/Figure1_S_longTermPCA.tiff \
  output/Figure1_S_timeplot.tiff  \
  output/Figure1_S_higherComponents.tiff \

figure2 = output/Figure2.tiff \
  output/Figure2_S_averageMotifsPerSection.tiff \
  output/Figure2_S_globalComparisons.tiff \
  output/Figure2_S_comparisonToESR.tiff \
  output/Figure2_S_justDestabilizedDecayvsDynamics.tiff \
  output/Figure2_S_sixExamplesOfDestabilizationWithoutRepression.tiff\
  output/Figure2_S_lengthAndCodons.tiff \
  output/Figure2_Supplementary_Writeup.pdf
#  output/Table1.tex \

figure3 = output/Figure3.tiff \
  output/Figure3_S_gap1deleteControl.tiff

figure4 = output/Figure4.tiff \
  output/Figure4_S_GClengthBiasBarcodes.tiff \
  output/Figure4_S_PCAonFilteredQCdData.tiff \
  output/Figure4_S_umiSaturationCurve.tiff \
  output/Figure4_Supplementary_Writeup.pdf

figure5 = output/Figure5.tiff \
  output/Figure5_S_bothutr.tiff \
  output/Figure4_S_PreShiftPredictingPostShiftLM.tiff \
  output/Figure4_S_poorlyQuantifiedStrains.tiff \
  output/Figure5_S_pbodyMicroscopy.tiff \
  output/Figure5_S_negGluconeogenesis.tiff \
  output/Figure5_S_sulfateAssimilation.tiff 

# 2.63 to 7.5 in width, 8.75 max height in
output/%.tiff: output/%.un.tiff
	convert $< -gravity Center -extent 101% -compress lzw $@

alltiff = $(figure1) $(figure2) $(figure3) $(figure4) $(figure5)

plosconversions = \
  plos_submission/millerBrandtGresham2018_main_text.pdf \
  plos_submission/Figure1.tiff \
  plos_submission/Figure2.tiff \
  plos_submission/Figure3.tiff \
  plos_submission/Figure4.tiff \
  plos_submission/Figure5.tiff \
  plos_submission/S1_Appendix.pdf \
  plos_submission/S2_Appendix.pdf \
  plos_submission/S1_Table.csv \
  plos_submission/S2_Table.csv \
  plos_submission/S3_Table.csv \
  plos_submission/S4_Table.csv \
  plos_submission/S5_Table.csv \
  plos_submission/S6_Table.csv \
  plos_submission/S7_Table.csv \
  plos_submission/S8_Table.csv \
  plos_submission/S9_Table.csv \
  plos_submission/S10_Table.csv \
  plos_submission/S11_Table.csv \
  plos_submission/S12_Table.csv \
  plos_submission/S1_Fig.tiff\
  plos_submission/S2_Fig.tiff\
  plos_submission/S3_Fig.tiff\
  plos_submission/S4_Fig.tiff\
  plos_submission/S5_Fig.tiff\
  plos_submission/S6_Fig.tiff\
  plos_submission/S7_Fig.tiff\
  plos_submission/S8_Fig.tiff\
  plos_submission/S9_Fig.tiff\
  plos_submission/S10_Fig.tiff\
  plos_submission/S11_Fig.tiff\
  plos_submission/S12_Fig.tiff\
  plos_submission/S13_Fig.tiff\
  plos_submission/S14_Fig.tiff\
  plos_submission/S15_Fig.tiff\
  plos_submission/S16_Fig.tiff\
  plos_submission/S17_Fig.tiff\
  plos_submission/S18_Fig.tiff

$(plosconversions): $(alltiff) output/miller2018_main_text.pdf output/Figure1.un.pdf
	mkdir -p tmp output html_reports plos_submission
	cp output/miller2018_main_text.pdf plos_submission/millerBrandtGresham2018_main_text.pdf 
#
	cp output/Figure1.tiff plos_submission/Figure1.tiff
	cp output/Figure1.un.pdf plos_submission/Figure1.uncorrected.pdf
	cp output/Figure2.tiff plos_submission/Figure2.tiff
	cp output/Figure3.tiff plos_submission/Figure3.tiff
	cp output/Figure4.tiff plos_submission/Figure4.tiff
	cp output/Figure5.tiff plos_submission/Figure5.tiff
#
	cp output/Figure2_Supplementary_Writeup.pdf plos_submission/S1_Appendix.pdf
	cp output/Figure4_Supplementary_Writeup.pdf plos_submission/S2_Appendix.pdf
#
	cp output/Figure1_Table_PCAresults.csv plos_submission/S1_Table.csv
	cp output/Figure1_Table_GSEofGOtermsAgainstPCcorrelation.csv plos_submission/S2_Table.csv
	cp output/Figure2_Table_RawCountsTableForPulseChase.csv plos_submission/S3_Table.csv
	cp output/Figure2_Table_PulseChaseDataNormalizedDirectAndFiltered.csv plos_submission/S4_Table.csv
	cp output/Figure2_Table_PulseChaseDataNormalizedByModel.csv plos_submission/S5_Table.csv
	cp output/Figure2_Table_PulseChaseModelingResultTable_ModelNormalization.csv plos_submission/S6_Table.csv
	cp output/Figure2_Table_AcceleratedDegradationTranscripts_EnrichedGOandKEGGterms.csv plos_submission/S7_Table.csv
	cp output/Figure4_Table_BFFcountsAndGateSettingsFACS.csv plos_submission/S8_Table.csv
	cp output/Figure4_Table_BFFfilteredPooledModels.csv plos_submission/S9_Table.csv
	cp output/Figure4_Table_GSEanalysisOfBFFresults.csv plos_submission/S10_Table.csv
	cp data/strains.csv plos_submission/S11_Table.csv
	cp data/primers.csv plos_submission/S12_Table.csv
#
	cp output/Figure1_S_longTermPCA.tiff  plos_submission/S1_Fig.tiff
	cp output/Figure1_S_timeplot.tiff plos_submission/S2_Fig.tiff
	cp output/Figure1_S_higherComponents.tiff plos_submission/S3_Fig.tiff
	cp output/Figure2_S_globalComparisons.tiff plos_submission/S4_Fig.tiff
	cp output/Figure2_S_comparisonToESR.tiff plos_submission/S5_Fig.tiff
	cp output/Figure2_S_justDestabilizedDecayvsDynamics.tiff plos_submission/S6_Fig.tiff
	cp output/Figure2_S_sixExamplesOfDestabilizationWithoutRepression.tiff plos_submission/S7_Fig.tiff
	cp output/Figure2_S_lengthAndCodons.tiff plos_submission/S8_Fig.tiff
	cp output/Figure2_S_averageMotifsPerSection.tiff plos_submission/S9_Fig.tiff
	cp output/Figure3_S_gap1deleteControl.tiff plos_submission/S10_Fig.tiff
	cp output/Figure4_S_PCAonFilteredQCdData.tiff plos_submission/S11_Fig.tiff
	cp output/Figure4_S_umiSaturationCurve.tiff plos_submission/S12_Fig.tiff
	cp output/Figure5_S_negGluconeogenesis.tiff plos_submission/S13_Fig.tiff
	cp output/Figure5_S_sulfateAssimilation.tiff plos_submission/S14_Fig.tiff
	cp output/Figure4_S_PreShiftPredictingPostShiftLM.tiff plos_submission/S15_Fig.tiff
	cp output/Figure4_S_poorlyQuantifiedStrains.tiff plos_submission/S16_Fig.tiff
	cp output/Figure5_S_bothutr.tiff plos_submission/S17_Fig.tiff
	cp output/Figure5_S_pbodyMicroscopy.tiff plos_submission/S18_Fig.tiff


output/miller2018_main_text.pdf\
  : \
  scripts/miller2018_main_text.tex \
  scripts/miller2018_references.bib \
  $(shiny) \
  scripts/plos2015.bst 
	mkdir -p tmp output html_reports plos_submission
	pdflatex -output-directory output/ scripts/miller2018_main_text.tex || true
	bibtex output/miller2018_main_text || true
	pdflatex -output-directory output/ scripts/miller2018_main_text.tex || true
	pdflatex -output-directory output/ scripts/miller2018_main_text.tex

.PHONY: dp draft #draft paper
dp: $(plosconversions) 
	pdflatex -output-directory output/ scripts/miller2018_main_text.tex
draft: $(plosconversions) 
	pdflatex -output-directory output/ scripts/miller2018_main_text.tex

.PHONY: all
all: output/miller2018_main_text.pdf \
  $(plosconversions) \
  $(dirStructure) \
  $(figure1) \
  $(figure2) \
  $(figure3) \
  $(figure4) \
  $(figure5) \
  $(shiny)



#
#
# DATA ARCHIVING
#
#

.PHONY: zipper zip_data zip_tmp zip_html zip_microscopy zip_fastq 
zipper: zip_data zip_tmp zip_html zip_microscopy zip_fastq  zip_shiny all_figures_and_tables.zip
	echo "this is going to take a while, it's level 9 compression on about 104G of files"

minor_zipper: zip_data zip_tmp zip_html zip_shiny all_figures_and_tables.zip
	echo "this shouldn't be that long"

zip_data: 
	zip -r data.zip data -x data/microscopy/\* data/microscopy/ data/dme209/dme209.fastq data/dme211/dme211_fastq/\* data/dme211/dme211_fastq/

zip_shiny: shiny
	zip -r independent_shiny_archive.zip shiny 

zip_microscopy: data/microscopy
	zip -9r microscopy_data.zip data/microscopy/

zip_fastq: data/dme209/dme209.fastq data/dme211/dme211_fastq/*
	zip --split-size 4500m -9r fastq_data.zip data/dme209/dme209.fastq data/dme211/dme211_fastq/* 

zip_tmp: 
	zip -r tmp.zip tmp -x tmp/folded_\* 

zip_html: 
	zip -r html_reports.zip html_reports/

zip_submission: 
	zip -r plos_submission.zip plos_submission/

all_figures_and_tables.zip: output/ 
	zip -r all_figures_and_tables.zip output/ -x output/*_files -x output/*log

.PHONY: unzip unzip_html unzip_tmp unzip_data unzip_microscopy unzip_fastq
unzip: unzip_html unzip_data unzip_tmp 
unzip_all: unzip_html unzip_data unzip_tmp unzip_microscopy unzip_fastq

unzip_data: data.zip
	mkdir -p data/
	unzip data.zip -d ./

unzip_microscopy: microscopy_data.zip
	unzip microscopy_data.zip -d ./

unzip_fastq: 
	zip -s0 fastq_data.zip --out whole_fastq_data.zip 
	unzip -o whole_fastq_data.zip -d ./

unzip_tmp: tmp.zip
	unzip tmp.zip -d ./

unzip_html: html_reports.zip
	unzip html_reports.zip -d ./

#
#
#
#
#

.PHONY: clean
clean:
	read -n 1 -p "This is going to delete all the intermediates, only if you press 'y'" tmp; \
	if [ $$tmp != "y" ]; then echo "	Okay I won't	"; else \
	rm -r tmp/ ;\
	rm -r output/ ;\
	rm -r html_reports/ ;\
	rm -r plos_submission/ ;\
	rm -r scripts/*_cache ;\
	rm -r scripts/html_reports/ ;\
	fi
