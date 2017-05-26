function logs = NI_ImportLogs(folder)   
% Imports the logs created by the NI_Acquire function. It called with no
% parameters, the function searches for the default log path (NIDAQ\Logs)
% if a folder path is passed it will import the logs from that path.
%
% if the function cannot resolve the path given, or if the string 'ui' is
% passed, the user will be asked to provide the log path through a ui
% selection.
%
% Logs are imported into an n x 1 array of structs where n is the number of
% log files in the specified folder. The structs contain fields for start
% time, dt, time axis, events and data.

    path = NI_StripPath (mfilename ('fullpath'), 2);
    
    if nargin == 0; folder = [path '\Logs']; end
    if ~logical(exist(folder, 'dir')) || strcmpi (folder, 'ui') 
        folder = uigetdir (pwd, 'Select Folder Containing Data Logs');
    end
    
    fileList = dir ([folder '\*.txt']);
    n = length (fileList);
    
    assert (n > 0, 'Error: No Log Files Found in Log Directory'); 
    logs(1:n) = struct; 
    
    for i=1:n;
        temp = importdata (fileList(i).name, '\t', 5); 
        logs(i).name = temp.textdata{1,1};
        logs(i).start = temp.textdata{2,1};
        logs(i).dt = str2double(temp.textdata{3,1});
        logs(i).time = temp.data(:,1);
        logs(i).events = temp.data(:,2);
        logs(i).data = temp.data(:,3:end);
    end 
    
    fprintf(1, '\nImported %d logs\n', n);

end

