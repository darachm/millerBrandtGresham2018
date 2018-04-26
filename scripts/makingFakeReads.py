
import argparse
parser = argparse.ArgumentParser(description=""+
  "takes in somepaths and prefixes, and a csv of orders for making "+
  "fake data, and make up some fastq files and SampleSheet csvs ")
parser.add_argument("--firstFixed")
parser.add_argument("--secondFixed")
parser.add_argument("--umiEtc")
parser.add_argument("--strainBarcodesFilePath")
parser.add_argument("--sampleBarcodesFilePath")
parser.add_argument("--fakeDataDir")
parser.add_argument("--duprate") #this is how many same strain UMI duplicates you make
parser.add_argument("--samples") #number of samples to do
parser.add_argument("--mutationRate") #avg mutatiosn per thingy
parser.add_argument("--totalReads") #total reads
parser.add_argument("--reps") #how many replicates to make
parser.add_argument("--empirical") #tabdelimited empirical counts distbrutions filename
args = parser.parse_args()
args.reps = int(args.reps)
args.duprate = int(args.duprate)

f = open(args.strainBarcodesFilePath)
strainBarcodes = {}
for strainBarcodeLine in f:
  tmp = strainBarcodeLine.split("\t")
  strainBarcodes[tmp[0]] = [tmp[1],tmp[2].rstrip()]
f.close()

f = open(args.sampleBarcodesFilePath)
sampleBarcodes = {}
for sampleBarcodeLine in f:
  tmp = sampleBarcodeLine.split("\t")
  sampleBarcodes[tmp[0]] = tmp[1].rstrip()
f.close()

f = open(args.empirical)
empirical = {}
empiricalSum = 0
for line in f:
  tmp = line.split("\t")
  empirical[tmp[0]] = tmp[1].rstrip()
  empiricalSum += int(empirical[tmp[0]])
f.close()
for each in empirical.keys():
  empirical[each] = int(empirical[each])/empiricalSum

seed = 1234
import numpy as np 
np.random.seed(seed)
import random
random.seed(seed)

# returns a random atcg
def randBase(oldBase):
  while 1:
    newBase = str(["a","c","t","g"][int(np.floor(np.random.uniform(0,4,1)))])
    if newBase.lower() != oldBase.lower():
      return newBase

# returns a random interspersed UMI, and the P7 sequence
import re

def umiGenerator():
  tmpString = args.umiEtc
  while True:
    tmpString, i = re.subn(pattern="N",repl=randBase("N").upper(),
      count=1,string=tmpString)
    if i == 0:
      break
  return tmpString

# takes a string, mutates those bases based on a lambda
def mutator(x,mutations=0):
  numberToMutate = np.random.poisson(lam=mutations)
  #positionsToMutate = np.floor(np.random.uniform(0,len(x),numberToMutate))
  try:
    positionsToMutate = random.sample(range(0,len(x)),numberToMutate)
    outputString = list(x)
    for eachMutation in positionsToMutate:
      outputString[int(eachMutation)] = randBase(outputString[int(eachMutation)])
    return "".join(outputString)
  except:
    return

# then we cook up some fake data to optimize this on

import os
try:
  os.mkdir(args.fakeDataDir)
except:
  pass

strainSet = sorted(strainBarcodes.keys())
strainProb = []
for i in range(0,len(strainSet)):
  strainProb.append(empirical[strainSet[i]])

for z in range(1,args.reps+1):
  totalReads = int(args.totalReads)
  numberSamples = int(args.samples)
  avgMutations = float(args.mutationRate)
  fakeDataName = "fd_"+str(seed)+"seed_"+str(numberSamples)+"samples_"+str(totalReads)+"reads_"+str(avgMutations)+"mutations_"+str(z)+"reps.base"
  print("Making fakeData "+fakeDataName)
  sampleSet = random.sample(sampleBarcodes.keys(),k=numberSamples)
#  strainSet = random.sample(strainBarcodes.keys(),k=len(strainBarcodes.keys()))
  o = open(args.fakeDataDir+"/"+fakeDataName+".SampleSheet.csv",'w')
  o.write("Sample,SampleBarcodeUsed\n")
  for z in range(len(sampleSet)):
    o.write(sampleSet[z]+","+sampleBarcodes[sampleSet[z]]+"\n")
  o.close()
  o = open(args.fakeDataDir+"/"+fakeDataName+".fastq",'w')
  i = 1
  while 1:
    thisStrain = np.random.choice(a=strainSet,size=1,replace=False,p=strainProb)[0]
    thisStrainBarcode = strainBarcodes[thisStrain][0]
    if thisStrain == "":
      print("no uptag!!!!")
      next
    thisSampleBarcode = sampleBarcodes[random.sample(sampleSet,1)[0]]
    r = open(args.fakeDataDir+"/"+fakeDataName+".real_"+
      thisSampleBarcode+".dedup.obs",'a')
    d = open(args.fakeDataDir+"/"+fakeDataName+".real_"+
      thisSampleBarcode+".obs",'a')
    platonicRead = (
      thisSampleBarcode+
      args.firstFixed+
      thisStrainBarcode+
      args.secondFixed+
      umiGenerator())
    r.write(thisStrain+"\n")
    for j in range(1,int(np.random.exponential(scale=args.duprate))):
      if i > totalReads:
        break
      o.write("@"+thisSampleBarcode+":"+thisStrain+":"+thisStrainBarcode+":"+"read"+str(i)+"\n")
      o.write(mutator(platonicRead[0:75],avgMutations)+"\n")
      o.write("+\n")
      o.write("G"*75+"\n")
      d.write(thisStrain+"\n")
      i += 1
    r.close()
    if i > totalReads:
      break
    if 0==(i % 10000):
      print(str(i)+" done")
  o.close()
  

