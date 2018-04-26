
import argparse
parser = argparse.ArgumentParser(description=""+
  "takes in somepaths and prefixes, and spits out a reference "+
  "fasta with a seq for each mutant expectation, this is for bowtie "+
  "alignment")
parser.add_argument("--ampliconPrefix")
parser.add_argument("--ampliconSuffix")
parser.add_argument("--strainBarcodesFilePath")
parser.add_argument("--referenceFilename")
args = parser.parse_args()

import os
try:
  os.mkdir(os.path.dirname(args.referenceFilename))
except:
  pass

f = open(args.strainBarcodesFilePath)
strainBarcodes = {}
for strainBarcodeLine in f:
  tmp = strainBarcodeLine.split("\t")
  strainBarcodes[tmp[0]] = [tmp[1],tmp[2]]
f.close()

f = open(args.referenceFilename,'w')
for strainName in sorted(strainBarcodes.keys()):
  f.write(">"+strainName+"\n")
  f.write( (args.ampliconPrefix+
            strainBarcodes[strainName][0]+
            args.ampliconSuffix)[0:30]+"\n")
f.close()



