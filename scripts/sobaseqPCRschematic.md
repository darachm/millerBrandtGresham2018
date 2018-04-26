---
title: "Schematic of SoBaSeq wetbench"
header-includes:
  - \usepackage{tikz}
  - \usetikzlibrary{positioning}
  - \usetikzlibrary{arrows.meta}
  - \usetikzlibrary{decorations.pathmorphing}
  - \usetikzlibrary{decorations.shapes}
  - \usetikzlibrary{decorations.markings}
  - \usetikzlibrary{decorations.fractals}
  - \renewcommand{\familydefault}{\sfdefault}
output:
  pdf_document:
geometry: paper=a4paper
---

<!--    file/.style={rectangle,draw=black!50,anchor=west},
    fileExp/.style={rectangle,draw=black!50,anchor=west,align=left,style=dashed},
geometry: paper=a5paper,landscape
-->

\centering
\pagenumbering{gobble}
\pagebreak

\begin{tikzpicture}[
  shift={(0,2)},
  scale=1.0, every node/.style={scale=1.0},
  overlay,
  dna/.style={-,line width=2pt},
  strainBarcode/.style={-,decorate,decoration={snake,amplitude=1.5mm}},
  sampleBarcode/.style={-,decorate,decoration=Koch curve type 2},
  umiBarcode/.style={-,decorate,decoration={zigzag,amplitude=1.5mm,
    segment length=1.5mm}},
  primer/.style={style=dashed,line width=2pt},
  extension/.style={-{Stealth[length=3mm]},style=dashed},
  prime/.style={-{Straight Barb[left,length=2mm]},line width=2pt},
  hybridize/.style={decorate,decoration={markings,
    mark=between positions 0 and 1 step 2mm
    with { \draw (0,0) -- (0,-0.2cm); } }},
  trans/.style={-{Latex[length=4mm]},shorten <=2mm,shorten >=2mm,
    style=dotted},
  label/.style={-{Latex[length=2mm]},shorten <=2mm,shorten >=2mm,line 
    width=0.5pt,style=dashed},
  gDNA/.style={line width=2pt,color=blue},
  newDNA/.style={line width=2pt,color=black},
]

