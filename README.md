# VCFvariance.pl

VCFvariance.pl is a script used to calculate the variance of allele balance for SNPs in a VCF file, called with FreeBayes (tested on v1.2).

Variance of allele balance can be used to determine if the variants in a VCF are consistent with diploidy. The expectation for a diploid is that reads will sample two haplotypes equally, meaning half the reads covering SNPs will represent the first genotype. The other half of the reads will cover the second genotype. This means that the allele balance for diploids should be approximately 0.5 and there should be low variance of allele balance within the sample.

Genomes inconsistent with diploidy (polyplods, heterokaryons, large scale copy number variants) will exhibit a larger variance of allele balance since they have more than two haplotypes. For example, in a triploid allele balance would be expected to be 0.33/0.66. This will increase the varaince of allele balance within the sample allowing detection.

This method is sensitive down to 10x whole genome sequencing coverage.

## Download
`git clone git@github.com:kfletcher88/VCFvariance.git`

## Usage
```
perl VCFvariance.pl -h
        Please provide:
                -i input VCF
                -c Coverage of input sample.
                Coverage may also be provided in the filename,
                preceeded by an underscore, followed by an x e.g:

                        SampleID_10x.vcf

        Optional flags include:
        -p Percent Haploid Flag (default 80). # This can be set to zero if haploidy is not possible.
                Percentage of SNPS required to pass allele balance filter
                Reduce if reads and reference are a larger genetic distance apart
                with multiple fixed differences.
                Cautious interpretation if reduced for low coverage sequencing
       -d Deviation from defined coverage allowed (default 0.4).
                Increase deviation from coverage to increase number of SNPs surveyed.
                This may be necessary if less than 1000 SNPs are detected.
                Increasing deviation tends to bring variance closer to the mean
        -B Print the allele balance bar chart for the input VCF.
                Recommened only when coverage exceeds 50x
```

## Results
VCFvariance.pl will output a tab-delimited text file describing:
1. The input file name
2. Use specified coverage
3. User specified deviation from coverage (default = 0.4)
4. User specified percent of polymorphisms heterozyous (default = 80) to filter haploids.
5. Number of high quality polymorphisms identified
6. Percent of high quality polymorphisms inferred to be heterozygous.
7. Variance of allele balance for polymorphisms.

An example:
```
Input VCF       Coverage        -d      -p      HQ Variants Analyzed    HQ Hets Variance
SF5_164x.vcf    164     0.4     80      297282  98.7    0.00788016117413868
```

## Plotting allele balance barcharts
Option `-B` allows users to plot allele balance bar charts. This is only reccomended when 50x or greater sequencing coverage has been obtained.\
An example bar chart:
![Exampe allele balance bar chart](./images/SF5_164x.jpg)
