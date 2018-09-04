In this Markdown document, a workflow for the analysis of 2D NMR spectra in **R** is presented.

This workflow includes:

**(i)** Importing of NMR spectra to Matlab

**(ii)** 2D NMR spectra denoising



## 0. USED EXAMPLES ##

In this guide, two raw NMR experiments will be used (**[FP22_A](https://drive.google.com/open?id=1K31lVE9RDT0efNgMQyZwt-yQPMA62Eyb)** and **[FP22_B](https://drive.google.com/open?id=1jWNa6BQlpgn9Nbjskd2wv1_vbbLWHQ8A)**). Each one of these experiments contain a 1D 1H NMR spectrum and a 2D 1H-13C HSQC NMR spectrum. The 1D 1H NMR spectrum is stored in the subfolder *10*, while the data from the 2D 1H-13C HSQC NMR spectrum are stored in the subfolder *11*.



## 1. IMPORT 2D NMR DATA ##

Files can be imported to R with the NMR spectra importing tool from **[rNMR](http://rnmr.nmrfam.wisc.edu/)**.



## 2. DENOISE A 2D NMR SPECTRUM ##
This is performed with the **voi2D.R** function.
```matlab
voi2D<-function(NMR_matrix,thresh,minvoi)
```
The **input** variables are:

*```NMR_matrix```*: The 2D NMR spectrum. First row and column include the ppm values.

*```thresh```*: The threshold used.

*```minvoi```*: the minimal number of connected variables that define a peak.

And the **output** variables is a list that contains the following objects:

*```filtered_NMR```*: a 2D matrix without noise. It is equal to the input 'NMR' variable, but with zero values instead of noise.

*```VOImatrix```*: a filtered matrix stored in a 3-row format. First row contains the intensity values kept, while the second and third rows contain the ppm chemical shifts for *f1* and *f2*, respectively.

*```indexes```*: the positions for all the selected pixels (the first pixel is at position [2,2], since it is the first with an intensity value).

*```array_peaks```*: a list containing as many entries as peaks. Each entry in the list contains the variables that constitute every single peak.



To denoise the NMR spectrum **FP22_A** (named here as ```A```) we can type the following:

```matlab
A_voi<-voi2D(A,6000,25);
```
For this example:

```A$filtered_NMR```: a 2D matrix of **2097152** data-points (1024 rows (*f1*) and 2048 columns (*f2*)), and from those only **14746** were **non**-**zero** data-points.

```A$VOImatrix```: the filtered ```A```NMR matrix stored in a 3-row format.

```A$indexes```: the positions for the **14746** VOIs.

```A$array_peaks```: a list containing **138** entries.



## References: ##
- Puig-Castellví F, Pérez Y, Piña B, Tauler R, Alfonso I (2018). Compression of multidimensional NMR spectra allows a faster and more accurate analysis of complex samples. Chem. Comm. http://doi.org/10.1039/C7CC09891J

## Contact: ##

puig.francesc@gmail.com
