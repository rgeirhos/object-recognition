###################################################################
#   Data analysis helper script for object-recognition experiments
#   All important functions for data analysis are collected
#   here (to be used for plotting, analysis, and in the
#   data-analysis.R script)
#   -------------------------------------------------------
#   Author:   Robert Geirhos
#   Based on: R version 3.2.3
###################################################################

library(ggplot2)

###################################################################
#               some general settings
###################################################################

NETWORKS = sort(c("alexnet", "googlenet", "vgg"))
NUM.OVERALL.PARTICIPANTS = 42 # arbitrary but large enough

# assign colors according to University of Tuebingen color scheme 
alexnet.100 = rgb(125, 165, 75, maxColorValue =  255)
alexnet.80 = rgb(151, 183, 111, maxColorValue =  255)
alexnet.60 = rgb(177, 201,  147, maxColorValue =  255)

googlenet.100 = rgb(130, 185, 160, maxColorValue =  255)
googlenet.80 = rgb(160, 199, 179, maxColorValue =  255)
googlenet.60 = rgb(186, 213, 198, maxColorValue =  255)

vgg.100 = rgb(50, 110, 30, maxColorValue =  255)
vgg.80 = rgb(97, 132, 71, maxColorValue = 255)
vgg.70 = rgb(117, 144, 89, maxColorValue =  255)
vgg.60 = rgb(144, 159, 110, maxColorValue = 255)
vgg.40 = rgb(177, 188, 156, maxColorValue =  255)

human.100 = rgb(165, 30, 55, maxColorValue = 255)
human.80 = rgb(180, 77, 80, maxColorValue = 255)
human.70 = rgb(188, 98, 97, maxColorValue = 255)
human.60 = rgb(197, 121, 116, maxColorValue = 255)
human.40 = rgb(216, 166, 159, maxColorValue = 255)
human.20 = rgb(235, 210, 205, maxColorValue = 255)

use.blue.color.scheme = TRUE
if(use.blue.color.scheme) {
  vgg.100 = rgb(0, 105, 170, maxColorValue = 255)
  alexnet.100 = rgb(65, 90, 140, maxColorValue = 255)
  googlenet.100 = rgb(80, 170, 200, maxColorValue = 255)
}

human.cols = c("1" = human.60, "2" = human.80, "3" = human.100)
alexnet.cols   = c("-1" = alexnet.60, "-2" = alexnet.80, "-3" = alexnet.100)
googlenet.cols   = c("-1" = googlenet.60, "-2" = googlenet.80, "-3" = googlenet.100)
vgg.cols   = c("-1" = vgg.60, "-2" = vgg.80, "-3" = vgg.100)

get.equally.spaced.colors = function(r, g, b, n=7) {
  # return n equally spaced colors, with the middle one
  # being grey (127, 127, 127)
  
  cols = list()
  
  rs = seq(from=r, to=255-r, length.out=n)
  gs = seq(from=g, to=255-g, length.out=n)
  bs = seq(from=b, to=255-b, length.out=n)
  counter = 1
  for(i in 1:n) {
    cols[counter] = rgb(rs[counter], gs[counter], bs[counter], maxColorValue = 255)
    counter = counter + 1 
  }
  
  return(cols)
}

# get blue and yellow colors used for confusion difference plotting
confdiff.cols.all = get.equally.spaced.colors(0, 0, 125)
confdiff.human.cols   = c("1" = confdiff.cols.all[3], "2" = confdiff.cols.all[2], "3" = confdiff.cols.all[1])
confdiff.net.cols   = c("-1" = confdiff.cols.all[5], "-2" = confdiff.cols.all[6], "-3" = confdiff.cols.all[7])

cols = list()
counter = 1
for(i in c(-3:3)) {
  val = counter * 255 / 7
  cols[counter] = rgb(val, val, val, maxColorValue = 255)
  counter = counter +1
}
rm(val)
rm(counter)
rm(i)


HUMAN.COLS = c(human.100, human.80, human.60, human.40, human.20)
DNN.RANGE.LWD = 2
LINES.LWD = 2.5
POINTS.CEX.VAL = 2.5

alexnet = list(name="AlexNet",
               color=alexnet.100,
               pch=23,
               data.name="alexnet")
googlenet = list(name="GoogLeNet",
                 color=googlenet.100,
                 pch=22,
                 data.name="googlenet")
vgg = list(name="VGG-16",
           color=vgg.100,
           pch=24,
           data.name="vgg")
NETWORK.DATA = list()
NETWORK.DATA[[1]] = alexnet
NETWORK.DATA[[2]] = googlenet
NETWORK.DATA[[3]] = vgg

