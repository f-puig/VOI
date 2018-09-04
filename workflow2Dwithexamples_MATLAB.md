In this Markdown document, a workflow for the analysis of 2D NMR spectra in Matlab is presented.

This workflow includes:

	**(i)** Importing of NMR spectra to Matlab

	**(ii)** 2D NMR spectra denoising

	**(iii)** Peak picking

	**(iv)** Peak plotting

	**(v)** Peak integration

	**(vi)** Exporting of denoised 2D NMR

Moreover, **some** functions have been implemented for the **simultaneous analysis of several 2D NMR** spectra at the same time.

All functions required for the analysis can be downloaded from this repository. This guide also includes examples, and the raw spectra used in these examples can be downloaded from this repository as well.



## 0. USED EXAMPLES ##

In this guide, two raw NMR experiments will be used (**[FP22_A](https://drive.google.com/open?id=1K31lVE9RDT0efNgMQyZwt-yQPMA62Eyb)** and **[FP22_B](https://drive.google.com/open?id=1jWNa6BQlpgn9Nbjskd2wv1_vbbLWHQ8A)**). Each one of these experiments contain a 1D 1H NMR spectrum and a 2D 1H-13C HSQC NMR spectrum. The 1D 1H NMR spectrum is stored in the subfolder *10*, while the data from the 2D 1H-13C HSQC NMR spectrum are stored in the subfolder *11*.



## 1. IMPORT 2D NMR DATA ##

### 1.1. Import Bruker files ###
For Bruker files, this can be achieved by using the following functions:
```matlab
NMR = rbnmr2D('path');
```
This function generates an structure that contains all the data relative to the given NMR spectrum (the spectral intensities, the ppm vectors, and all the parameters relative to the acquisition and processing).

For the posterior application of the VOI denoising, it is preferrable to use the following command instead:
```matlab
NMR = read2rr('path');
```
This function generates a 2D matrix of intensities that contains in the first row and the first column both ppm1 and ppm2 vectors. This is the format that accepts the **voi2D.m** function.

In both cases, the path provided should be the path to the **2rr** file.

In order to import the two 2D NMR spectra included in this repository, we need to write in the command line the following text:

```matlab
A = read2rr('C:/User/Documents/VOI/examples/2D/FP22_A/11/pdata/1/2rr');
B = read2rr('C:/User/Documents/VOI/examples/2D/FP22_B/11/pdata/1/2rr');
```

### 1.2. Import Varian files ###
For Varian files, a 2D NMR spectrum can be saved as a matrix in a *.csv* format in MestReNova (http://mestrelab.com). This *.csv* file can be converted into a matrix by simply writing load(*'filename.csv'*) on the command line.
The resulting variable will be in the correct format for the **voi2D.m** function.



## 2. DENOISE A 2D NMR SPECTRUM ##
This is performed with the **voi2D.m** function.
```matlab
[filtered_NMR,VOImatrix,indexes,array_peaks]=voi2D(NMR,thresh,minvoi);
```
The **input** variables are:

*```NMR```*: The 2D NMR spectrum. First row and column include the ppm values.

*```thresh```*: The threshold used.

*```minvoi```*: the minimal number of connected variables that define a peak.

And the **output** variables are:

*```filtered_NMR```*: a 2D matrix without noise. It is equal to the input 'NMR' variable, but with zero values instead of noise.

*```VOImatrix```*: a filtered matrix stored in a 3-row format. First row contains the intensity values kept, while the second and third rows contain the ppm chemical shifts for *f1* and *f2*, respectively.

*```indexes```*: the positions for all the selected pixels (the first pixel is at position [2,2], since it is the first with an intensity value).

*```array_peaks```*: a cell array containing as many cells as peaks. Each cell contains the variables that constitute every single peak.

To denoise the NMR spectrum **A**, we can type the following:

```matlab
[filtered_NMR,VOImatrix,indexes,array_peaks]=voi2D(A,6000,25);
```
For this example, the denoising operation has reduced the number of data-points from **2097152** (a matrix of 1024 rows (*f1*) and 2048 columns (*f2*) to only **14746** data-points or **VOIs**. Moreover, these **14746** data-points are organized in **138** clusters of VOIs (or peaks).



## 3. DENOISE A **PHASE-SENSITIVE** 2D NMR SPECTRUM

This is performed with the **voi2Df.m** function.

```matlab
[filtered_NMR,VOImatrix,indexes,array_peaks]=voi2Df(NMR,threshpos,threshneg,minvoi)
```

**VOI2Df.m** is the analogous function of VOI2D for phase-sensitive 2D spectra. The only difference to **voi2D.m** function is that two different thresholds (one positive and one negative) are used instead of one.



## 4. PLOTTING 2D NMR DATA ##

To generate a plot from the 2D NMR data, the **plot2D.m** function can be used.

```matlab
plot2D(filtered_NMR,contourlines);
```

If the ```countourlines``` parameters is an integer or it is left blank, then a contour plot of the data will be constructed. This parameter corresponds to the number of contour lines drawn. If this parameter is not set by the user, the default value of 30 is used.

```
plot2D(filtered_NMR,30);
```

![fig1](C:\Users\putxv\Desktop\voi per penjar\voi per penjar\functions2D\fig1.png)

If the ```countourlines``` parameters is the string ```'no-lines'```, then no lines are drawn in the 2D NMR plot, and each peak is defined by one single-colored spot.

```matlab
plot2D(filtered_NMR,'no-lines');
```

![fig2](C:\Users\putxv\Desktop\voi per penjar\voi per penjar\functions2D\fig2.png)

This mode of plotting may result useful when the difference in scale among the resonances is very high.



## 5. INTEGRATE ALL PEAKS FROM A 2D NMR SPECTRUM ##

This is performed with the **integral2D.m** function.
This functions sums all the intensity values that are comprised within each cluster of variables.

```matlab
[integrals]=integral2D(array_peaks, filtered_NMR)
```
The **input** variables are:

*```array_peaks```*: a cell array containing the list of VOIs. Each cell contains the VOIs for one cluster.

*```filtered_NMR```*: the denoised 2D NMR spectrum.

These two variables are obtained after application of the voi2D.m function.

And the **output** variables are:

*```integrals```*: the vector of integrals for the peaks defined by 'array_peaks' cell array.



## 6. PICK PEAKS FROM A 2D NMR SPECTRUM ##
This is performed with the **pickpeaking2D.m** function.
This functions searches, for every peak, the variable with the highest intensity, and reports their associated chemical shifts in *f1* and *f2*.
```matlab
[peak_pos]=pickpeaking2D(array_peaks, filtered_NMR)
```
The **input** variables are:

*```array_peaks```*: a cell array containing the list of VOIs. Each cell contains the VOIs for one cluster.

*```filtered_NMR```*: the denoised 2D NMR spectrum.

These two variables are obtained after application of the voi2D.m function.

And the **output** variables are:

*```peak_pos```*: the list of chemical shifts associated to every peak (or cluster of VOIs). This variable contains as many rows as peaks, and two columns. The first column contains the chemical shifts in *f1*, while the second column contains the chemical shifts in *f2*.



## 7. DENOISE SEVERAL 2D NMR SPECTRA USING THE SAME LIST OF VOIS

To perform this simultaneous denoising, the following workflow can be used. In this example, only two 2D NMR spectra are combined, but this methodology can be applied to analyze any number of spectra.
1) Import the two 2D NMR spectra to MATLAB.

```matlab
NMR1 = read2rr('path1');
NMR2 = read2rr('path2');
```

2) Create a structure with the two NMR spectra.

```matlab
strNMR=struct;
strNMR.NMR1=NMR1;
strNMR.NMR2=NMR2;
```

**3**) Ensure that the the ppm values for *f1* and *f2* dimensions in the two 2D NMR are the same. This can be solved by running the **interp2D.m** function, which can also be found in this package.

```matlab
strNMR = interp2D(strNMR);
```

4) Apply VOI separately on the two NMR spectra. If different acqusition parameters are used on the two NMR, then the threshold and minvoi parameters must be optimized for every spectrum.

