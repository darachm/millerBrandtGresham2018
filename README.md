This is a repo that holds all the analysis for the paper
"Systematic identification of factors mediating accelerated mRNA
degradation in response to changes in environmental nitrogen" by
Miller, Brandt, Gresham in 2018.

All the various analyses and figure generation were written with a 
GNU Makefile to make the set of analyses entirely or modularly
reproducible. This section describes how to reproduce everything,
although with
[more of an understanding of Makefiles](https://www.gnu.org/software/make/manual/make.html#Introduction)
one can simply re-make subsections of the analyses<sup>1</sup>. 

Unzipping the `html_reports.zip` will give you a folder of HTML
reports from the various R analyses, which may be all you need.

# How to use this:

1. Download `data.zip`, `html_reports.zip`, and `tmp.zip`
  from the OSF<sup>2</sup>. Put them here, in this folder.
2. Run `make unzip_data` to just unzip the data. Or, you can run
  `make unzip` to unzip all three.
3. Run all or parts of this:
    - Run `make all` to remake everything. This will take extensive
      dependencies<sup>3</sup> and < 24 hours
      (on a t420)<sup>4</sup>.
    - Re-run a subset of the analysis. See the Makefile documentation
      to identify this. To remake a particular report, then run
      `make html_reports/thatParticularReport.html`.

**While running, it may choke on lack of memory or segfaults from
the Makefile. Re-trying `make all` seems to stochastically work
for getting to to work. Sorry.**

The scripts and instructions for doing the sequence alignment steps
are included in this repo but require more supervision that is 
practical for a GNU Makefile. These are designed for a 
`SLURM` high performance computing system. 
Therefore we provide the various intermediate files post-alignment
in the data zip archives.
To unzip the fastq files for this, run `make unzip_fastq` 
after having downloaded the set of archives [ 
  `fastq_data.zip` 
  `fastq_data.z01` 
  `fastq_data.z02` 
  `fastq_data.z03` 
  `fastq_data.z04` ]. This is a multi-part archive because OSF
  sensibly limits to 5GB individual files for their archives.

It's also available on SRA, but these are raw 
(pre-alignment/processing).

`make unzip_microscopy` extracts the raw microscopy images (`.dv`).

# Organization:

`data/`
 :  is a directory with the raw data or intermediate files generated
    from the raw data. This is especially true of things like `htseq`
    counts downstream of HPC so we can do laptop work. This should
    be distributed on OSF as a zipped archive, and should make
    these scripts run okay when distributed as a git repo.

`scripts/`
 :  contain the actual scripts, R and shell (called from rmarkdown).
    Output scripts depend on RData objects made by analysis scripts,
    hence the use of a `Makefile`.

`output/` 
 :  contains all figures, tables, and such.

`plos_submission/` 
 :  contains all submitted files, renamed (copied from output)

`tmp/`
 :  is a scratch folder, where various intermediates are held.
    It gets really big, especially when running the sequencing steps.
    Again, this is zipped up for convienence in re-running certain
    small bits.

`shiny/`
:   contains the shiny application, you can point your 
    `shiny::runApp` at this folder to run it

---

<sup>1</sup>
For example,
"`make output/Figure2.png`" will execute code to take the
gene feature counts from the post-alignment step through various
filtering, modeling, and analysis steps, then reproduce Figure 2
as seen in the text. 

<sup>2</sup>: [https://osf.io/7ybsh/files/](https://osf.io/7ybsh/files)

<sup>3</sup>
There's a lot of dependencies. I tried to put a comprehensive list
here, but I likely forgot some. A better system would be a
containerized setup, but for now this is what I did.

I would recommend that you only attempt to re-build the analyses
or figures you want to regenerate, and use the intermediate files
in the `tmp.zip` to accelerate this process.
The cis element analysis for Figure 2 is quite laborious, and
can be commented out to re-generate Figure 2 more quickly.

- Alignments:
    - `SLURM` system (or adapt the scripts to your system)
    - `cutadapt` 1.12
    - `r` 3.3.2
    - `perl` 5.24.0
    - `bowtie2` 2.2.9
    - `tophat` 2.1.1
    - `htseq` 0.6.1p1
    - `samtools` 1.3.1
    - `umitools` 0.4.2
    - `python3` 3.5.3
    - `bwa` 0.7.15
    - `Barnone` 1.0
- Laptop analysis
    - `R` packages:
        - `rmarkdown` 1.8
        - `tidyverse` 1.2.1
        - `multidplyr` 0.0.0.9000
        - `plyr` 1.8.4
        - `stats4` 3.4.2
        - `reshape2` 1.4.2
        - `flowCore` 1.42.3 from BioConductor
        - `pcaMethods` 1.68.0 Stacklies et al. 2007 from BioConductor
        - `clusterProfiler` 3.4.4 Yu et al. 2012 from BioConductor
        - `ggrepel` 0.7.0 \texttt{\url{https://github.com/slowkow/ggrepel}}, but CRAN version should also work
        - `stringr` 1.2.0
        - `Cairo` 1.5-9
        - `org.Sc.sgd.db` from BioConductor
        - `GenomicRanges` 1.28.6 from BioConductor
        - `BSgenome.Scerevisiae.UCSC.sacCer3` 1.4.0 from BioConductor
        - `Biostrings` 2.44.2 from BioConductor
        - `chron` 2.3-51
        - `knitr` 1.17
        - `qvalue` 2.8.0 from BioConductor
        - `magrittr` 1.5
        - `cowplot` 0.9.1
        - `gtable` 0.2.0
        - `magick` 1.5
        - `png` 0.1-7
    - Other:
        - FIRE and TEISER (available from [Saeed Tavazoie's website](https://tavazoielab.c2b2.columbia.edu/lab/tools/))
        - [DECOD](http://sb.cs.cmu.edu/DECOD/) (relevant `jar` is tracked in git repo for convienence)
        - [Vienna RNAfold package](https://www.tbi.univie.ac.at/RNA/index.html#download)
        - The Makefile clones #ATSpipeline from Quaid Morris' github
        - [MEME suite](http://meme-suite.org/)
        - [bedtools](https://github.com/arq5x/bedtools2)

<sup>4</sup>
There is one small bug. Running `dme209importAndQC.Rmd` may choke
up on available memory. You just have to let it die, then run
`make all` again. I think it has to do with the various
automatic caching schemes of the `rmarkdown` package, and for some
reason it's trying to load something twice into memory, but I
do not have the time to either disable all the caching or understand
how that caching is decided, so you will just have to run it twice.
Sorry.