PARTICIPANTS = list()
for(i in 1:NUM.OVERALL.PARTICIPANTS) {
  n = paste("subject-", ifelse(i<10, "0", ""), i, sep="")
  PARTICIPANTS[[i]] = list(name=n,
                           color=human.100,
                           pch=1,
                           data.name=n)
}
rm(n)
rm(i)

human.avg = list(name="participants (avg.)",
                 color=human.100,
                 pch=1,
                 data.name="not defined")

get.all.subjects = function(dat, avg.human.data) {
  # Return all subjects, including networks.
  
  subjects = NETWORK.DATA 
  i = length(NETWORK.DATA) + 1
  
  if(avg.human.data & any(! unique(dat$subj) %in% NETWORKS)) {
    subjects[[i]] = human.avg
  } else {
    counter = 1
    for(p in PARTICIPANTS) {
      if(p$data.name %in% unique(dat$subj)) {
        subjects[[i]] = p
        subjects[[i]]$color = HUMAN.COLS[i - length(NETWORK.DATA)]
        i = i+1
        counter = counter+1
      }
    }
  }
  return(subjects) 
}

###################################################################
#               confusion plotting
###################################################################

confusion.matrix = function(dat, subject=NULL, main=NULL, plot.scale=TRUE,
                            plot.x.y.labels=TRUE) {
  #Plot confusion matrix either for all or for a specific subject
  
  confusion = get.confusion(dat, subject)
  return(plot.confusion(confusion, unique(dat$experiment.name), subject,
                        main=main, plot.scale=plot.scale,
                        plot.x.y.labels = plot.x.y.labels))
}

get.confusion = function(dat, subject=NULL,
                         net.dat=NULL, human.dat=NULL) {
  # Sure you want to get confused? ;)
  # Return all data necessary to plot confusion matrix.
  
  if(is.null(subject)) {
    d = data.frame(dat$category,
                   dat$object_response)
  } else {
    d = data.frame(dat[dat$subj==subject, ]$category,
                   dat[dat$subj==subject, ]$object_response)
  }
  
  names(d) = c("category", "object_response") 
  
  category = as.data.frame(table(d$category))
  names(category) = c("category","CategoryFreq")
  
  confusion = as.data.frame(table(d$category, d$object_response))
  names(confusion) = c("category", "object_response", "Freq")
  
  confusion = merge(confusion, category, by=c("category"))
  confusion$Percent = confusion$Freq/confusion$CategoryFreq*100
  
  # make sure the order is correct, with 'na' in the end
  for(f in rev(c("airplane", "bear", "bicycle", "bird", "boat", "bottle",
                 "car", "cat", "chair", "clock", "dog", "elephant",
                 "keyboard", "knife", "oven", "truck", "na"))) {
    confusion$object_response <- relevel(confusion$object_response, f)
  }
  
  return(confusion)
}

plot.confusion = function(confusion, 
                          experiment.name,
                          subject=NULL,
                          is.difference.plot=FALSE,
                          main=NULL,
                          plot.accuracies=TRUE,
                          plot.x.y.labels=TRUE,
                          plot.scale = TRUE,
                          network.name=NULL) {
  # Plot confusion matrix
  
  if(is.difference.plot) {
    g = geom_tile(aes(x=category, y=object_response, fill=z),
                  data=confusion, color="black", size=0.1)
  } else {
    g = geom_tile(aes(x=category, y=object_response, fill=Percent),
                  data=confusion, color="black", size=0.1)
  }
  
  tile <- ggplot() + g +
    labs(x="presented category",y="response") + 
    if(is.null(main)) {
      ggtitle(paste("Confusion matrix", experiment.name)) 
    } else {
      ggtitle(main)
    }
  
  # print accuracy; fill gradient
  if(plot.accuracies) {
    tile = tile + 
      geom_text(aes(x=category, y=object_response, label=sprintf("%.1f", Percent)),
                data=confusion, size=5, colour="black")
  }
  
  tile = tile +
    if((!is.null(confusion$z)) & !is.difference.plot) {
      if(is.null(network.name)) {
        stop("no network name, but confusion$z exists -> which color to use?")
      }
      
      net.cols = NULL
      if(network.name == "vgg") {
        net.cols = vgg.cols
      } else if (network.name == "alexnet") {
        net.cols = alexnet.cols
      } else if (network.name == "googlenet") {
        net.cols = googlenet.cols
      }
      scale_fill_manual(values = c("0" = rgb(230, 230, 230, maxColorValue = 255),
                                   human.cols, net.cols))
    } else if(is.difference.plot) {
      print("plotting difference matrix")
      scale_fill_manual(values = c("0" = rgb(127, 127, 127, maxColorValue = 255),
                                   confdiff.human.cols, confdiff.net.cols), guide=FALSE)
    } else {
      if(plot.scale) {
        scale_fill_gradient(low=rgb(250, 250, 250, maxColorValue = 255),
                            high=human.100)
      } else {
        scale_fill_gradient(low="grey", high=human.100, guide=FALSE)
      }
    }
  
  tile = tile + 
    geom_tile(aes(x=category, y=object_response),
              data=subset(confusion, as.character(category)==as.character(object_response)),
              color="black",size=0.3, fill="black", alpha=0) 
  if(! plot.x.y.labels) {
    tile = tile +
      theme(axis.title.x=element_blank(),
            axis.text.x=element_blank(),
            axis.ticks.x=element_blank(),
            axis.title.y=element_blank(),
            axis.text.y=element_blank(),
            axis.ticks.y=element_blank())
  }
  return(tile)
}

