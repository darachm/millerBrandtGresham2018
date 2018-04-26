#!/usr/bin/bash

for file in $@; do
	basename=$(echo $file | sed 's/.dv//')
	currdir=$(pwd)
	newdir=$currdir""
	echo "Saving basename $file in $newdir"
	cmd='
run("Bio-Formats","open='$currdir'/'$file' color_mode=Grayscale");
run("Z Project...","start=5 stop=25 projection=[Max Intensity]");
run("8-bit");
setMinAndMax(0, 200);
run("Scale Bar...", "width=2 height=5 font=15 color=White background=None location=[Lower Right] bold label");
saveAs("PNG","'$newdir'/'$basename'_max.png"); 
close();
'
    echo $cmd
	echo -n $cmd > ~/.imagej/macros/tmpfile.ijm
    /usr/bin/imagej -b ~/.imagej/macros/tmpfile.ijm
done;

