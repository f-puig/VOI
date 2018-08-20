# VOI: Variables-Of-Interest #

VOI is a small package to denoise multidimensional NMR spectra. Currently, it can be used to denoise 2D NMR and 3D NMR spectra. This package has been written in **MATLAB** programming language, but the main function from this package (VOI2D.m) has been also translated to **R**.
VOI denoising strategy filters NMR variables based on two parameters defined by the user:
1) The intensity **threshold**: The intensity of the selected variables will be *higher* than the established threshold. Otherwise, these variables will be discarded.
2) The **minvoi**: This parameter represents the *minimal* number of connected variables that constitutes a peak. If the set of connected variables is smaller than the minvoi, the set of adjacent variables will be considered as noise and it will be discarded.

The functions that can be donwloaded from this repository are the following:

**For MATLAB**
- rbnmr2D.m: to import 2rr Bruker files to Matlab environment.
- read2rr.m: to import 2rr Bruker files to Matlab environment, and to prepare the data for VOI denosing.
- rbnmr3D.m: to import 3rrr Bruker files to Matlab environment.
- write2rr.m: to write a 2rr binary file from a 2D NMR matrix.
- write3rrr.m: to write a 3rrr binary file from a 3D NMR cube. 
- voi2D.m: to denoise and filter a single 2D NMR spectrum.
- integral2D.m: to integrate clusters from a voi-processed 2D NMR spectrum.
- peakpicking2D.m: to pick peaks from a voi-processed 2D NMR spectrum.
- voi2Df.m: to denoise and filter a single 2D phase-sensitive NMR spectrum.
- voi3D.m: to denoise and filter a single 3D NMR spectrum.
- filtervoi.m: to use an existent list of VOIs to filter one or more NMR spectra.

**For R**
- voi2D.R: to denoise and filter a single 2D NMR spectrum.

Here are some examples on how these functions are applied:

## 1. IMPORT 2D NMR DATA ##
### 1.1. Import Bruker files ###
For Bruker files, this can be achieved by using the following functions:
```
NMR = rbnmr2D('path');
```
This function generates an structure that contains all the data relative to the given NMR spectrum (the intensities, ppm vectors, and parameters relative to the acquisition and processing).

