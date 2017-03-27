function NI_Acquire (session, duration, plotOption, logName, logFilename, logDirectory)
% Starts data acquisition for a given NI daq session.
%
% Input Params: 
%
%   session (required) - the DAQ session to be used.
%
%   duration (optional) - overrides the target duration of the session (in
%       seconds). Default is the currently configured session duration. 
%       Pass an empty string '' to use the session's default duration
%
%   plotOption (optional) - the type of preview plot:
%       0: no preview plot.
%       1: graph preview (shows the current input buffer only).
%       2: chart preview type 1 (shows all the data from the current 
%           acquisition in a chart that grows in width as more data is 
%           acquired).
%       3: chart preview type 2 (shows all the data in a chart that is
%           starts at the full width and gradually fills up).
%
%   logName (optional) - a unique name to identify the log. 
%       Pass an empty string to use the dafault name 'Data Log'.
%       Pass the string 'ui' to enter the name at a prompt
%
%   logFilename (optional) - the prefix for the filename of the log file.
%       Pass an empty string to use the default name 'Data Log'
%       Pass the string 'ui' to enter the name at a prompt
%       Pass the string 'same' to use the same name as the logName above
% 
%   logDirectory (optional) - 
%       Pass a path string for direct specification of a folder path
%       Pass an empty string to use the default directory
%       Pass the string 'ui' to enter the name at a prompt
%
%   while data is logging you will have access to a gui for stopping the
%   acquisition and recording events into the data.
%
%

    %% HANDLE INPUT
    % make sure a session is passed   
    assert (nargin > 0, 'Error: DAQ session is a required parameter');
    
    % apply log folder defaults
    if nargin < 6; logDirectory = ''; end
    if nargin < 5; logFilename = ''; end
    if nargin < 4; logName = ''; end   
    if nargin < 3; plotOption = 3; end
    if nargin < 2; duration = session.DurationInSeconds; end 
    
    % validate input
    if ~ischar(logDirectory) 
        typeError ('logDirectory', 'string');        
        logDirectory = '';
    end  
    if ~ischar(logFilename)
        typeError ('logFilename', 'string');
        logDirectory = '';
    end 
    if ~ischar(logName) 
        typeError ('logName', 'string');
        logDirectory = '';
    end 
    if ~isnumeric(plotOption) || plotOption < 0 || plotOption > 3             
        typeError ('plotOption', 'integer 0 to 3');
        plotOption = 3;
    end
    if ~isnumeric(duration)        
        typeError ('duration', 'numeric');
        duration = session.DurationInSeconds;
    end
    
    % cache the current session settings
    defaultDuration = session.DurationInSeconds;
    defaultContinuous = session.IsContinuous; 
    
    % check if an empty string is passed, if so set to default
    if isempty(duration); duration = session.DurationInSeconds; end  
    % validate duration and update IsContinous param on the session
    if duration <=0 || duration == inf    
        session.IsContinuous = true;        
    else 
        session.IsContinuous = false;
        session.DurationInSeconds = duration;
    end
    
    % provide ui if logname is passed as 'ui' or set default if empty
    if strcmpi (logName, 'ui')
        dlg = inputdlg('Enter Log Identifier', ...
            'Log Name', 1, {'Data Log'});
        logName = dlg{1};
    elseif isempty(logName)
        logName = 'Data Log';
    end
    
    % do the same for the log filename
    if strcmpi (logFilename, 'same')
        logFilename = logName;
    elseif strcmpi (logFilename, 'ui')
        dlg = inputdlg('Enter Log Filename', ...
            'Log File Name', 1, {'Data Log'});
        logFilename = dlg{1};
    elseif isempty(logFilename)
        logFilename = 'Data Log';
    end    
        
    % do the same for the log directory
    upperFolder = StripPath (mfilename ('fullpath'), 2);
    if strcmpi (logDirectory, 'ui')
        logDirectory = uigetdir (upperFolder);        
    elseif ischar (logDirectory) && exist(logDirectory, 'dir')                 
    else                
        path = upperFolder;        
        logDirectory = [path '\Data Logs'];
        if ~exist(logDirectory, 'dir')
            mkdir(logDirectory);
        end                 
    end
    addpath(genpath(logDirectory));
    
    
    %% INITIALISE NEW LOG FILE
    % get a filename for data logging and start a new file
    logFullPath = [logDirectory '\' logFilename ' ' ...
        datestr(now, 'YYYY-mm-DD hh-MM-ss-fff.txt')];
    logfile = fopen (logFullPath, 'wt+');
    eventValue = 0;

    % print file header 
    fprintf (logfile, '%s\n', logName);
    fprintf (logfile, '%s\n', datestr(now));
    fprintf (logfile, '%d\n\n', 1/session.Rate);   
    
    % print column headers
    n = length(session.Channels) + 1;
    fprintf (logfile, 'Time\tEvt');
    for jj=2:n;
        fprintf (logfile, ['\tCh' num2str(jj-1)]);
    end    
    
    %% ADD LISTENERS TO SESSION
    % add listener to session for data storage
    lh = addlistener (session, 'DataAvailable', @LogData);
    
    % add listener to session for preview plotting
    if logical(plotOption)         
        
        % create a figure
        FF = figure('units','normalized','OuterPosition',[0.05 0.1 0.7 0.85]);
        grid on
        box on
        title('Data Preview')
        xlabel('Time Since Acquisition Start')
        ylabel('Voltage') 
        
        % only use pre-sized chart if isContinous is false
        if session.IsContinuous && plotOption > 2; 
            plotOption = 2; 
        end
        
        % chart or graph option?
        if plotOption >= 2
            nextPlot = 'add';
            % grow chart or start full size?
            if plotOption == 3; xlim([0, duration]); end
        else
            % only display current DAQ buffer
            nextPlot = 'replacechildren';
        end
        
        % configure colors and plot behaviour
        lineColors = lines(n-1);
        set(gca, 'ColorOrder', lineColors, 'NextPlot', nextPlot);       
        
        % add the listener
        ph = addlistener (session, 'DataAvailable', @PlotData);
        
    end

    %% CREATE UI       
    scrn = get(0, 'ScreenSize');
    
    % create stop button
    h = 830;
    w = 200;
    pos = [scrn(3) - (w+50), scrn(4) - (h+50), w, h];
    btn = figure ( ...
        'OuterPosition', pos, ...
        'MenuBar', 'none', ...
        'Toolbar', 'none', ...
        'Name', 'STOP BUTTON', ...
        'NumberTitle', 'off' );        
     
    % setup stop button
    uicontrol('Style', 'pushbutton', 'String', 'STOP',...
        'ForegroundColor', [1, 0 0], ...
        'FontWeight', 'bold', ...
        'FontSize', 12, ...
        'Position', [20 h-130 150 60],...
        'Callback', @(~,~,~) stop(session)); 
    
    % set up trigger buttons
    for ii=1:9
        uicontrol('Style', 'pushbutton', 'String', ...
            ['Event ' num2str(ii)],...
            'Position', [20 h-150-(ii*65) 150 60], ...
            'Callback', @(~,~,~) onTriggerPressed(ii))
    end
    
    % store current time 
    DAQTime = 0;
    DAQValue = 0;

    %% Start DAQ
    fprintf ('\n\tDAQ Started. Target Duration: %d', session.DurationInSeconds);  
    fprintf ('\n\tAcquiring Data ...');
    session.startBackground;    
    while session.IsRunning
        pause(1);            
    end  
    
    %% Cleanup 
    % reset the session duration to default    
    session.IsContinuous = defaultContinuous; 
    if ~session.IsContinuous
        session.DurationInSeconds = defaultDuration;
    end   
    
    % finish acquisition 
    close all
    delete(lh);
    if logical(plotOption); delete(ph); end
    fclose('all');
    fprintf('\n\tDAQ Complete.\n');
    
    %% CALLBACKS
    % callback for logging data
    function LogData (~,evt)        
        for r = 1:length(evt.TimeStamps)
            fprintf (logfile, '\n%2.4f', evt.TimeStamps(r));
            fprintf (logfile, '\t%d', eventValue);
            fprintf (logfile, '\t%2.4f', evt.Data(r,:));
            if eventValue ~= 0; eventValue = 0; end            
        end   
        DAQTime = evt.TimeStamps(end);
        DAQValue = evt.Data(end);
    end
    
    % callback for previewing data
    function PlotData (~,evt) 
        if ~ishandle(FF); return; end
        figure(FF);
        plot(evt.TimeStamps, evt.Data);
    end

    % callback for event triggers
    function onTriggerPressed(evtIndex)
        eventValue = evtIndex;
        if ishandle(FF)
            figure(FF);
            plot(DAQTime,DAQValue,'ro','markerfacecolor','r')
            text(DAQTime,DAQValue,[' EVT' num2str(evtIndex)])
        end
    end

    % function for printing error messages about input data type
    function typeError (varstr, typestr)
       fprintf(['\n\nNI_Acquire: ' varstr ' argument invalid, '...
            'using default.\nArgument must be type ' upper(typestr) '.' ...
            '\nFor more information type: help NI_Acquire\n\n']); 
    end

end

