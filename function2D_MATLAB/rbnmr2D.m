function A = rbnmr2D(D,silent)
% rbnmr2D     Reads processed Bruker NMR-data.
%
% SYNTAX    A = rbnmr2D;			% Reads 2rr in the current working dir.
%           For example: 'E:/NMR folder/Project_XX/11/pdata/1/2rr'
% OUT       A: Struct with nmrdata.
%
% Francesc Puig-Castellvi, 2018-08-01
% Adapted from the rbnmr.m function created by Nils Nyberg, and available from
% https://www.mathworks.com/matlabcentral/fileexchange/40332-rbnmr
%
%% Copyright of the original function
% Copyright (c) 2013, Nils Nyberg
% All rights reserved.
% 
% Redistribution and use in source and binary forms, with or without
% modification, are permitted provided that the following conditions are
% met:
% 
% * Redistributions of source code must retain the above copyright
% notice, this list of conditions and the following disclaimer.
% * Redistributions in binary form must reproduce the above copyright
% notice, this list of conditions and the following disclaimer in
% the documentation and/or other materials provided with the distribution
% 
% THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS"
% AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE
% IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE
% ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT OWNER OR CONTRIBUTORS BE
% LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR
% CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF
% SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS
% INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN
% CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE)
% ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE
% POSSIBILITY OF SUCH DAMAGE.


%% Init values
CurrentWorkingDir = pwd;


%% Check inputs
if (nargin < 3);
	search = 1;
	% Warning: DOS programs may not execute correctly when the current directory is a UNC pathname.
	if all(ismember([1 2], regexp(CurrentWorkingDir,'\\')))
		search = 0;
	end
end
if (nargin < 2); silent = 0; end
if (nargin < 1); D = []; end

if (isempty(D) && exist('2rr','file')==2)
	input_class = 'datafiledirect'; File = '2rr';
elseif (~isempty(D) && ~isempty(regexp(D,'[12][ri]{1,2}$', 'once' )) && exist(D,'file')==2)
	input_class = 'datafile';
end

switch input_class
case 'datafile'
	try cd(fileparts(D))
	catch ME
		A.Title = ME.message;
		cd(CurrentWorkingDir);
		return;
	end
	A = rbnmr2D([],silent); cd(CurrentWorkingDir);
case 'datafiledirect'
	try
		A = do_the_actual_import(File);
	catch ME
		A.Title = ME.message;
		cd(CurrentWorkingDir);
		return;
    end	
end

% Fix out put and clean up
cd(CurrentWorkingDir);
return

function A = do_the_actual_import(File)

%% Read first line of title-file
fid = fopen('title','r');
if (fid ~= -1);
        title = textscan(fid,'%s','Whitespace','\n','ReturnOnError',1);
        fclose(fid);
		if isempty(title{1})
			A.Title = '<Title file empty>';
		else
			try
				A.Title = title{1}{1};
			catch ME
				A.Title = sprintf('Strange title-file: %s',ME.message);
			end
		end
else
	A.Title = '<Title file empty>';
end
	

%% Date and file information
[path,name,ext] = fileparts(File);
if isempty(path); path = pwd; end;
A.Info.ImportDate = datestr(now);
A.Info.FileName = [name ext];
A.Info.FilePath = path;
A.Info.Title = A.Title;


%% Add relative path from 'path'
q = regexpi(...
    fullfile(A.Info.FilePath,A.Info.FileName),...
    'data[/\\].+[/\\]nmr[/\\](.+)[/\\](\d+)[/\\]pdata[/\\](\d+)[/\\](.+)','tokens');
s = '/';	% unix-style
try
	A.Info.RelativePath = [q{1}{1},s,q{1}{2},s,'pdata',s,q{1}{3},s,q{1}{4}];
catch ME
	% Do nothing. Relative path does not seem to make any sense...
end


%% Check parameter files and read parameters
if strcmp(File,'2rr') && exist('proc2s','file')==2;
    A.Proc2s = readnmrpar('proc2s');
