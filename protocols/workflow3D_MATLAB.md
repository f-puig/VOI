In this Markdown document, a workflow for the analysis of 3D NMR spectra in Matlab is presented. This workflow includes the data import to Matlab, the denoising, and the export of denoised 2D NMR.

All functions required for the analysis can be downloaded from this repository.



## 1. IMPORT 3D NMR DATA ##

Nowadays, this feature is only available for Bruker files, using the following instruction:
```matlab
NMR3D = rbnmr3D('path');
```
This function generates an structure that contains all the data relative to the given NMR spectrum (the intensities, ppm vectors, and parameters relative to the acquisition and processing).



## 2. DENOISE A **3D** NMR SPECTRUM ##
This is performed with the **voi3D.m** function.
```matlab
[filtered_NMR,VOIcube,indexes,array_peaks]=voi3D(NMR,thresh,minvoi,ppm1,ppm2,ppm3)
```
In this case (unlike **voi2D.m** function), the intensity values and the ppm vectors are given in different variables.
If the 3D NMR spectrum was imported to Matlab using the **rbnmr3D.m** function, these variables (NMR, ppm1, ppm2, and ppm3) are contained in the fields Data, XAxis, YAxis, and ZAxis, respectively.
So, we can just write the following:

```matlab
[filtered_NMR,VOIcube,indexes,array_peaks]=voi3D(NMR3D.Data,6000,24,NMR3D.XAxis,NMR3D.YAxis,NMR3D.ZAxis);
```
The outputs from this function are equivalent to the ones obtained after application of the **voi2D.m** function.



## 3. EXPORT A DENOISED 3D CUBE TO TOPSPIN (CONVERSION TO 3RRR) ##
3D NMR files can be converted to 3rrr Bruker files using the following function:
```matlab
write3rrr(filtered_NMR,'path','filename');
```
The **input** variables are:
*```filtered_NMR```*: the cube that contains the filtered variables. It corresponds to the output of the **voi3D.m** function with the same name (see **section 2 "DENOISE A 3D NMR SPECTRUM"**).
*```path```*: the path that contains the original 3D NMR spectrum.
*```filename```*: Name for the output **3rrr**-file. For example: ```'3rrr_new'```.

This function creates a **3rrr** file in the working directory.
To identify the working directory, write ```pwd``` in the comand line.
To open the VOI-processed 3D NMR in a NMR Suite, replace the original **3rr** file by the new one.



## References: ##

- Puig-Castellví F, Pérez Y, Piña B, Tauler R, Alfonso I (2018). Compression of multidimensional NMR spectra allows a faster and more accurate analysis of complex samples. Chem. Comm. http://doi.org/10.1039/C7CC09891J



## Contact: ##

puig.francesc@gmail.com
