function [filtered_NMR,VOImatrix,indexes,array_peaks]=voi2Df(NMR,threshpos,threshneg,minvoi)
% NMR: the 2D matrix (ppm included). First row and column include ppm
%      values.
% threshpos: positive threshold level applied.
% threshneg: negative threshold level applied.
% minvoi: the minimal number of connected pixels to be considered a peak.
% filtered_NMR: the 2D matrix without noise.
% VOImatrix: the filtered matrix stored in a 3-row format.
% indexes: positions for all the selected pixels (pixel 1 starts counting at
%      position [2,2]), since it is the first with a intensity value.
% array_peaks: cell array containing with as many cells as peaks. Each cell
%      contains the pixels for every single peak.

tic

if threshneg > 0 || threshpos < 0
    display('"Threshpos" parameter must be positive.')
    display('"Threshneg" parameter must be negative.')
    display('Try again.')
    toc
    return
end

%// A. Indexes for peaks in phase.
%// A1. Creation of a matrix of 0 (below thresh) and 1 (above thresh).
temp = zeros(size(NMR(2:end,2:end),1),size(NMR(2:end,2:end),2));
temp(NMR(2:end,2:end)>=threshpos)=1;

%// A2. Data initialization 
[rows,cols] = size(temp);
evaluated = ~temp;
arraypeak={};
indexes=[];
peaks = 1;

%// A3. Look for connected pixels in temp matrix.
for row = 1 : rows
    for col = 1 : cols
        %/  A3.1 Pixels will be evaluated once. If they have already been
        %   evaluated, they will be ignored.
        if evaluated(row,col) == 1
            continue;    
        
        %/ A3.2 If the current pixel was not evaluated, and intensity is
        %  above threshold, then the pixel is counted.
        else
            candidate = [row col];
            
            while ~isempty(candidate)
                % Copy 'candidate' data to 'pos' and empty content from 'candidate'.
                % pos includes the pixel positions within a peak and it is increasing at every iteration
                pos = candidate(1,:);
                candidate(1,:) = [];

                % If we have visited this pixel, don't count it again. 
                if evaluated(pos(1),pos(2)) == 1
                    continue;
                end

                % Otherwise, check the pixel and store the position.
                evaluated(pos(1),pos(2)) = 1;
                if size(arraypeak,2) == peaks
                    arraypeak{peaks}=[arraypeak{peaks},sub2ind([rows cols], pos(1), pos(2))];
                else
                    arraypeak{peaks}=sub2ind([rows cols], pos(1), pos(2));
                end

                % Check the 8 neighbouring positions. 
                % Stablish the positions.
                [pos_y, pos_x] = meshgrid(pos(2)-1:pos(2)+1, pos(1)-1:pos(1)+1);
                pos_y = pos_y(:);
                pos_x = pos_x(:);

                % Discard locations outside the matrix limits.
                offlimits = pos_x < 1 | pos_x > rows | pos_y < 1 | pos_y > cols;
                pos_y(offlimits) = [];
                pos_x(offlimits) = [];

                % Discard locations already checked.
                checked = evaluated(sub2ind([rows cols], pos_x, pos_y));
                pos_y(checked) = [];
                pos_x(checked) = [];

                % Add to 'candidate'.
                candidate = [candidate; [pos_x pos_y]];
            end

            % Start with the new region
            peaks = peaks + 1;
        end
    end
end

%// B. Indexes for peaks in antiphase.
%// B1. Switch peaks from phase to antiphase (and vice versa) and repeat.
temp = zeros(size(NMR(2:end,2:end),1),size(NMR(2:end,2:end),2));
temp(NMR(2:end,2:end)<=threshneg)=1;

%// B2. Data initialization 
evaluated = ~temp;

%// B3. Look for connected pixels in temp matrix.
for row = 1 : rows
    for col = 1 : cols
        %/  B3.1 Pixels will be evaluated once. If they have already been
        %   evaluated, they will be ignored.
        if evaluated(row,col) == 1
            continue;    
        
        %/ B3.2 If the current pixel was not evaluated, and intensity is
        %  above threshold, then the pixel is counted.
        else
            candidate = [row col];
            
            while ~isempty(candidate)
                % Copy 'candidate' data to 'pos' and empty content from 'candidate'.
                % pos includes the pixel positions within a peak and it is increasing at every iteration
                pos = candidate(1,:);
                candidate(1,:) = [];

                % If we have visited this pixel, don't count and continue 
                if evaluated(pos(1),pos(2)) == 1
                    continue;
                end

                % Otherwise, check the pixel and store the position.
                evaluated(pos(1),pos(2)) = 1;
                if size(arraypeak,2) == peaks
                    arraypeak{peaks}=[arraypeak{peaks},sub2ind([rows cols], pos(1), pos(2))];
                else
                    arraypeak{peaks}=sub2ind([rows cols], pos(1), pos(2));
                end

                % Check the 8 neighbouring positions. 
                % Stablish the positions.
                [pos_y, pos_x] = meshgrid(pos(2)-1:pos(2)+1, pos(1)-1:pos(1)+1);
                pos_y = pos_y(:);
                pos_x = pos_x(:);

                % Discard locations outside the matrix limits.
                offlimits = pos_x < 1 | pos_x > rows | pos_y < 1 | pos_y > cols;
                pos_y(offlimits) = [];
                pos_x(offlimits) = [];

                % Discard locations already checked.
                checked = evaluated(sub2ind([rows cols], pos_x, pos_y));
                pos_y(checked) = [];
                pos_x(checked) = [];

                % Add to candidate.
                candidate = [candidate; [pos_x pos_y]];
            end

            % Start with the new region
            peaks = peaks + 1;
        end
    end
end

% List of indexes (VOIs) and array_peaks2
array_peaks ={};
k=1;
for i = 1:size(arraypeak,2)
    if length(arraypeak{1,i})>= minvoi
        indexes = [indexes,arraypeak{1,i}];
        array_peaks{k} = arraypeak{1,i};
        k = k+1;
    end
end
indexes=sort(indexes);

% filtered_NMR
filtered_NMR = zeros(rows+1, cols+1);
filtered_NMR(1,2:end) = NMR(1,2:end);
filtered_NMR(2:end,1) = NMR(2:end,1);
[pos_sortx,pos_sorty] = ind2sub([rows, cols], indexes);
indexes2=sub2ind([rows+1, cols+1], pos_sortx+1,pos_sorty+1);
filtered_NMR(indexes2) = NMR(indexes2);

% VOImatrix
VOImatrix = zeros(3,length(indexes));
VOImatrix(1,:) = NMR(indexes2);
VOImatrix(2,:) = NMR(1,pos_sorty+1);
VOImatrix(3,:) = NMR(pos_sortx+1,1);

toc
end