\coordinate (key) at (-4,-1);
\node[align=left,anchor=west,draw=black] at (key) {
  Different types sequences are colored, with \\
  \textbf{new DNA from primers and polymerases in black},\\
  \textcolor{orange}{strain barcode in orange},\\
  \textcolor{purple}{UMI degenerate sequence in purple},
  \textcolor{red}{3' phosphorylated blocker oligos in red}\\
  \textcolor{olive}{sample index barcode in green},
  and \textcolor{blue}{other genomic DNA in blue}.
  };

%%% pree 
\coordinate (r0anchor) at (-10,-5);
\coordinate[right=5cm of r0anchor] (r0r1transEnd);
%\node[anchor=south west,above right=4cm and 1cm of r0anchor,font=\large] {Round 1};
\draw[trans] (r0anchor) to 
  node[align=left,anchor=south] {
    \textbf{Round 1}. Combine in tube:\\
    Vent exo- polymerase + \\
    buffer, dNTPs, salts + \\
    \textcolor{blue}{extracted gDNA} + \\
    \textcolor{purple}{UMI first-round primer} + \\
    \textcolor{red}{off-target blockers}\\
    \\
    Melt and anneal all DNA
  }
  (r0r1transEnd);
%%% gDNA target
\coordinate (gDNAanchor) at (-4,-5) {};
\coordinate[above=0cm of gDNAanchor] (gDNAorigin) {};
\coordinate[right=2cm of gDNAorigin] (gDNAbarcodeStart);
\coordinate[right=2cm of gDNAbarcodeStart] (gDNAbarcodeEnd);
\coordinate[right=2cm of gDNAbarcodeStart] (gDNAcasetteStart);
\coordinate[right=4cm of gDNAcasetteStart] (gDNAcasetteEnd);
\coordinate[right=3cm of gDNAcasetteEnd] (gDNAend);
%
\node[left=0.1cm of gDNAorigin] {5'};
\draw[gDNA] (gDNAorigin) 
  to (gDNAbarcodeStart);
\draw[orange] (gDNAbarcodeStart) decorate[strainBarcode] { to
    node[midway,above](gDNAbarcodeCenter){} 
    (gDNAbarcodeEnd) 
    };
\draw[gDNA] (gDNAbarcodeEnd) 
  to node[very near start,above=1.50cm,text width=3cm,align=center,color=black] 
      (strainLabel) {strain barcode,\\UPtag} 
    (gDNAbarcodeEnd) 
  to (gDNAcasetteStart) 
  to node[at start,sloped,above,rectangle,draw=blue,
    text width=4.3cm,anchor=south west](gDNAkanmx)
      {KanMX cassette} 
    node[midway,above right=1.50cm and 0.5cm,text width=3cm,align=center,color=black] 
      (gDNAlabel) {genomic DNA,\\KO locus} 
    (gDNAcasetteEnd) 
  to (gDNAend);
\node[right=0.1cm of gDNAend] {3'};
\draw[label,bend right=10] (strainLabel) to (gDNAbarcodeCenter);
\draw[label,bend right=10] (gDNAlabel) to (gDNAkanmx);
%%% round1
\coordinate[below=0.3cm of gDNAorigin] (r1extendEnd);
\coordinate[below right=0.3cm and 0.3cm of gDNAbarcodeEnd] (r1primeEnd);
\coordinate[right=1.0cm of r1primeEnd] (r1primeStart);
\coordinate[below right=0.7cm and 0.7cm of r1primeStart] (r1umiStart);
\coordinate[below right=0.7cm and 0.7cm of r1umiStart] (r1adapterStart);
\node[right=0.1cm of r1adapterStart] {5'};
\draw[newDNA] (r1adapterStart) 
  to (r1umiStart);
\draw[purple] (r1umiStart)
  decorate[umiBarcode] { to 
    node[midway,above](r1midUMI){}
    (r1primeStart)
    };
\draw[newDNA] (r1primeStart) to (r1primeEnd);
\draw[extension,prime,newDNA] (r1primeEnd) to (r1extendEnd);
%%% off-target 1
\coordinate[below right=3cm and 5cm of gDNAanchor] (offTarget1origin);
\coordinate[right=5cm of offTarget1origin] (offTarget1End);
%
\node[left=0.1cm of offTarget1origin] {5'};
\draw[newDNA] (offTarget1origin) to 
  node[midway,below right=1.0cm and 1cm,align=left](offTarget1label){off-target priming sites\\are blocked by \\ 3' phosphorylated oligos \\ DGO1588, DGO1589} 
  (offTarget1End);
\coordinate[below left=0.5cm and 2.0cm of offTarget1End] (offTarget1center);
\draw[label] (offTarget1label) to[out=-180,in=-135] (offTarget1center);
\node[right=1.0cm of r1umiStart,align=left] (r1umiLabel){Round1 UMI-containing \\ primer DGO1562};
\draw[label] (r1umiLabel) to[bend right] (r1umiStart);
%%% round2
\coordinate[below left=0.3cm and 1.5cm of offTarget1End] (offTarget1blockStart);
\coordinate[left=2.0cm of offTarget1blockStart] (offTarget1blockEnd);
\node[right=0cm of offTarget1blockStart] {5'};
\draw[dna,red] (offTarget1blockStart) decorate[hybridize] { to (offTarget1blockEnd) };
\draw[dna,red] (offTarget1blockStart) to (offTarget1blockEnd);
\draw[fill=red] (offTarget1blockEnd) circle (0.2);
\node[color=white] at (offTarget1blockEnd) {P};
\coordinate[below=0.2cm of offTarget1center] (r1off1primeEnd);
\coordinate[right=1.0cm of r1off1primeEnd] (r1off1primeStart);
\coordinate[right=0.7cm of r1off1primeStart] (r1off1umiStart);
\coordinate[right=0.7cm of r1off1umiStart] (r1off1adapterStart);
\node[right=0.1cm of r1off1adapterStart] {5'};
\draw[newDNA] (r1off1adapterStart) 
  to (r1off1umiStart);
\draw[purple] (r1off1umiStart)
  decorate[umiBarcode,color=purple] { to 
    node[midway,above](r1off1midUMI){}
    (r1off1primeStart)
    };
\draw[prime,newDNA] (r1off1primeStart) to (r1off1primeEnd);
%%% off-target 2
\coordinate[below right=2.5cm and 5cm of gDNAanchor] (offTarget2origin);
\coordinate[right=5cm of offTarget2origin] (offTarget2End);
%
%\node[left=0.1cm of offTarget2origin] {5'};
%\draw[newDNA] (offTarget2origin) to (offTarget2End);
%\coordinate[below right=0.5cm and 2cm of offTarget2origin](offTarget2center);
%\draw[label] (offTarget1label) to[out=0,in=-135] (offTarget2center);
%%%% round2
%\coordinate[below right=0.3cm and 3.0cm of offTarget2origin] (offTarget2blockStart);
%\coordinate[left=2.0cm of offTarget2blockStart] (offTarget2blockEnd);
%\node[right=0cm of offTarget2blockStart] {5'};
%\draw[dna,red] (offTarget2blockStart) decorate[hybridize] { to (offTarget2blockEnd) };
%\draw[dna,red] (offTarget2blockStart) to (offTarget2blockEnd);
%\draw[fill=red] (offTarget2blockEnd) circle (0.2);
%\node[color=white] at (offTarget2blockEnd) {P};
%\coordinate[below right=0.2cm and 0.5cm of offTarget2center] (r1off2primeEnd);
%\coordinate[right=1.0cm of r1off2primeEnd] (r1off2primeStart);
%\coordinate[right=0.7cm of r1off2primeStart] (r1off2umiStart);
%\coordinate[right=0.7cm of r1off2umiStart] (r1off2adapterStart);
%\node[right=0.1cm of r1off2adapterStart] {5'};
%\draw[dna] (r1off2adapterStart) 
%  to (r1off2umiStart);
%\draw[purple] (r1off2umiStart)
%  decorate[umiBarcode,color=purple] { to 
%    node[midway,above](r1off2midUMI){}
%    (r1off2primeStart)
%    };
%\draw[prime,newDNA] (r1off2primeStart) to (r1off2primeEnd);

%%%
%%%
%%%
%%%
%%%

%%% pree 
\coordinate (r1anchor) at (-10,-13);
%\node[anchor=south west,above right=2cm and 1cm of r1anchor,font=\large] {Round 2};
\node[align=left,anchor=west] at (r1anchor) {
    \textbf{Round 2}. Re-primed with \\outside adapter primers\\
    and another \textcolor{red}{blocker oligo}. \\
    Thermal cycled to melt and anneal.
  };

%%% exo
\coordinate[above right=3cm and 6cm of r1anchor] (digestingPrimerEnd);
\coordinate[right=1cm of digestingPrimerEnd] (digestingPrimerprimeStart);
\coordinate[right=1cm of digestingPrimerprimeStart] (digestingPrimerumiStart);
\coordinate[right=1cm of digestingPrimerumiStart] (digestingPrimeradapterStart);
\node[right=0.1cm of digestingPrimeradapterStart] {5'};
\draw[dna] (digestingPrimeradapterStart) 
  to (digestingPrimerumiStart);
\draw[purple] (digestingPrimerumiStart)
  decorate[umiBarcode] { to 
    node[midway,above](digestingPrimermidUMI){}
    (digestingPrimerprimeStart)};
\draw[dna]    (digestingPrimerprimeStart)
  to (digestingPrimerEnd);
\coordinate[above right=0.3cm and 0.3cm of digestingPrimerEnd] (exoTop);
\coordinate[below right=0.3cm and 0.3cm of digestingPrimerEnd] (exoBottom);
\fill[black] (digestingPrimerEnd) -- (exoTop) 
  arc[radius=0.5,start angle=45,delta angle=280] -- (exoBottom);
\node[color=white,font=\small,left=-0.15cm of digestingPrimerEnd] {exoI};
\node[left=0.8cm of digestingPrimerEnd,align=left] {excess\\primers\\removed};

%%% round2template
\coordinate[right=4cm of r1anchor] (r1extendEnd);
\coordinate[right=3cm of r1extendEnd] (r1strainEnd);
\coordinate[right=2cm of r1strainEnd] (r1strainStart);
\coordinate[right=4cm of r1strainStart] (r1primeStart);
\coordinate[right=2cm of r1primeStart] (r1umiStart);
\coordinate[right=1cm of r1umiStart] (r1adapterStart);
\node[right=0.1cm of r1adapterStart] {5'};
\draw[dna] (r1adapterStart) 
  to (r1umiStart);
\draw[purple] (r1umiStart)
  decorate[umiBarcode] { to 
    node[midway,above](r1midUMI){}
    (r1primeStart)};
\draw[dna]    (r1primeStart)
  to (r1strainStart);
\draw[orange] (r1strainStart)
  decorate[strainBarcode] { to 
    node[midway,above](r1midStrain){}
    (r1strainEnd) };
\draw[dna]    (r1strainEnd) 
  to (r1extendEnd);

%%% round2blocker
\coordinate[above right=0.6 and 1.0cm of r1strainStart] (blockerStart);
\coordinate[above left=0.6 and 1.0cm of r1primeStart] (blockerEnd);
\draw[dna,red] (blockerStart) to (blockerEnd);
\foreach \x in {0.0,0.3,0.6,0.9,1.2,1.5,1.8} \draw (\x,-12.4) to (\x,-12.65);
\draw[fill=red] (blockerEnd) circle (0.2);
\node[color=white] at (blockerEnd) {P};
\coordinate[above left=0.5cm and 0.5cm of blockerStart] (r1badPrimerStart);
\coordinate[right=1cm of r1badPrimerStart] (r1badPrimerEnd);
%\draw[dna,prime,newDNA] (r1badPrimerStart) to (r1badPrimerEnd);
\node[above right=0.25cm and 0.25cm of r1badPrimerEnd,anchor=west,align=left] 
  {3' phosphorylated oligo DGO1576 \\ blocks dimer formation, but strand-displacing};
\node[below right=0.4cm and 2cm of r1badPrimerEnd,anchor=west] {polymerase extends through};

%%
%trans
%%

\coordinate[right=1cm of r1anchor] (thisAnchor) {} ;
\draw[trans,shorten >=2cm,shorten <=4cm] (gDNAcasetteStart) 
  ..controls (-8,-6) and (-9,-6) .. 
  node[pos=0.2,left] (anchorR1toR2) {} (thisAnchor);%(r1badPrimerEnd);
\node[anchor=north,below=0.5cm of anchorR1toR2,align=left] {
  First round extends, then samples \\
  cooled and \textbf{digested with exoI} at 37C\\
  (3'-processive enzyme, dsDNA and \\5' ssDNA not digested)
  };

%%% primers
\coordinate[above left=0.25 and 1.0cm of r1strainEnd] (r1leftPrimerStart);
\coordinate[above left=0.25 and 0.3cm of r1strainEnd] (r1leftPrimerEnd);
\draw[dna,newDNA] (r1leftPrimerStart) to (r1leftPrimerEnd);
\coordinate[right=9cm of r1leftPrimerEnd] (r1leftPrimerExtend);
\draw[extension,prime,newDNA] (r1leftPrimerEnd) to (r1leftPrimerExtend);
\node[left=0.1cm of r1leftPrimerStart] {5'};

\node[above left=0.5cm and 0.5cm of r1leftPrimerStart,anchor=south,align=left] 
  (r2leftLabel) {Round2 forward \\ DGO1567};
\draw[label] (r2leftLabel) to[out=30,in=70] (r1leftPrimerEnd);

%%% r1 half way
\coordinate[below right=2cm and 6cm of r1anchor] (r1bextendEnd);
\coordinate[right=1cm of r1bextendEnd] (r1bstrainEnd);
\coordinate[right=2cm of r1bstrainEnd] (r1bstrainStart);
\coordinate[right=4cm of r1bstrainStart] (r1bprimeStart);
\coordinate[right=2cm of r1bprimeStart] (r1bumiStart);
\coordinate[right=1cm of r1bumiStart] (r1badapterStart);
\node[left=0.1cm of r1bextendEnd] {5'};
\draw[dna] (r1badapterStart) 
  to (r1bumiStart);
\draw[purple] (r1bumiStart)
  decorate[umiBarcode] { to 
    node[midway,above](r1bmidUMI){}
    (r1bprimeStart)};
\draw[dna] (r1bprimeStart)
  to (r1bstrainStart);
\draw[orange] (r1bstrainStart)
  decorate[strainBarcode] { to 
    node[midway,above](r1bmidStrain){}
    (r1bstrainEnd) };
\draw[dna]    (r1bstrainEnd) 
  to (r1bextendEnd);
%
\coordinate[below right=0.25cm and 2cm of r1badapterStart] (r1brightPrimerStart);
\coordinate[below right=0.25cm and 0.3cm of r1bumiStart] (r1brightPrimerEnd);
\draw[dna,newDNA] (r1brightPrimerStart) to (r1brightPrimerEnd);
\coordinate[left=9cm of r1brightPrimerEnd] (r1brightPrimerExtend);
\draw[extension,prime,newDNA] (r1brightPrimerEnd) to (r1brightPrimerExtend);
\node[right=0.1cm of r1brightPrimerStart] {5'};

\node[below=1.0cm of r1brightPrimerStart,anchor=north,align=left] 
  (r2rightLabel) {Round2 reverse \\ DGO1519};
\draw[label] (r2rightLabel) to[out=120,in=-90] (r1brightPrimerEnd);

%
%
%

\draw[trans,shorten <=0.2cm,shorten >=0.2cm] 
  (r1primeStart) to 
    node[midway,anchor=east,align=left] {polymerase extension, \\ cycle to re-anneal}
  (r1bprimeStart);

%
%
%
%
%

%%% pre r2
\coordinate (r2anchor) at (-10,-20);
%\node[anchor=south west,above right=1cm and 1cm of r2anchor,font=\large] {Round 3};
\node[align=left,anchor=west] at (r2anchor) {
    \textbf{Round 3}.
    Reprime with\\ sample-specific \textcolor{olive}{indexing primers}, \\
    PCR cycle to amplify.
  };

\coordinate[right=1cm of r2anchor] (thatAnchor) {};
\draw[trans,shorten <=1cm,shorten >=1cm] (r1brightPrimerExtend) 
  ..controls (-9,-16) ..
  node[near start,below=0cm] (anchorR2toR3) {} (thatAnchor);
\node[anchor=north,below=0.5cm of anchorR2toR3,align=left] {
    PCR cycle to amplify
  };

% round3
\coordinate[right=8cm of r2anchor] (r2extendEnd);
\coordinate[right=1cm of r2extendEnd] (r2strainEnd);
\coordinate[right=2cm of r2strainEnd] (r2strainStart);
\coordinate[right=2cm of r2strainStart] (r2primeStart);
\coordinate[right=2cm of r2primeStart] (r2umiStart);
\coordinate[right=2cm of r2umiStart] (r2adapterStart);
\node[right=0.1cm of r2adapterStart] {5'};
\draw[dna] (r2adapterStart) 
  to (r2umiStart);
\draw[purple] (r2umiStart)
  decorate[umiBarcode] { to 
    node[midway,above](r2midUMI){}
    (r2primeStart)};
\draw[dna]    (r2primeStart)
  to (r2strainStart);
\draw[orange] (r2strainStart)
  decorate[strainBarcode] { to 
    node[midway,above](r2midStrain){}
    (r2strainEnd) };
\draw[dna]    (r2strainEnd) 
  to (r2extendEnd);

%%% primers
\coordinate[above left=0.25 and 2.0cm of r2extendEnd] (r2leftPrimerStart);
\coordinate[right=0.5cm of r2leftPrimerStart] (r2leftPrimerCodeEnd);
\coordinate[right=0.75cm of r2leftPrimerCodeEnd] (r2leftPrimerCodeStart2);
\coordinate[right=0.75cm of r2leftPrimerCodeStart2] (r2leftPrimerCodeStart);
\coordinate[right=1.0cm of r2leftPrimerCodeStart] (r2leftPrimerEnd);
\coordinate[right=8cm of r2leftPrimerEnd] (r2leftExtendEnd);
\draw[dna] (r2leftPrimerStart) to 
  (r2leftPrimerCodeEnd);
\draw[olive]  (r2leftPrimerCodeEnd)
  decorate[sampleBarcode] { to node[midway,above](r2midSample){} (r2leftPrimerCodeStart2) }
  decorate[sampleBarcode] { to (r2leftPrimerCodeStart) };
\draw[dna,newDNA] (r2leftPrimerCodeStart) 
  to (r2leftPrimerEnd);
\draw[dna,extension,prime,newDNA] (r2leftPrimerEnd) to (r2leftExtendEnd);
\node[left=0.1cm of r2leftPrimerStart] {5'};

\node[above right=1cm and 1cm of r2midSample,align=left] (r2sampleLabel) {Sample-barcode \\ primer};
\draw[label] (r2sampleLabel) to[bend right] (r2midSample);

% round3product
\coordinate[below right=2cm and 8cm of r2anchor] (r2dextendEnd);
\coordinate[right=1cm of r2dextendEnd] (r2dstrainEnd);
\coordinate[right=2cm of r2dstrainEnd] (r2dstrainStart);
\coordinate[right=2cm of r2dstrainStart] (r2dprimeStart);
\coordinate[right=2cm of r2dprimeStart] (r2dumiStart);
\coordinate[right=2cm of r2dumiStart] (r2dadapterStart);
\draw[dna] (r2dadapterStart) 
  to (r2dumiStart);
\draw[purple] (r2dumiStart)
  decorate[umiBarcode] { to 
    node[midway,above](r2dmidUMI){}
    (r2dprimeStart)};
\draw[dna]    (r2dprimeStart)
  to (r2dstrainStart);
\draw[orange] (r2dstrainStart)
  decorate[strainBarcode] { to 
    node[midway,above](r2dmidStrain){}
    (r2dstrainEnd) };
\draw[dna]   (r2dstrainEnd) 
  to (r2dextendEnd);
\coordinate[left=2.0cm of r2dextendEnd] (r2dleftPrimerStart);
\coordinate[right=0.5cm of r2dleftPrimerStart] (r2dleftPrimerCodeEnd);
\coordinate[right=0.75cm of r2dleftPrimerCodeEnd] (r2dleftPrimerCodeStart2);
\coordinate[right=0.75cm of r2dleftPrimerCodeStart2] (r2dleftPrimerCodeStart);
\coordinate[right=1cm of r2dleftPrimerCodeStart] (r2dleftPrimerEnd);
\coordinate[right=8cm of r2dleftPrimerEnd] (r2dleftExtendEnd);
\draw[dna] (r2dleftPrimerStart) to (r2dleftPrimerCodeEnd);
\draw[olive]  (r2dleftPrimerCodeEnd)
  decorate[sampleBarcode] { to (r2dleftPrimerCodeStart2) }
  decorate[sampleBarcode] { to (r2dleftPrimerCodeStart) };
\draw[dna] (r2dleftPrimerCodeStart) 
  to (r2dleftPrimerEnd);
\node[left=0.1cm of r2dleftPrimerStart] {5'};

% round3product
\coordinate[below=0.25cm of r2dumiStart] (r2eumiStart);
\coordinate[right=2cm of r2eumiStart] (r2eadapterStart);
\draw[dna,prime,newDNA] (r2eadapterStart) to (r2eumiStart);
\coordinate[left=9cm of r2eumiStart] (primeBackEnd);
\draw[dna,extension,prime,newDNA] (r2eumiStart) to (primeBackEnd);
\node[right=0.1cm of r2eadapterStart] {5'};

\node[below right=0.5cm and 1cm of r2eumiStart,align=left] (r3label1519) {Round3 reverse \\ DGO1519};
\draw[label] (r3label1519) to[bend left] (r2eumiStart);

% round3productproduct
\coordinate[below right=4cm and 8cm of r2anchor] (r2bextendEnd);
\coordinate[right=1cm of r2bextendEnd] (r2bstrainEnd);
\coordinate[right=2cm of r2bstrainEnd] (r2bstrainStart);
\coordinate[right=2cm of r2bstrainStart] (r2bprimeStart);
\coordinate[right=2cm of r2bprimeStart] (r2bumiStart);
\coordinate[right=2cm of r2bumiStart] (r2badapterStart);
\draw[dna] (r2badapterStart) 
  to (r2bumiStart);
\draw[purple] (r2bumiStart)
  decorate[umiBarcode] { to 
    node[midway,above](r2bmidUMI){}
    (r2bprimeStart)};
\draw[dna]    (r2bprimeStart)
  to (r2bstrainStart);
\draw[orange] (r2bstrainStart)
  decorate[strainBarcode] { to 
    node[midway,above](r2bmidStrain){}
    (r2bstrainEnd) };
\draw[dna]   (r2bstrainEnd) 
  to (r2bextendEnd);
\coordinate[left=2.0cm of r2bextendEnd] (r2bleftPrimerStart);
\coordinate[right=0.5cm of r2bleftPrimerStart] (r2bleftPrimerCodeEnd);
\coordinate[right=0.75cm of r2bleftPrimerCodeEnd] (r2bleftPrimerCodeStart2);
\coordinate[right=0.75cm of r2bleftPrimerCodeStart2] (r2bleftPrimerCodeStart);
\coordinate[right=1cm of r2bleftPrimerCodeStart] (r2bleftPrimerEnd);
\coordinate[right=8cm of r2bleftPrimerEnd] (r2bleftExtendEnd);
\draw[dna] (r2bleftPrimerStart) to (r2bleftPrimerCodeEnd);
\draw[olive]  (r2bleftPrimerCodeEnd)
  decorate[sampleBarcode] { to (r2bleftPrimerCodeStart2) }
  decorate[sampleBarcode] { to (r2bleftPrimerCodeStart) };
\draw[dna] (r2bleftPrimerCodeStart) 
  to (r2bleftPrimerEnd);
\node[left=0.1cm of r2bleftPrimerStart] {5'};

% round3productproduct
\coordinate[below right=4.5cm and 8cm of r2anchor] (r2cextendEnd);
\coordinate[right=1cm of r2cextendEnd] (r2cstrainEnd);
\coordinate[right=2cm of r2cstrainEnd] (r2cstrainStart);
\coordinate[right=2cm of r2cstrainStart] (r2cprimeStart);
\coordinate[right=2cm of r2cprimeStart] (r2cumiStart);
\coordinate[right=2cm of r2cumiStart] (r2cadapterStart);
\draw[dna] (r2cadapterStart) 
  to (r2cumiStart);
\draw[purple] (r2cumiStart)
  decorate[umiBarcode] { to 
    node[midway,above](r2cmidUMI){}
    (r2cprimeStart)};
\draw[dna]    (r2cprimeStart)
  to (r2cstrainStart);
\draw[orange] (r2cstrainStart)
  decorate[strainBarcode] { to 
    node[midway,above](r2cmidStrain){}
    (r2cstrainEnd) };
\draw[dna]   (r2cstrainEnd) 
  to (r2cextendEnd);
\coordinate[left=2.0cm of r2cextendEnd] (r2cleftPrimerStart);
\coordinate[right=0.5cm of r2cleftPrimerStart] (r2cleftPrimerCodeEnd);
\coordinate[right=0.75cm of r2cleftPrimerCodeEnd] (r2cleftPrimerCodeStart2);
\coordinate[right=0.75cm of r2cleftPrimerCodeStart2] (r2cleftPrimerCodeStart);
\coordinate[right=1cm of r2cleftPrimerCodeStart] (r2cleftPrimerEnd);
\coordinate[right=8cm of r2cleftPrimerEnd] (r2cleftExtendEnd);
\draw[dna] (r2cleftPrimerStart) to (r2cleftPrimerCodeEnd);
\draw[olive]  (r2cleftPrimerCodeEnd)
  decorate[sampleBarcode] { to (r2cleftPrimerCodeStart2) }
  decorate[sampleBarcode] { to (r2cleftPrimerCodeStart) };
\draw[dna] (r2cleftPrimerCodeStart) 
  to (r2cleftPrimerEnd);
\node[right=0.1cm of r2cleftExtendEnd] {5'};

\draw[trans,shorten <=0.3cm,shorten >=0.3cm] 
  (r2strainEnd) to 
    node[pos=0.4,anchor=west,align=left] {polymerase extension, \\ cycle to re-anneal}
  (r2dstrainEnd);

\draw[trans,shorten <=0.5cm,shorten >=0.3cm] 
  (r2dstrainEnd) to 
    node[midway,anchor=west,align=left] {PCR to amplify}
  (r2bstrainEnd);

\node[below left=1cm and 2cm of r2cleftExtendEnd,align=left] {Library column-purified, and Illumina P5 adapter\\added in subsequent 2-cycle polymerase reaction};

\end{tikzpicture}
  
\pagebreak
