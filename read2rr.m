function [NMR_matrix] = read2rr(path)
% This function reads a 2rr-file. 
% Ex. path= 'E:/NMR folder/Project_XX/11/pdata/1/2rr'

%% Read 2rr-file
% Adapted from rbnmr.m function created by Nils Nyberg, and downloaded from
% https://www.mathworks.com/matlabcentral/fileexchange/40332-rbnmr
A = rbnmr2D(path);

%% Create A_matrix, which contains intensity and ppm values.
NMR_matrix=zeros(size(A.Data)+1);
NMR_matrix(1,2:end) = A.XAxis;
NMR_matrix(2:end,1) = A.YAxis;
NMR_matrix(2:end,2:end) = A.Data;

end

