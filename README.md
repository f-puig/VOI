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
- plot2D.m: to plot a 2D NMR spectrum.
- plotpeaks.m: to plot selected peaks from several 2D NMR spectra.
- voi2D.m: to denoise and filter a single 2D NMR spectrum.
- integral2D.m: to integrate clusters from a voi-processed 2D NMR spectrum.
- peakpicking2D.m: to pick peaks from a voi-processed 2D NMR spectrum.
- voi2Df.m: to denoise and filter a single 2D phase-sensitive NMR spectrum.
- voi3D.m: to denoise and filter a single 3D NMR spectrum.
- filtervoi.m: to use an existent list of VOIs to filter one or more NMR spectra.

**For R**
- voi2D.R: to denoise and filter a single 2D NMR spectrum.


## References: ##
- Puig-Castellví F, Pérez Y, Piña B, Tauler R, Alfonso I (2018). Compression of multidimensional NMR spectra allows a faster and more accurate analysis of complex samples. Chem. Comm. http://doi.org/10.1039/C7CC09891J

## Contact: ##

puig.francesc@gmail.com
