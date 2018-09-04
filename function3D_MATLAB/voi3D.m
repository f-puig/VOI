function [filtered_NMR,VOIcube,indexes,array_peaks]=voi3D(NMR,thresh,minvoi,ppm1,ppm2,ppm3)
% NMR: the 3D NMR matrix. It only contains intensity values.
% thresh: threshold level applied.
% minvoi: the minimal number of connected pixels to be considered a peak.
% filtered_NMR: the 3D matrix without noise.
% VOIcube: the filtered matrix stored in a 4-row format.
% indexes: positions for all the selected pixels (pixel 1 starts counting at
%      position [1,1,1]), since it is the first with an intensity value.
% array_peaks: cell array containing with as many cells as peaks. Each cell
%      contains the pixels for every single peak.
% ppm1, ppmw2, and ppm3. PPM values in f1, f2 and f3.

tic
%// 1. Creation of a cube of 0 (below thresh) and 1 (above thresh).
temp = zeros(size(NMR,1),size(NMR,2),size(NMR,3));
temp(NMR>=thresh)=1;

%// 2. Data initialization 
[rows,cols,slices] = size(temp);
evaluated = ~temp;
arraypeak={};
indexes=[];
peaks = 1;

%// 3. Look for connected pixels in temp cube.
for slice = 1:slices
    for row = 1 : rows
        for col = 1 : cols
            %/  3.1 Pixels will be evaluated once. If they have already been
            %   evaluated, they will be ignored.
            if evaluated(row,col,slice) == 1
                continue;    
        
            %/ 3.2 If the current pixel was not evaluated, and intensity is
            %  above threshold, then the pixel is counted.
            else
                candidate = [row col slice];
            
                while ~isempty(candidate)
                    % Copy 'candidate' data to 'pos' and empty 'candidate' content.
                    % pos includes the pixel positions within a peak and it is increasing at every iteration
                    pos = candidate(1,:);
                    candidate(1,:) = [];

                    % If we have visited this pixel, don't count it again. 
                    if evaluated(pos(1),pos(2),pos(3)) == 1
                        continue;
                    end

                    % Otherwise, check the pixel and store the position.
                    evaluated(pos(1),pos(2),pos(3)) = 1;
                    if size(arraypeak,2) == peaks
                        arraypeak{peaks}=[arraypeak{peaks},sub2ind([rows cols slices], pos(1), pos(2), pos(3))];
                    else
                        arraypeak{peaks}=sub2ind([rows cols slices], pos(1), pos(2), pos(3));
                    end

                    % Check the 26 neighbouring positions. 
                    % Stablish the positions.
                    [pos_y, pos_x, pos_z] = meshgrid(pos(2)-1:pos(2)+1, pos(1)-1:pos(1)+1, pos(3)-1:pos(3)+1);
                    pos_y = pos_y(:);
                    pos_x = pos_x(:);
                    pos_z = pos_z(:);

                    % Discard locations outside the matrix limits.
                    offlimits = pos_x < 1 | pos_x > rows | pos_y < 1 | pos_y > cols |pos_z < 1 | pos_z > slices;
                    pos_y(offlimits) = [];
                    pos_x(offlimits) = [];
                    pos_z(offlimits) = [];

                    % Discard locations already checked.
                    checked = evaluated(sub2ind([rows cols slices], pos_x, pos_y, pos_z));
                    pos_y(checked) = [];
                    pos_x(checked) = [];
                    pos_z(checked) = [];

                    % Add to 'candidate'.
                    candidate = [candidate; [pos_x pos_y pos_z]];
                end

                % Start with the new region
                peaks = peaks + 1;
            end
        end
    end
end

%//4. List of indexes (VOIs) and array_peaks
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

%//5. filtered_NMR
filtered_NMR = zeros(rows, cols, slices);
filtered_NMR(indexes)=NMR(indexes);

%//6. VOIcube
VOIcube = zeros(4,length(indexes));
for i=1:length(indexes)
    VOIcube(1,i) = NMR(indexes(i));
    [pos2, pos1, pos3]=ind2sub([cols rows slices], indexes(i));
    VOIcube(2,i) = ppm1(pos1);
    VOIcube(3,i) = ppm2(pos2);
    VOIcube(4,i) = ppm3(pos3);
end

toc
end
