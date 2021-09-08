# VCFvariance


```
perl VCFvariance.pl -h
        Please provide:
                -i input VCF
                -c Coverage of input sample.
                Coverage may also be provided in the filename,
                preceeded by an underscore, followed by an x e.g:

                        SampleID_10x.vcf

        Optional flags include:
        -p Percent Haploid Flag (default 80).
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
