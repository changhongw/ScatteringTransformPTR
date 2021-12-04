# Scattering Transform for Playing Technique Recognition
Implementation of scattering transform variants for playing technique recognition. It includes two notebooks for reproducing the playing technique recognition system in [1] and [2], respectively:

[1] C. Wang. "[Scattering Transform for Playing Technique Recognition](https://changhongw.github.io/publications/)", PhD thesis, Queen Mary University of London, 2021.

[2] C. Wang, E. Benetos, V. Lostanlen, and E. Chew. "[Adaptive Scattering Transforms for Playing Technique Recognition](https://changhongw.github.io/publications/)", submitted to *IEEE/ACM Transactions on Audio, Speech, and Language Processing (TASLP)*, 2021.

Both work proposed two variants of the scattering transform: adaptive scattering and direction-invariant joint time--frequency scattering (dJTFS). The code for extracting these features was build upon the [ScatNet](https://www.di.ens.fr/data/software/scatnet/) toolbox. We organise the code in each notebook by four stages:

## CBFdataset download
Download the complete CBFdataset directly from [zenodo.org/record/5744336](https://zenodo.org/record/5744336).

## Decomposition trajectory extraction
Work [1] used the fundamental frequency (F0) as the decomposition trajectory while paper [2] used the dominant band as the decomposition trajectory.

## Scattering feature extraction
We extract the AdaTS+AdaTRS feature and the dJTFS-avg feature using by calling Matlab as a Python subprocess. The AdaTS+AdaTRS is the concatenation of adaptive time scattering (AdaTS) and the adaptive time--rate scattering (AdaTRS) while the dJTFS-avg is dJTFS obtained by applying average pooling to the direction variable of the joint time--frequency scattering.

## Playing Technique Recognition
With the scattering features extracted, we use a support vector machine classifier to label the playing techniques.

Any questions/bugs, please feel free to contact the author at changhong.wang-outlook.com.
