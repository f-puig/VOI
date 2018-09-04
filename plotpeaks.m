function plotpeaks(structureNMR, array_peaks_common, list_peaks, thresh, ref)
% INPUT VARIABLES
% structureNMR: a structure that contains all the original 2D NMR spectra.
%   For every 2D NMR spectra, first row and column include ppm values.
% array_peaks_common: it contains the list of independent clusters of VOI variables.
% list_peaks: the index of the peaks to be plotted.
% thresh: minimal threshold intensity for plotting. It must be a number or left blank.
%   If it is not specified, only negative intensities will be
%   filtered.
% ref: reference spectrum to perform peak-picking, if it is not used, then
%   the first sample will be the reference spectrum.

if (nargin < 5);
    ref = 1;
end
if (nargin < 4);
    thresh = 'default';
end

peak_length=zeros(length(array_peaks_common),2);
S=fieldnames(structureNMR);
ppm2=structureNMR.(S{1})(1,2:end);
ppm1=structureNMR.(S{1})(2:end,1);
rows=length(ppm1);
cols=length(ppm2);

[peak_pos] = peakpicking2D(array_peaks_common, structureNMR.(S{ref}));

for i=1:length(list_peaks)
    region=[];
    pos=array_peaks_common{i};
    [ind1,ind2] = ind2sub([rows, cols], array_peaks_common{list_peaks(i)});
    min_ind1 = min(ind1);
    min_ind2 = min(ind2);
    max_ind1 = max(ind1);
    max_ind2 = max(ind2);
    subplot(1,length(list_peaks),i)
    for j=1:length(S)
        region_small = zeros(length(min_ind1:max_ind1),length(min_ind2:max_ind2));
        for k=1:length(ind1);
            region_small(ind1(k)+1-min_ind1,ind2(k)+1-min_ind2)=structureNMR.(S{j})(ind1(k)+1,ind2(k)+1);
        end
        region = [region;region_small];
    end
    
    if isnumeric(thresh)
        region(region<thresh)=0;
    elseif strcmp(thresh,'default')
        region(region<0)=0;
    end
    
    contour(ppm2(min_ind2+1:max_ind2+1),1:size(region,1),region)
    set(gca,'xdir','reverse')
    xlabel({sprintf('Peak %d',list_peaks(i)),sprintf('H = %0.2f',peak_pos(list_peaks(i),2)),sprintf('C = %0.2f',peak_pos(list_peaks(i),1))})
    hline={};
    if i==1
        ylabel('Samples')
        ytickss = ((max_ind1-min_ind1+1)*(1:length(S)))-((max_ind1-min_ind1+1)/2);
        yticks(ytickss);
        yticklabels(S);
    else
        set(gca,'ytick',[])
        set(gca,'yticklabel',[])
    end
    for j=1:length(S)
        hline{j} = refline([0,((size(region,1)-1)/length(S))*j+1]);
        hline{j}.Color = 'k';
    end
    ylim([1, size(region,1)])
    set(gca,'ydir','reverse')
end

end