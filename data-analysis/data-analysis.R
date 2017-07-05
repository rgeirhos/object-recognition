###################################################################
#   Data analysis script for object-recognition experiments   
#   -------------------------------------------------------
#   Author:   Robert Geirhos
#   Based on: R version 3.2.3
###################################################################

DATAPATH = "../raw-data/"
source("data-analysis-helper.R")

###################################################################
#               loading & preprocessing experimental data
###################################################################

# preprocessing color data
colordat = get.expt.data("colour-experiment")
colordat$condition = ifelse(colordat$condition=="cr", "color", "grayscale")
colordat$condition = as.factor(colordat$condition)

# preprocessing contrast data
contrastdat = get.expt.data("contrast-experiment")
contrastdat$condition = as.character(contrastdat$condition)
contrastdat$condition = lapply(contrastdat$condition, function(y){substring(y, 2)})
contrastdat$condition = as.character(as.numeric(contrastdat$condition)) # '05' -> '5' etc

# preprocessing contrast-png data
contrastpngdat = get.expt.data("contrast-png-experiment")
contrastpngdat$condition = as.character(contrastpngdat$condition)
contrastpngdat$condition = lapply(contrastpngdat$condition, function(y){substring(y, 2)})
contrastpngdat$condition = as.character(as.numeric(contrastpngdat$condition)) # '05' -> '5' etc

# preprocessing noise-experiment
noisedat = get.expt.data("noise-experiment")
noisedat$condition = as.character(noisedat$condition)
noisedat$condition = lapply(noisedat$condition, function(y){if(y=="0"){return("0.0")}else{return(substring(y, 2))}})
noisedat$condition = as.character(noisedat$condition)

# preprocessing eidolon-experiment
eidolondat = get.expt.data("eidolon-experiment")
e0dat = get.eidolon.dat.preprocessed(eidolondat, 0)   # coherence = 0.0
e3dat = get.eidolon.dat.preprocessed(eidolondat, 3)   # coherence = 0.3
e10dat = get.eidolon.dat.preprocessed(eidolondat, 10) # coherence = 1.0



###################################################################
#               confusion matrix plotting
###################################################################

# Fig. 5a in the paper draft
confusion.matrix(colordat[colordat$condition=="color" & colordat$is.human==TRUE, ],
                 main="Confusion matrix: color-experiment, color-condition, human observers")

###################################################################
#               confusion difference matrix plotting
###################################################################

# Fig. 5b in the paper draft
difference.matrix(colordat[colordat$condition=="color" & colordat$is.human==TRUE, ],
                  colordat[colordat$condition=="color" & colordat$subj=="vgg", ],
                  main = "Confusion difference matrix: color-experiment, color-condition, human vs. VGG-16",
                  divide.alpha.by = 16.0*17.0, # 16 columns * 17 rows
                  binomial = TRUE)

###################################################################
#               print accuracies to .txt file
###################################################################

accuracy.printing.path = "../raw-accuracies/"
print.accuracies.to.file(colordat, path=accuracy.printing.path)
print.accuracies.to.file(contrastdat, path=accuracy.printing.path)
print.accuracies.to.file(contrastpngdat, path=accuracy.printing.path)
print.accuracies.to.file(noisedat, path=accuracy.printing.path)
print.accuracies.to.file(eidolondat, path=accuracy.printing.path)
