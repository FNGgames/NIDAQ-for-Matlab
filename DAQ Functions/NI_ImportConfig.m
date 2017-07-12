%% Import Settings File
function [cfg, raw] = NI_ImportConfig()

%% Initialize variables.
filename = [fileparts(mfilename('fullpath')) '\settings.cfg'];
assert(logical(exist(filename, 'file')), 'Configuration file not found');
delimiter = '\t';
startRow = 1;
endRow = inf;

%% Read columns of data as text
formatSpec = '%s%s%[^\n\r]';

%% Open the text file.
fileID = fopen(filename,'r');

%% Read columns of data according to the format.
dataArray = textscan(fileID, formatSpec, endRow(1)-startRow(1)+1, 'Delimiter', delimiter, 'HeaderLines', startRow(1)-1, 'ReturnOnError', false, 'EndOfLine', '\r\n');
for block=2:length(startRow)
    frewind(fileID);
    dataArrayBlock = textscan(fileID, formatSpec, endRow(block)-startRow(block)+1, 'Delimiter', delimiter, 'HeaderLines', startRow(block)-1, 'ReturnOnError', false, 'EndOfLine', '\r\n');
    for col=1:length(dataArray)
        dataArray{col} = [dataArray{col};dataArrayBlock{col}];
    end
end

%% Close the text file.
fclose(fileID);

%% Convert the contents of columns containing numeric text to numbers.
% Replace non-numeric text with NaN.
raw = repmat({''},length(dataArray{1}),length(dataArray)-1);
for col=1:length(dataArray)-1
    raw(1:length(dataArray{col}),col) = dataArray{col};
end
raw = raw(:,2)';

%% Create output struct
cfg = struct('SampleRate', str2double(raw{2}), ...
    'Duration', str2double(raw{3}), ...
    'PreviewMode', str2double(raw{4}), ...
    'LogName', raw{1}, ...
    'LogFolder', raw{5}, ...
    'SaveAsText', str2double(raw{6}));

end
