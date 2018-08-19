function write2rr(filtered_NMR,path,fileID)
% INPUT:
%       filtered_NMR: datamatrix that contains the filtered variables,
%           as well the ppm values for f1 in the first column,
%           and the ppm values for f2 in the first row.
%       path: path that contains the original 2D NMR spectrum.
%       fileID: Name for the output 2rr-file.
%               ex: '2rr_new'.
%
% OUTPUT:
%       A 2rr-file with name 'fileID' in the working directory.
%       In order to open the 2D NMR spectrum in Topspin, the name
%       for this file needs to be '2rr', stored in the ./path/1
%       folder, thus replacing the original '2rr' file.
% ----------------------------------------------------------------

%% Read the parameters required for the conversion from the original spectrum.
A = rbnmr2D(path);
X  = A.Procs.XDIM;
Y  = A.Proc2s.XDIM;
nX = A.Procs.SI/X;
nY = A.Proc2s.SI/Y;
count = A.Procs.SI*A.Proc2s.SI;

%% Prepare the VOI data.
voi=filtered_NMR(2:end,2:end)';

%% Append all the data together in a vector format
REAL=zeros(count,1);
m=0;
    for j=1:nY
        for i=1:nX
            piece=reshape(voi((X*(i-1)+1):X*i,(Y*(j-1)+1):Y*j),X*Y,1);
            m=m+1;
            REAL((X*Y*(m-1)+1):(X*Y*m),1)=piece;
        end
    end

%% Write the file
f = fopen(char(fileID),'w');
fwrite(f,REAL,'uint32');
fclose(f);

    
    
    
    