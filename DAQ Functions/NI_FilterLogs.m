function filteredLogs = NI_FilterLogs( logs, filterType, param1, param2 )
% Runs log data through a filter
%   logs: the data logs to be filtered
%   filterType: 
%       1: AC Coupling filter
%       2: Humbucker (50/60hz band stop)
%       3: Band Pass Fitler
%   param1: 
%       if filtertype == 1, no effect
%       if filtertype == 2, stop band (50 or 60)
%       if filtertype == 3, low cutoff frequency (hz)
%   param2
%       if filtertype == 1, no effect
%       if filtertype == 2, filter order
%       if filtertype == 3, high cutoff frequency (hz)
%   
    filteredLogs = logs;
    
    for i = 1 : length(logs)        
               
        switch filterType            
            case 1
                filt = 'ACCouple';
                params = ' (logs(i).data, logs(i).time)';           
            case 2
                filt = ' Humbucker';
                params = '(logs(i).data, logs(i).time';
                if nargin > 2; params = [params ', param1']; end 
                if nargin > 3; params = [params ', param2']; end      
                params = [params ')'];                
            case 3
                filt = 'BandPassFilter';
                params = ' (logs(i).data, logs(i).time';
                if nargin > 2; params = [params ', param1']; end
                if nargin > 3; params = [params ', param2']; end      
                params = [params ')'];  
        end 
        
        eval (['filteredLogs(i).data = ' filt params ';']);            
        
    end  
    
    %#ok<*VUNUS>
    %#ok<*AGROW>

end