Or,
```
NMR = read2rr('path');
```
This function generates a 2D matrix of intensities that contains in the first row and the first column both ppm1 and ppm2 vectors. This is the format that accepts the **voi2D.m** function.
### 1.2. Import Varian files ###
For Varian files, a 2D NMR spectrum can be saved as a matrix in a *.csv* format in MestReNova (http://mestrelab.com). This *.csv* file can be converted into a matrix by simply writing load(*'filename.csv'*) on the command line.
The resulting variable will be in the correct format for the *voi2D.m* function.

## 2A. DENOISE A 2D NMR SPECTRUM (FOR MATLAB) ##
This is performed with the **voi2D.m** function.
```
[filtered_NMR,VOImatrix,indexes,array_peaks]=voi2D(NMR,thresh,minvoi);
```
For example:
```
[filtered_NMR,VOImatrix,indexes,array_peaks]=voi2D(NMR,6000,24);
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

## 2B. DENOISE A 2D NMR SPECTRUM (FOR R) ##
This is performed with the **voi2D.R** function.
```
output<-voi2D(NMR,thresh,minvoi)
```
For example:
```
output <- voi2D(NMR,6000,24)
```
The **input** variables are the same as in the equivalent Matlab function. To import the NMR spectra to **R** environment, the **rNMR** software (http://rnmr.nmrfam.wisc.edu/) can be used. 

The **output** variable is a list that contains the following 4 elements:

*```filtered_NMR```*: a 2D matrix without noise. It is equal to the input 'NMR' variable, but with zero values instead of noise. This denoised 2D NMR spectrum is also **compatible** with the **rNMR** software.

*```VOImatrix```*: a filtered matrix stored in a 3-row format. First row contains the intensity values kept, while the second and third rows contain the ppm chemical shifts for *f1* and *f2*, respectively.

*```indexes```*: the positions for all the selected pixels (the first pixel is at position [2,2], since it is the first with an intensity value).

*```array_peaks```*: a list containing as many elements as peaks. Each elements contains the variables that constitute every single peak.

## 3. INTEGRATE ALL PEAKS FROM A 2D NMR SPECTRUM ##
This is performed with the **integral2D.m** function.
This functions sums all the intensity values that are comprised within each cluster of variables.
```
[integrals]=integral2D(array_peaks, filtered_NMR)
```
The **input** variables are:

*```array_peaks```*: a cell array containing the list of VOIs. Each cell contains the VOIs for one cluster.

*```filtered_NMR```*: the denoised 2D NMR spectrum.

These two variables are obtained after application of the voi2D.m function.

And the **output** variables are:

*```integrals```*: the vector of integrals for the peaks defined by 'array_peaks' cell array.

## 4. PICK PEAKS FROM A 2D NMR SPECTRUM ##
This is performed with the **pickpeaking2D.m** function.
This functions searches, for every peak, the variable with the highest intensity, and reports their associated chemical shifts in f1 and f2.
```
[peak_pos]=pickpeaking2D(array_peaks, filtered_NMR)
```
The **input** variables are:

*```array_peaks```*: a cell array containing the list of VOIs. Each cell contains the VOIs for one cluster.

*```filtered_NMR```*: the denoised 2D NMR spectrum.

These two variables are obtained after application of the voi2D.m function.

And the **output** variables are:

*```peak_pos```*: the list of chemical shifts associated to every peak (or cluster of VOIs). This variable contains as many rows as peaks, and two columns. The first column contains the chemical shifts in *f1*, while the second column contains the chemical shifts in *f2*.

## 5. EXPORT A DENOISED 2D MATRIX TO TOPSPIN (CONVERSION TO 2RR) ##
2D NMR files can be converted to 2rr Bruker files using the following function:
```
write2rr(filtered_NMR,'path','filename');
```
The **input** variables are:

*```filtered_NMR```*: the datamatrix that contains the filtered variables, as well the ppm values for *f1* and for *f2* in the first column and row.

*```path```*: the path that contains the original 2D NMR spectrum.

*```filename```*: Name for the output **2rr**-file. For example: ```'2rr_new'```.

This function creates a **2rr** file in the working directory.
To identify the working directory, write ```pwd``` in the comand line.
To open the VOI-processed 2D NMR on TopSpin, MestReNova or any other NMR Suite, replace the original **2rr** file by the new one.

## 6. DENOISE SEVERAL 2D NMR SPECTRA USING THE SAME LIST OF VOIS ##
To perform this simultaneous denoising, the following workflow can be used. In this example, only two 2D NMR spectra are combined, but this methodology can be applied to analyze any number of spectra.
1) Import the two 2D NMR spectra to MATLAB.
```
NMR1 = read2rr('path1');
NMR2 = read2rr('path2');
```
2) Ensure that the the ppm values for f1 and f2 dimensions in the two 2D NMR are the same. Otherwise, this can be solved by interpolation (see ```interp1``` and ```interp2``` functions in Matlab).
3) Apply VOI separately on the two NMR spectra. If different acqusition parameters are used on the two NMR, then the threshold and minvoi parameters must be optimized for every spectrum.
```
[filtered_NMR1,VOImatrix1,indexes1,array_peaks1]=voi2D(NMR1,thresh1,minvoi1);
[filtered_NMR2,VOImatrix2,indexes2,array_peaks2]=voi2D(NMR2,thresh2,minvoi2);
```
4) Combine the two list of selected VOIs obtained:
```
indexes_common=unique(indexes1,indexes2);
```
5) Create a structure with the two NMR spectra.
```
structureNMR=struct;
structureNMR.NMR1=NMR1;
structureNMR.NMR2=NMR2;
```
6) Filter the original NMR (NMR1 and NM2) with the new list of selected VOIs.
```
[filtered_common, VOImatrix, VOIppm, array_peaks_common]=filtervoi(structureNMR, indexes_common);
```
The **filtered_common** structure contains the denoised versions of NMR1 and NMR2 according to the list of VOIs from the indexes_common variable.

## 7. DENOISE A **PHASE-SENSITIVE** 2D NMR SPECTRUM ##
This is performed with the **voi2Df.m** function.
```
[filtered_NMR,VOImatrix,indexes,array_peaks]=voi2Df(NMR,threshpos,threshneg,minvoi)
```
**VOI2Df.m** is the analogous function of VOI2D for phase-sensitive 2D spectra. The only difference to **voi2D.m** function is that two different thresholds (one positive and one negative) are used instead of one.

## 8. IMPORT 3D NMR DATA ##
Nowadays, this feature is only available for Bruker files, using the following instruction:
```
NMR3D = rbnmr3D('path');
```
This function generates an structure that contains all the data relative to the given NMR spectrum (the intensities, ppm vectors, and parameters relative to the acquisition and processing).

## 9. DENOISE A **3D** NMR SPECTRUM ##
This is performed with the **voi3D.m** function.
```
[filtered_NMR,VOIcube,indexes,array_peaks]=voi3D(NMR,thresh,minvoi,ppm1,ppm2,ppm3)
```
In this case (unlike **voi2D.m** function), the intensity values and the ppm vectors are given in different variables.
If the 3D NMR spectrum was imported to Matlab using the **rbnmr3D.m** function, these variables (NMR, ppm1, ppm2, and ppm3) are contained in the fields Data, XAxis, YAxis, and ZAxis, respectively.
So, we can just write the following:
```
[filtered_NMR,VOIcube,indexes,array_peaks]=voi3D(NMR3D.Data,6000,24,NMR3D.XAxis,NMR3D.YAxis,NMR3D.ZAxis);
```
The outputs from this function are equivalent to the ones obtained after application of the **voi2D.m** function.

## 10. EXPORT A DENOISED 3D CUBE TO TOPSPIN (CONVERSION TO 3RRR) ##
3D NMR files can be converted to 3rrr Bruker files using the following function:
```
write3rrr(filtered_NMR,'path','filename');
```
The **input** variables are:
*```filtered_NMR```*: the cube that contains the filtered variables. It corresponds to the output of the **voi3D.m** function with the same name (see **section 9**).
*```path```*: the path that contains the original 3D NMR spectrum.
*```filename```*: Name for the output **3rrr**-file. For example: ```'3rrr_new'```.

This function creates a **3rrr** file in the working directory.
To identify the working directory, write ```pwd``` in the comand line.
To open the VOI-processed 3D NMR in a NMR Suite, replace the original **3rr** file by the new one.

## References: ##
- Puig-Castellví F, Pérez Y, Piña B, Tauler R, Alfonso I (2018). Compression of multidimensional NMR spectra allows a faster and more accurate analysis of complex samples. Chem. Comm. http://doi.org/10.1039/C7CC09891J

## Contact: ##

puig.francesc@gmail.com