difference.matrix = function(dat1, dat2.network,
                             plot.accuracies = TRUE,
                             plot.x.y.labels = TRUE,
                             plot.scale = TRUE,
                             main=NULL,
                             binomial=FALSE,
                             divide.alpha.by=16.0*17.0*9.0) {
  # Plot the difference of two confusion matrices
  
  if(length(unique(dat2.network$subj)) != 1) {
    warning("more than one network found in dat2.network:")
    print(unique(dat2.network$subj))
    network.name = unique(dat2.network$subj)
  } else {
    network.name = "GROUP"
  }
  
  
  if(is.null(main)) {
    main=paste("Confusion matrix ", unique(dat1$experiment.name), sep="")
  }
  
  confusion1 = get.confusion(dat1)
  confusion2 = get.confusion(dat2.network)
  confusion.difference = confusion1
  confusion.difference$Percent = confusion1$Percent - confusion2$Percent
  
  if(binomial) {
    confusion.difference = get.z.for.binomial(confusion.difference,
                                              confusion1, confusion2,
                                              divide.alpha.by)
  } else {
    stop("not implemented.")
  }
  
  result = plot.confusion(confusion.difference,
                          experiment.name = unique(dat1$experiment.name),
                          is.difference.plot = TRUE,
                          main=main,
                          plot.accuracies = plot.accuracies,
                          plot.x.y.labels = plot.x.y.labels,
                          plot.scale = plot.scale,
                          network.name = network.name)
  return(result)
}

###################################################################
#               loading & preprocessing experimental data
###################################################################

get.expt.data = function(expt.name) {
  # Read data and return in the correct format
  
  if(!exists("DATAPATH")) {
    stop("you need to define the DATAPATH variable")
  }
  
  dat = NULL
  expt.path = paste(DATAPATH, expt.name, sep="")
  files = list.files(expt.path)
  
  if(length(files) < 1) {
    warning(paste("No data for expt", expt.name, "found! Check DATAPATH."))
  }
  
  for (i in 1:length(files)) {
    if(!endsWith(files[i], ".csv")) {
      warning("File without .csv ending found (and ignored)!")
    } else {
      dat = rbind(dat, read.csv(paste(expt.path, files[i], sep="/")))
    }
  }
  dat$imagename = as.character(dat$imagename)
  dat$is.correct = as.character(dat$object_response) == as.character(dat$category)
  dat$is.human = ifelse(grepl("subject", dat$subj), TRUE, FALSE)
  
  return(data.frame(experiment.name = expt.name, dat))
}

get.eidolon.dat.preprocessed = function(dat, separating.condition) {
  # Eidolon data is a special case because condition is 3-dimensional
  # (compared to other 1-dimensional experiments). Therefore this function
  # can be used to extract the whole data for the middle condition.
  # Parameter separating.condition is one of 0, ..., 10 .
  
  dat.new = dat[grepl(paste("-", as.character(separating.condition), "-", sep=""), dat$condition), ]
  dat.new$condition = as.character(dat.new$condition)
  dat.new$condition = lapply(dat.new$condition, function(y){strsplit(y, "-")[[1]][1]})
  dat.new$condition = as.numeric(dat.new$condition)
  return(dat.new)
}


###################################################################
#               helper functions
###################################################################

endsWith <- function(argument, match, ignore.case = TRUE) {
  # Return: does 'argument' end with 'match'?
  # Code adapted from:
  # http://stackoverflow.com/questions/31467732/does-r-have-function-startswith-or-endswith-like-python
  
  if(ignore.case) {
    argument = tolower(argument)
    match = tolower(match)
  }
  n = nchar(match)
  
  length = nchar(argument)
  
  return(substr(argument, pmax(1, length - n + 1), length) == match)
}