end
if strcmp(File,'2rr') && exist('../../acqu2s','file')==2;
    A.Acqu2s = readnmrpar('../../acqu2s');
end
if exist('../../acqus','file')==2;
    A.Acqus = readnmrpar('../../acqus');
else
	error('rbnmr2D: Could not find ../../acqus')
end
if exist('procs','file')==2;
    A.Procs = readnmrpar('procs');
end

%% Add acq-date
% Converts time given in UTC (base 1970, seconds) as matlab serial time
% (base 0000, days)
TZ = str2double(regexp(A.Acqus.Stamp,'UT(.\d+)h','tokens','once'));
if isempty(TZ); TZ = 2; end;	% Assume UT+2h if not in stamp-field
A.Info.AcqSerialDate = A.Acqus.DATE/(60*60*24)+datenum([1970 01 01])+TZ/24;
A.Info.AcqDateTime = datestr(A.Info.AcqSerialDate);
A.Info.AcqDate = datestr(A.Info.AcqSerialDate,'yyyy-mm-dd');
% Convert serial date to text to keep format
A.Info.AcqSerialDate = sprintf('%.12f',A.Info.AcqSerialDate);

%% Add plotlabel from A.Acqus.Stamp-info
q = regexp(A.Acqus.Stamp,'data[/\\].+[/\\]nmr[/\\](.+)[/\\](\d+)[/\\]acqus','tokens');
if isempty(q)	% New, more relaxed, data path
	q = regexp(A.Acqus.Stamp,'#.+[/\\](.+)[/\\](\d+)[/\\]acqus','tokens');
end
if isempty(q)
	A.Info.PlotLabel = ['[',A.Info.FilePath,']'];
else
	A.Info.PlotLabel = ['[',q{1}{1},':',q{1}{2},']'];
end

%% Open and read file
if A.Procs.BYTORDP == 0
    endian = 'l';
else
    endian = 'b';
end

[FID, MESSAGE] = fopen(File,'r',endian);
if FID == -1
	disp(MESSAGE);
	error(['rbnmr2D: Error opening file (',File,').']);
end

A.Data = fread(FID,'int32');
fclose(FID);

%% Read imaginary data if the file 1i exists
if (exist('1i','file')==2)
    [FID, MESSAGE] = fopen('1i','r',endian);
    if FID == -1
        % Do nothing
    end
    A.IData = fread(FID,'int32');
    fclose(FID);
end    

%% Correct data for NC_proc-parameter
A.Data = A.Data/(2^-A.Procs.NC_proc);
if (isfield(A,'IData'))
    A.IData = A.IData/(2^-A.Procs.NC_proc);
end

A.Procs.NC_proc = 0;

%% Calculate x-axis
A.XAxis = linspace( A.Procs.OFFSET,...
                    A.Procs.OFFSET-A.Procs.SW_p./A.Procs.SF,...
                    A.Procs.SI)';

%% Additional axis and reordering if 2D-file
if isfield(A,'Proc2s')
    A.YAxis = linspace( A.Proc2s.OFFSET,...
                        A.Proc2s.OFFSET-A.Proc2s.SW_p./A.Proc2s.SF,...
                        A.Proc2s.SI)';

%% Reorder submatrixes (se XWinNMR-manual, chapter 17.5 (95.3))

		SI1 = A.Procs.SI; SI2 = A.Proc2s.SI;
		XDIM1 = A.Procs.XDIM; XDIM2 = A.Proc2s.XDIM;

		NoSM = SI1*SI2/(XDIM1*XDIM2);    % Total number of Submatrixes
		NoSM2 = SI2/XDIM2;		 			% No of SM along F1

		A.Data = reshape(...
				permute(...
					reshape(...
						permute(...
							reshape(A.Data,XDIM1,XDIM2,NoSM),...
						[2 1 3]),...
					XDIM2,SI1,NoSM2),...
				[2 1 3]),...
  			    SI1,SI2)';

