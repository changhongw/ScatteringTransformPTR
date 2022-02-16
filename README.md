# Scattering Transform for Playing Technique Recognition
Code for reproducing the playing technique recognition system (Section 5.5.2) in the thesis:

C. Wang. "[Scattering Transform for Playing Technique Recognition](https://qmro.qmul.ac.uk/xmlui/handle/123456789/76559)", PhD thesis, Queen Mary University of London, 2021.

This work proposes two scattering transform variants, the adaptive scattering and the direction-invariant joint time--frequency scattering (dJTFS). The code for extracting these features is build upon the [ScatNet](https://www.di.ens.fr/data/software/scatnet/) toolbox. We organise the implementation by four stages:

## CBFdataset download
Download the complete CBFdataset directly from [zenodo.org/record/5744336](https://zenodo.org/record/5744336).

## Decomposition trajectory extraction
Detect the fundamental frequency (F0) as the decomposition trajectory.

## Scattering feature extraction
We extract the AdaTS+AdaTRS feature and the dJTFS-avg feature using by calling Matlab as a Python subprocess. The AdaTS+AdaTRS is the concatenation of adaptive time scattering (AdaTS) and the adaptive time--rate scattering (AdaTRS) while the dJTFS-avg is dJTFS obtained by applying average pooling to the direction variable of the joint time--frequency scattering.

## Playing Technique Recognition
With the scattering features extracted, we use a support vector machine classifier to label the playing techniques.

Any questions/bugs, please feel free to contact the author at changhong-wang@outlook.com.

### Acknowledgement
The thesis template is built upon [William J. Wilkinson's thesis](https://qmro.qmul.ac.uk/xmlui/bitstream/handle/123456789/61329/WILKINSON_W_J_PhD_Final_041019.pdf?sequence=2&isAllowed=y).
