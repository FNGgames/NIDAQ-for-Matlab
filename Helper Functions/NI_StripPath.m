function strippedPath = NI_StripPath( path, level )
% Get upper folder from path
%   path: original file path
%   level: how many folders to move up
%
%   StripPath ('C:\Users\Username\Documents\Matlab\MyFunction.m', 1)
%   returns: 'C:\Users\Username\Documents\Matlab\'
%
%   StripPath ('C:\Users\Username\Documents\Matlab\MyFunction.m', 2)
%   returns: 'C:\Users\Username\Documents\'
%
%   StripPath ('C:\Users\Username\Documents\Matlab\MyFunction.m', 3)
%   returns: 'C:\Users\Username\'
%
% etc...

    if nargin < 2; level = 1; end
    level = abs(level);
    strippedPath = fliplr (path);
    ind = strfind(strippedPath, filesep);
    if length(ind) <= 0; error('Invalid Path'); end
    level(level>length(ind)) = length(ind);
    ind = ind(level);    
    strippedPath = fliplr(strippedPath(ind+1:end));   
    
end

