#!/usr/bin/bash

for file in $@; do
	basename=$(echo $file | sed 's/.dv//')
	currdir=$(pwd)
	newdir=$currdir"/"
	echo "Saving basename $file in $newdir"
	cmd='
setBatchMode(true);
run("Bio-Formats","open='$currdir'/'$file'");
imageTitle=getTitle();
run("Split Channels");
selectWindow("C1-"+imageTitle); 
run("Animation Options...", "speed=10 first=1 last=40");
run("Animated Gif... ", "save='$newdir'gifd/'$basename'.c1.gif");
run("Z Project...","projection=[Max Intensity]");
run("16-bit");
saveAs("PNG","'$newdir'dvflatd/'$basename'.bc1max.png");
selectWindow("C2-"+imageTitle); 
run("Z Project...","start=19 stop=21 projection=[Sum Slices]");
run("16-bit");
saveAs("PNG","'$newdir'dvflatd/'$basename'.ac2sum.png");

'
	echo -n $cmd > ~/.imagej/macros/tmpfile
	imagej -b tmpfile
done;



# close();
