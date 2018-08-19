function [filtered_common, VOImatrix, VOIppm, array_peaks_common]=filtervoi(structureNMR, indexes_common)
% INPUT VARIABLES
% structureNMR: a structure that contains all the original 2D NMR spectra. For every 2D NMR spectra, first row and column include ppm values.         
% indexes_common: the list of indexes to retrieve the intensity values of every spectrum.

% OUTPUT VARIABLES
% filtered_common: it contains all the VOI-processed 2D NMR spectra in a structure format.
% VOImatrix: A matrix with m rows and n columns, containing the intensities of the n VOI-filtered variables for the m 2D NMR spectra.
% VOIppm: A 2-row matrix, containing the ppm values in f1 and f2 of the filtered variables.
% array_peaks_common: it contains the list of independent clusters of VOI variables.

%% 1. Initializing variables
S=fieldnames(structureNMR);
ppm1=structureNMR.(S{1})(1,2:end);
ppm2=structureNMR.(S{1})(2:end,1);
rows=length(ppm2);
cols=length(ppm1);
zero_matrix=zeros(length(ppm2)+1,length(ppm1)+1);
zero_matrix(1,2:end)=ppm1;
zero_matrix(2:end,1)=ppm2;
VOImatrix=zeros(length(S),length(indexes_common));
filtered_common=struct;
[pos_sortx,pos_sorty] = ind2sub([rows, cols], indexes_common);
indexes2=sub2ind([rows+1, cols+1], pos_sortx+1,pos_sorty+1);
ones_matrix=zero_matrix;
ones_matrix(indexes2)=ones(1,length(indexes2));

%% 2. Filling filtered_common structure and VOImatrix.
for i=1:length(S)
	zero_matrix2=zero_matrix;
	filtered_common.(S{i}) = zero_matrix2;
	filtered_common.(S{i})(indexes2) = structureNMR.(S{i})(indexes2);
	VOImatrix(i,:)=structureNMR.(S{i})(indexes2);
end

%% 3. VOIppm
VOIppm(1,:)=structureNMR.(S{1})(1,pos_sorty+1);
VOIppm(2,:)=structureNMR.(S{1})(pos_sortx+1,1);

%% 4. array_peaks_common
[~,~,~,array_peaks_common]=voi2D(ones_matrix,0.1,2);