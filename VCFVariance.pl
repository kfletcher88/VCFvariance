#!/usr/bin/perl

################################################################################
#	A script to determine the variance of allele frequencies presented in a VCF file. In addition it prints the number of sites that were used in the analysis.
#	The script was tested on a VCF generated by FreeBayes v1.2
#	
#	Developed by Kyle Fletcher
#	UC Davis Genome Center
#	kfletcher[at]ucdavis.edu
################################################################################

################################################################################
#	Current issues with the script
################################################################################

use strict;
use warnings;
use Statistics::Descriptive;
use Getopt::Std;
use vars qw($opt_h $opt_i $opt_c $opt_p $opt_d $opt_B);
getopts('i:c:p:d:hB');
use File::Basename;


if ( (defined($opt_h)) || !(defined($opt_i)) ) {
	print STDERR "\tPlease provide:\n\t\t-i input VCF\n\t\t-c Coverage of input sample.\n\t\tCoverage may also be provided in the filename, \n\t\tpreceeded by an underscore, followed by an x e.g:\n\n\t\t\tSampleID_10x.vcf\n\n";
	print STDERR "\tOptional flags include:\n\t-p Percent Haploid Flag (default 80). \n\t\tPercentage of SNPS required to pass allele balance filter\n\n";
	print STDERR "\t-d Deviation from defined coverage allowed (default 0.4).\n\t\tIncrease deviation from coverage to increase number of SNPs surveyed. \n\n";
	print STDERR "\t-B Print the allele balance bar chart for the input VCF.\n\t\tRecommened only when coverage exceeds 50x\n\n";
	exit;
}
my $input = $opt_i if $opt_i;
my $output = (basename $opt_i).'.array';
##Switch lines below if you want to set coverage on the command line. Second line will extract the coverage defined in the input file header.
#my $cov = $opt_c if $opt_c;
my ($cov) = $opt_c || ($input =~ /_0?([1-9][0-9]*)x/);
#Enable user defined deviation from coverage. Useful if too few SNPs are measured with defaults.
#Enable user defined haploid flag.
my $Hflag = $opt_p || "80";
my $Cdev = $opt_d || "0.4";
my $lbo = sprintf "%.2f",1-$Cdev;
my $ubo = sprintf "%.2f",1+$Cdev;

my $LogFile = 'Variance.log';
if (-e $LogFile) {
	print STDERR "Previous results detected, will append to $LogFile\n";
} else {
	system("echo 'Input VCF\tCoverage\t-d\t-p\tHQ Variants Analyzed\t% HQ Hets\tVariance' >> Variance.log");
}

open(LOG, ">> Variance.log");

#open(VCF, "> VCF.check");
#Check all required parameters are described. Die if not and print usage statement. If help requested, print help.

my ($MQA,$MQR,$AB,$DP,$AF,$NA,$SQ,$MQ,$Perc) = 0;
my @array = ();
my @total = ();
open(IN, "grep -v '#' $input |") or die"";
while(<IN>){
	chomp;
#	FreeBayes v1.2
	if(/[A|T|C|G]+\s+[A|C|T|G]+\s+(\d+\.?\d*)\s+\.\s+.*DP=(\d+).*MQM=(\d+.?\d*);MQMR=(\d+.?\d*);.*NUMALT=1.*TYPE=snp.*:(\d+),(\d+).*,.*,/){
		$MQ = sprintf "%f",$1;
		$DP = sprintf "%f",$2;
		$MQA = sprintf "%f",$3;
		$MQR = sprintf "%f",$4;
		$AF = sprintf "%.2f",$5/($5+$6);
		}
	else {
		$DP = 0;
		$AF = 0
		}
	#Compare values from the line with the filtering parameters.
	next if($DP < $cov * $lbo);
	next if($DP > $cov * $ubo);
	next if($MQA < 30);
	next if($MQR < 30);
	next if($MQ < 30);
	push(@total, $AF);
        next if($AF < 0.20);
	next if($AF > 0.80);
	#Add to array
	push(@array, $AF);
#	print VCF "$_\t$AF\n";
	}
#Generate stats for printing
my $stat = Statistics::Descriptive::Full->new();
$stat->add_data(\@array);
my $variance = $stat->variance();
my $size = @array;
my $RA = @total;
$Perc = sprintf "%.3f",$size/$RA;
#Print those stats
$Perc = ($Perc*100);
if($Perc <= $Hflag){
	print LOG "$input\t$cov\t$Cdev\t$Hflag\t$size\t$Perc\tPossible_Haploid\n";
	print STDERR "\t${Perc}% of SNPs observed from $input are biallelic. \n\tThis suggests $input may be haploid\n";
	exit;
	}
print LOG "$input\t$cov\t$Cdev\t$Hflag\t$size\t$Perc\t$variance\n";
close IN;
#Print allele balance bar chart if requested
if ( (defined($opt_B)) ) {
print STDERR "Printing Allele balance bar chart for $input\n";
open(OUT, "> $output") or die"";
print OUT "@array\n";
#Close input
close OUT;
#close LOG;
my $dir = dirname $0;
system("Rscript $dir/R/Ploidy_v2.R $output");
system("rm $output");
exit;
} else {
exit;
}
