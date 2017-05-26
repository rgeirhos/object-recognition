# Data and materials from <br>"Comparing Deep Neural Networks against humans:<br> Object recognition when the signal gets weaker"

This repository contains information, data and materials from the paper "Comparing deep neural networks against humans: Object recognition when the signal gets weaker" by Robert Geirhos, David H. J. Janssen, Heiko H. Schütt, Jonas Rauber, Matthias Bethge, and Felix A. Wichmann.

Please don't hesitate to contact me at robert.geirhos@uni-tuebingen.de or open an issue in case there is any question!

## raw-data
Every .csv raw data file has a header with the **bold** categories below, here's what they stand for:

- **subj:** for DNNs, name of network; for human observers: number of subject. This number is consistent across experiments. Note that the subjects were not necessarily given consecutive numbers, therefore it can be the case that \'subject-04\' does not exist in some or all experiments.

- **session:** session number

- **trial:** trial number

- **rt:** reaction time in seconds, or \'NaN\' for DNNs

- **object_response:** the response given, or \'na\' (no answer) if human subjects failed to respond

- **category:** the presented category

- **condition:** short indicator of the condition of the presented stimulus. Color-experiment: \'cr\' for color, \'bw\' for grayscale images; contrast-experiment: \'c100\', \'c50\', ... \'c01\' for 100%, 50%, ... 1% nominal contrast; noise-experiment: \'0\', \'0.03\', ... \'0.9\' for noise width; eidolon-experiment: in the form \'a-b-c\', indicating:
	- a is the parameter value for \'reach\', in {1,2,4,8,...128} 
	- b in {0,3,10} for coherence value of 0.0, 0.3, or 1.0
	- c = 10 for grain value of 10 (not varied in this experiment)

- **imagename:**

e.g. 3841_eid_dnn_1-0-10_knife_10_n03041632_32377.JPEG

This is a concatenation of the following information (separated by \'_\'):

1. a four-digit number starting with 0000 for the first image in an experiment; the last image therefore has the number n-1 if n is the number of images in a certain experiment
2. short code for experiment name, e.g. \'eid\' for eidolon-experiment
3. either e.g. \'s01\' for subject-01, or \'dnn\' for DNNs
4. condition
5. category
6. image identifier in the form a_b.JPEG, with _a_ being the WNID (WordNet ID) of the corresponding synset and _b_ being an integer.

## images
We preprocessed images from the ILSVRC2012 training database as described in the paper (e.g. we excluded grayscale images). In total we retained 213,555 images. The \'images/\' directory contains a .txt file with the final image names (the ones that were retained). If you would like to obtain the images, check out the [ImageNet website](http://image-net.org/download.php). In every experiment, the number of presented images for every entry-level MS COCO category (e.g. dog, car, boat, ...) were exactly the same.

## lab-experiment

#### experimental-code
Contains the main .m MATLAB experiment as well as a .yaml file for every experiment. In the .yaml file, the specific parameter values used in an experiment are specified (such as the stimulus presentation duration).

#### helper-functions
Some of the helper_functions are based on other people's code, please check out the corresponding files for the copyright notices.

#### response-screen-icons
The response screen icons appeared on the response screen, and participants were instructed to click on the corresponding one. The icons were taken from the [MS COCO website](http://mscoco.org/explore/).

![response screen icons](./lab-experiment/response-screen-icons/response_screen.png  "response screen icons")
