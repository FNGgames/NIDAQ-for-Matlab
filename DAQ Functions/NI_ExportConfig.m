% Export the configuration to a text file
function NI_ExportConfig( cfg )
cfgFileName = [fileparts(mfilename('fullpath')) '\settings.cfg'];
fid = fopen(cfgFileName, 'w+');
fprintf(fid, 'Name\t%s\r\nFs\t%d\r\nDur\t%d\r\nPrev\t%d\r\nPath\t%s', ...
    cfg.LogName, cfg.SampleRate, cfg.Duration, cfg.PreviewMode, cfg.LogFolder ); 
fclose(fid);
end