```matlab
[filtered_NMR1,VOImatrix1,indexes1,array_peaks1]=voi2D(strNMR.NMR1,thresh1,minvoi1);
[filtered_NMR2,VOImatrix2,indexes2,array_peaks2]=voi2D(strNMR.NMR2,thresh2,minvoi2);
```

If we set both ``thresh1`` and ``thresh2`` to **6000**, and ``minvoi1`` and ``minvoi2`` to **25**, we obtain that NMR1 has **138** clusters of VOIs (or peaks), and NMR2 has **113** clusters.

5) Combine the two list of selected VOIs obtained:

```matlab
indexes_common=unique([indexes1,indexes2]);
```

6) Filter the interpolated NMR obtained in **step 3** with the new list of selected VOIs.

```matlab
[filtered_common, VOImatrix, VOIppm, array_peaks_common]=filtervoi(strNMR, indexes_common);
```

The **filtered_common** structure contains the denoised versions of NMR1 and NMR2 according to the list of VOIs from the indexes_common variable.



## 8. PLOT 2D NMR PEAKS

This is performed with the **plotpeaks.m** function.

This function plots, for a set of samples, an array of peaks using a contour representation.

```matlab
plotpeaks(strNMR, array_peaks_common, list_peaks, thresh, ref)
```

For instance, for the given dataset, an example of the array of peaks that can be obtained is shown below:

![figpeaks](C:\Users\putxv\Desktop\voi per penjar\voi per penjar\functions2D\figpeaks.png)

This figure was generated using the following command:

```matlab
plotpeaks(strNMR, array_peaks_common, list_peaks, 6000, 1)
```

The list of peaks to be plotted are indicated with the ``list_peaks`` variable. In this case:

```matlab
list_peaks = [57, 60, 63, 67, 70, 78, 90, 107, 112, 127];
```



## 9. EXPORT A DENOISED 2D MATRIX TO TOPSPIN (CONVERSION TO 2RR) ##
2D NMR files can be converted to 2rr Bruker files using the following function:
```matlab
write2rr(filtered_NMR,'path','filename');
```
The **input** variables are:

*```filtered_NMR```*: the datamatrix that contains the filtered variables, as well the ppm values for *f1* and for *f2* in the first column and row.

*```path```*: the path that contains the original 2D NMR spectrum.

*```filename```*: Name for the output **2rr**-file. For example: ```'2rr_new'```.

This function creates a **2rr** file in the working directory.
To identify the working directory, write ```pwd``` in the comand line.
To open the VOI-processed 2D NMR on TopSpin, MestReNova or any other NMR Suite, replace the original **2rr** file by the new one.





## References: ##
- Puig-Castellví F, Pérez Y, Piña B, Tauler R, Alfonso I (2018). Compression of multidimensional NMR spectra allows a faster and more accurate analysis of complex samples. Chem. Comm. http://doi.org/10.1039/C7CC09891J

## Contact: ##

puig.francesc@gmail.com
