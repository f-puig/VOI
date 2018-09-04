function [integrals]=integral2D(array_peaks, filtered_NMR)
% INPUT VARIABLES
% array_peaks: cell array containing the list of VOIs. Each cell contains the VOIs for one cluster.
% filtered_NMR: the 2D NMR spectrum. The "filtered_NMR" spectrum generated
% with the VOI2D function can also be used.

% OUTPUT VARIABLES
% integrals: the vector of integrals for the peaks defined by 'array_peaks' cell array.

NMRshort=filtered_NMR(2:end,2:end);
integrals=zeros(1,length(array_peaks));
for i=1:length(array_peaks)
integrals(i)=sum(NMRshort(array_peaks{i}));
end
