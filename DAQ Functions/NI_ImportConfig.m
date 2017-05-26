function cfg = NI_ImportConfig()

cfgFileName = [fileparts(mfilename('fullpath')) '\settings.cfg']; 

if exist(cfgFileName, 'file')
    
    fmt = '%s%s%[^\n\r]';
    fid = fopen(cfgFileName, 'r');
    data = textscan(fid, fmt, 'delimiter', '\t');
    data = data{2};
    fclose(fid);

    cfg = struct;
    cfg.DeviceIndex = str2double(data{1});
    cfg.SubsystemIndex = str2double(data{2});
    cfg.Channels = string2mat(data{3});
    cfg.SampleRate = str2double(data{4});
    cfg.Duration = str2double(data{5});
    cfg.PreviewMode = str2double(data{6});
    cfg.LogName = data{7};
    cfg.LogDirectory = data{8};
    
else
   
    cfg = struct;
    cfg.DeviceIndex = 1;
    cfg.SubsystemIndex = 1;
    cfg.Channels = [1];
    cfg.SampleRate = 1000;
    cfg.Duration = 60;
    cfg.PreviewMode = 1;
    cfg.LogName = 'Data Log';
    cfg.LogDirectory = '';
    
end

function mat = string2mat(str)

str = strrep(str, '[', '');
str = strrep(str, ']', '');
mat = [];
if ~isempty(str)
    str = strsplit(str, ' ');
    for i=1:length(str)
        mat(i) = str2double(str{i}); %#ok<AGROW>
    end
end





