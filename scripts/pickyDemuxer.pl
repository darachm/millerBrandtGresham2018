#/usr/bin/perl -w
use strict;

print "usage:
pickyDemuxer.pl input.fastq indicies to use space seperated
" and die if $#ARGV<1;

my $inputFastq = shift @ARGV; 
$inputFastq =~ s/\.fastq//;
my @indicies;
while ($_ = shift(@ARGV)) {
  push(@indicies,$_);
}

print "working on demuxing it to @indicies\n";

my %outputs;
my %counts;
foreach my $barcode (@indicies) {
  open($outputs{$barcode},">",$inputFastq.".demux_".$barcode.".fastq") or die;
  $counts{$barcode} = 0;
#  print { $outputs{$key} } "\@HD	VN:1.0	SO:unsorted\n";
}
open(UNDE,">",$inputFastq.".demux_undetermined.fastq") or die;
open(CLIP,">",$inputFastq.".demux_all.fastq") or die;
my ($line1,$line2,$line3,$line4,$firstFive);
open FASTQ, "<".$inputFastq.".fastq" or die;
while ($line1 = <FASTQ>) {
  $line2 = <FASTQ>;
  $line3 = <FASTQ>;
  $line4 = <FASTQ>;
  $line2 =~ /^(.....).*/;
  $firstFive = $1;
  $firstFive =~ tr/actg/ACTG/;
  $counts{$firstFive} += 1;
  if (!defined($outputs{$firstFive})) { 
    print UNDE $line1;
    print UNDE $line2;
    print UNDE $line3;
    print UNDE $line4;
  } else {
    print { $outputs{$firstFive} } $line1;
    print { $outputs{$firstFive} } substr($line2,5);
    print { $outputs{$firstFive} } $line3;
    print { $outputs{$firstFive} } substr($line4,5);
  }
  print CLIP $line1;
  print CLIP substr($line2,5);
  print CLIP $line3;
  print CLIP substr($line4,5);
}
close FASTQ;

print "EachBarcode\tExpected?\tTimesObservered\n";
foreach (sort(keys(%outputs))) {
  print $_."\tYep\t".$counts{$_}."\n";
}
foreach (sort(keys(%counts))) {
  next if defined($outputs{$_});
  print $_."\tNope!\t".$counts{$_}."\n";
}

foreach my $barcode (@indicies) {
  close $outputs{$barcode};
}
close UNDE;
close CLIP;
