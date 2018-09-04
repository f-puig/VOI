function structureNMR2 = interp2D(structureNMR, ref)
% INPUT VARIABLES
% structureNMR: a structure that contains all the original 2D NMR spectra.
% For every 2D NMR spectra, first row and column include ppm values.
% ref: the reference spectrum that contains the ppm values used. If this
% parameter is left blank, then the first sample is picked.

% OUTPUT VARIABLES
% structureNMR2: the same structure as structureNMR, but ppm1 and ppm2 axis
% for all samples are identical.

if (nargin < 2);
    ref = 1;
end

S=fieldnames(structureNMR);
numspec = length(S);
list_spec = setdiff(1:numspec,ref);
structureNMR2 = structureNMR;
for i=1:(numspec-1)
    structureNMR2.(S{list_spec(i)})(2:end,2:end) = interp2(structureNMR.(S{list_spec(i)})(1,2:end),structureNMR.(S{list_spec(i)})(2:end,1),structureNMR.(S{list_spec(i)})(2:end,2:end),structureNMR.(S{ref})(1,2:end),structureNMR.(S{ref})(2:end,1));
end

end
