args <- commandArgs(trailingOnly = TRUE)
a <- scan(args[1], what=numeric(), sep=' ', quiet=TRUE)
b <- gsub(".vcf.array",".jpg",args[1])
lab<-c(0.25, 0.5, 0.75)
jpeg(b)
m<-barplot(table(factor(a, seq(0.2,0.8,0.01))),xlab="",xaxt="n",las=1)
axis(1,at=m[c(5, 30, 55)],labels=lab, cex.axis=1)
graphics.off()
