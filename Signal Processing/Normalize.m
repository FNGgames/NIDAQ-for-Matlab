function out = Normalize( data, independant ) 

if nargin < 2; independant = false; end

if size(data,1)<size(data,2); data=data'; end
nCols = size(data, 2);

out = data;

if independant
    for i = 1:nCols
        aData = abs(data(:,i));
        out(:,i) = (data(:,i)-min(aData))./(max(aData)-min(aData));    
    end
else    
    dmax = max(abs(data(:)));
    dmin = min(abs(data(:)));    
    for i = 1:nCols
        out(:,i) = (data(:,i)-dmin)./(dmax - dmin);    
    end    
end

assert(max(out(:))<=1, 'Max exceeds 1');



