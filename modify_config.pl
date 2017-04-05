#!/usr/bin/env perl

use Getopt::Long;

my $filename=STDIN;
my $position=1;
my $text="";
my $output=STDOUT;

GetOptions(
  "filename=s"=>\$filename,
  "position=i"=>\$position, #line at which to insert. first line is 1.
  "text=s"=>\$text,
  "output=s"=>\$output
);

my $counter=0;
open FHIN,"<$filename" or die "Could not open input file '$filename'.\n";
open FHOUT,">$output" or die "Could not open output file '$output'.\n";

while(<FHIN>){
  ++$counter;
  print FHOUT "$text\n" if($counter==$position) ;
  print FHOUT $_;
}

close FHIN;
close FHOUT;