%% Read the level file if it exists
% The old version (level) is a binary 
	if(exist('level','file')==2)
		[FID, MESSAGE] = fopen('level','r',endian);
		if FID == -1
			disp('READBNMR: Error opening level file');
			disp(MESSAGE);
		end

		L=fread(FID,'int32');
		fclose(FID);

		% The first two figures is the number of pos. and neg. levels
		A.Levels = L(3:end);
		% Adjust for NC-parameter
		A.Levels = A.Levels/(2^-A.Procs.NC_proc);
	end

%% Read the clevel file if it exists
% The new version (clevel) is a text file 
	if(exist('clevels','file')==2)
		L = readnmrpar('clevels');
		switch L.LEVSIGN
			case 0	% Positive only
				A.Levels = L.LEVELS(L.LEVELS > 0)';
			case 1	% Negative only
				A.Levels = L.LEVELS(L.LEVELS < 0)';
			case 2	% Both pos and neg.
				A.Levels = L.LEVELS(1:L.MAXLEV*2);
		end
	end

%% Check that A.Levels is not one (large) scalar. If so 'Contour' will crash.
	if (isfield(A,'Levels') && length(A.Levels) == 1)
		A.Levels = [A.Levels;A.Levels];
	end

end


function P = readnmrpar(FileName)
% rbnmr2DPAR      Reads BRUKER parameter files to a struct
%
% SYNTAX        P = readnmrpar(FileName);
%
% IN            FileName:	Name of parameterfile, e.g., acqus
%
% OUT           Structure array with parameter/value-pairs
%

% Read file
A = textread(FileName,'%s','whitespace','\n');

% Det. the kind of entry
TypeOfRow = cell(length(A),2);
    
R = {   ...
    '^##\$*(.+)=\ \(\d\.\.\d+\)(.+)', 'ParVecVal' ; ...
    '^##\$*(.+)=\ \(\d\.\.\d+\)$'   , 'ParVec'    ; ...
    '^##\$*(.+)=\ (.+)'             , 'ParVal'    ; ...
    '^([^\$#].*)'                   , 'Val'       ; ...
    '^\$\$(.*)'                     , 'Stamp'     ; ...
    '^##\$*(.+)='                   , 'EmptyPar'  ; ...
	'^(.+)'							, 'Anything'	...
    };

for i = 1:length(A)
    for j=1:size(R,1)
        [s,t]=regexp(A{i},R{j,1},'start','tokens');
        if (~isempty(s))
            TypeOfRow{i,1}=R{j,2};
            TypeOfRow{i,2}=t{1};
        break;
        end
    end
end

% Set up the struct
i=0;
while i < length(TypeOfRow)
    i=i+1;
    switch TypeOfRow{i,1}
        case 'ParVal'
            LastParameterName = TypeOfRow{i,2}{1};
            P.(LastParameterName)=TypeOfRow{i,2}{2};
        case {'ParVec','EmptyPar'}
            LastParameterName = TypeOfRow{i,2}{1};
            P.(LastParameterName)=[];
        case 'ParVecVal'
            LastParameterName = TypeOfRow{i,2}{1};
            P.(LastParameterName)=TypeOfRow{i,2}{2};
        case 'Stamp'
            if ~isfield(P,'Stamp') 
                P.Stamp=TypeOfRow{i,2}{1};
            else
                P.Stamp=[P.Stamp ' ## ' TypeOfRow{i,2}{1}];
            end
        case 'Val'
			if isempty(P.(LastParameterName))
				P.(LastParameterName) = TypeOfRow{i,2}{1};
			else
				P.(LastParameterName) = [P.(LastParameterName),' ',TypeOfRow{i,2}{1}];
			end
        case {'Empty','Anything'}
            % Do nothing
    end
end
    

% Convert strings to values
Fields = fieldnames(P);

for i=1:length(Fields);
    trystring = sprintf('P.%s = [%s];',Fields{i},P.(Fields{i}));
    try
        eval(trystring);
	catch %#ok<CTCH>
        % Let the string P.(Fields{i}) be unaltered
    end
end