get.z.for.binomial = function(conf, conf1, conf2,
                              divide.alpha.by) {
  # Assign values within [-3, 3] indicating the 'significance color'
  # for a confusion difference plot (here, these color values are called z)
  #
  # Parameters:
  # - conf            -> confusion difference
  # - conf1           -> human confusion data
  # - conf2           -> network confusion data
  # - divide.alpha.by -> if > 1.0, Bonferroni correction will be applied
  #
  # z values:
  # -3 to -1 -> difference significant for alpha = 0.001, 0.01, 0.05; network more frequently
  # 0        -> no or no significant difference
  # 3 to 1   -> difference significant for alpha = 0.001, 0.01, 0.05; humans more frequently
  # These alpha values (0.001, 0.01, 0.05) are subject to a Bonferroni
  # correction if divide.alpha.by is assigned a value larger than 1.0
  
  conf$z = "0" # default value
  
  conf1$Freq = as.numeric(conf1$Freq)
  conf1$CategoryFreq = as.numeric(conf1$CategoryFreq)
  conf2$Freq = as.numeric(conf2$Freq)
  conf2$CategoryFreq = as.numeric(conf2$CategoryFreq)
  
  for(i in 1:nrow(conf1)) {
    if(conf1[i, ]$category != conf2[i, ]$category) {
      stop("category mismatch")
    }
    tmp = 0
    weight = 3
    for(alpha in sort(c(0.001, 0.01, 0.05), decreasing = F)) {
      val = is.in.CI(conf2[i, ]$Freq, conf2[i, ]$CategoryFreq,
                     conf1[i, ]$Freq, conf1[i, ]$CategoryFreq,
                     conf.level = 1.0-alpha/divide.alpha.by)
      if(abs(weight*val) > abs(tmp)) {
        tmp = weight*val
        break # shortcut: speed up computation and begin with most significant
      }
      weight = weight - 1
    }
    conf[i, ]$z = as.character(tmp)
  }
  return(conf)
}


is.in.CI = function(a.num.successes, a.total,
                    b.num.successes, b.total,
                    conf.level,
                    default.for.p.equals.0 = 0.001) {
  # In this analysis, is it used as follows:
  # a: network (in general, reference)
  # b: human
  #
  # Return value will be 1 if b.num.successes / b.total larger than 
  # the CI's upper bound, -1 if it is smaller, and 0 otherwise
  # (i.e. if it is contained in the CI, the return value will be 0).
  
  p.a = a.num.successes / a.total
  p.b = b.num.successes / b.total
  
  p = ifelse(p.a != 0, ifelse(p.a != 1, p.a, 1-default.for.p.equals.0), default.for.p.equals.0)
  
  p.value = binom.test(b.num.successes, b.total,
                       p = p,
                       alternative = "two.sided",
                       conf.level = conf.level)$p.value
  
  if(p.value < (1.0 - conf.level)) {
    if(p.a > p.b) {
      return(-1)
    } else if (p.b > p.a) {
      return(1)
    } else {
      stop("this shouldn't occur!")
    }
  } else {
    return(0)
  }
}

get.accuracy = function(dat) {
  # Return data.frame with x and y for condition and accuracy.
  
  tab = table(dat$is.correct, by=dat$condition)
  false.index = 1
  true.index = 2
  acc = tab[true.index, ] / (tab[false.index, ]+tab[true.index, ])
  d = as.data.frame(acc)
  
  if(length(colnames(tab)) != length(unique(dat$condition))) {
    stop("Error in get.accuracy: length mismatch.")
  }
  
  #enforce numeric ordering instead of alphabetic (otherwise problem: 100 before 20)
  if(!is.factor(dat$condition)) {
    #condition is numeric
    d$order = row.names(d)
    d$order = as.numeric(d$order)
    d = d[with(d, order(d$order)), ]
    d$order = NULL
    e = data.frame(x = as.numeric(row.names(d)), y=100*d[ , ])
  } else {
    #condition is non-numeric
    e = data.frame(x = row.names(d), y=100*d[ , ])
  }
  return(e)
}


print.accuracies.to.file = function(dat, path="./", filename=paste(path, unique(dat$experiment.name),
                                                        "_accuracies.txt", sep="")) {
  # print a .txt file with a table of all accuracies for a certain experiment
  # (split by experimental condition and subject/network)
  
  colnames.here = c("condition", "human_observers(average)")
  acc = get.accuracy(dat[dat$is.human==TRUE, ])
  for(subj in get.all.subjects(dat, avg.human.data = TRUE)) {
    if(subj$data.name %in% NETWORKS) {
      acc = cbind(acc, get.accuracy(dat[dat$subj==subj$data.name, ])$y)
      colnames.here = c(colnames.here, subj$name)
    }
  }
  colnames(acc) = colnames.here
  write.table(acc,
              filename, sep=" ",
              row.names = FALSE)
}
