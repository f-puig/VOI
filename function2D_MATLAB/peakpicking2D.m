function [peak_pos]=peakpicking2D(array_peaks, filtered_NMR)
% INPUT VARIABLES
% array_peaks: cell array containing the list of VOIs. Each cell contains the VOIs for one cluster.
% filtered_NMR: the 2D NMR spectrum. The "filtered_NMR" spectrum generated
%   with the VOI2D function can also be used.

% OUTPUT VARIABLES
% peak_pos: the list of chemical shifts associated to each cluster. This variable
%   contains as many rows as peaks, and two columns. The first column contains the
%   chemical shifts in f1, while the second column contains the chemical
%   shifts in f2.

peak_pos=zeros(length(array_peaks),2);
NMRshort=filtered_NMR(2:end,2:end);
rows=size(NMRshort,1);
cols=size(NMRshort,2);

for i=1:length(array_peaks)
    pos_in_array=find(NMRshort(array_peaks{i})==max(NMRshort(array_peaks{i})),1,'first');
    [ind1,ind2] = ind2sub([rows, cols], array_peaks{i}(pos_in_array));
    peak_pos(i,1)= filtered_NMR(ind1+1,1);
    peak_pos(i,2)= filtered_NMR(1,ind2+1);
    
end
