RDIR= .
all: ReportVanCityTrees.html ReadMe.html

cityTreesDF.txt: dataCleaning.R
	R CMD BATCH ./dataCleaning.R 
	
%.png: dataAggregationPlotting.R cityTreesDF.txt
	R CMD BATCH ./dataAggregationPlotting.R
ReportVanCityTrees.html: %.png
	Rscript -e "knitr::knit2html('ReportVanCityTrees.Rmd', stylesheet='markdown7.css')"; rm -r ReportVanCityTrees.md
	
ReadMe.html: 
	Rscript -e "knitr::knit2html('ReadMe.Rmd', stylesheet='markdown7.css')"; rm -r ReadMe.md