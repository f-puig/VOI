function write3rrr(filtered_NMR,path,fileID)
% INPUT:
%       filtered_NMR: datacube containing the filtered intensities.
%           It has the same dimensions as the original 3D NMR spectrum.
%       path: path that contains the original 3D NMR spectrum.
%       fileID: Name for the output 3rrr-file.
%               ex: '3rrr_new'.
%
% OUTPUT:
%       A 3rrr-file with name 'fileID' in the working directory.
%       In order to open the 3D NMR spectrum in Topspin, the name
%       for this file needs to be '3rrr', stored in the ./path/1
%       folder, thus replacing the original '3rrr' file.
% ----------------------------------------------------------------

%% Read the parameters required for the conversion from the original spectrum.
A = rbnmr3D(path);
X  = A.Procs.XDIM;
Y  = A.Proc2s.XDIM;
Z  = A.Proc3s.XDIM;
nX = A.Procs.SI/X;
nY = A.Proc2s.SI/Y;
nZ = A.Proc3s.SI/Z;
count = A.Procs.SI*A.Proc2s.SI*A.Proc3s.SI;

%% Append all the data together in a vector format
REAL=zeros(count,1);
m=0;
for k=1:nZ
    for j=1:nY
        for i=1:nX
            piece=reshape(filtered_NMR((X*(i-1)+1):X*i,(Y*(j-1)+1):Y*j,(Z*(k-1)+1):Z*k),X*Y*Z,1);
            m=m+1;
            REAL((X*Y*Z*(m-1)+1):(X*Y*Z*m),1)=piece;
        end
    end
end

%% Write the file
f = fopen(char(fileID),'w');
fwrite(f,REAL,'uint32');
fclose(f);

    
    
    
    