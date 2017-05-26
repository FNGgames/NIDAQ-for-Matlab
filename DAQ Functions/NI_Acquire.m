function NI_Acquire (session, cfg)
% Starts data acquisition for a given NI daq session.
%
%   While data is logging you will have access to a gui for stopping the
%   acquisition and recording events into the data.
%
%   Events are also recorded when a number key is pressed (note the figure
%   has to be in focus for the key presses to work)
    
% update the configuration file
if nargin < 1; error('A Valid DAQ session is a required parameter'); end
if nargin < 2; cfg = NI_ImportConfig(); end

%% INITIALISE NEW LOG FILE
% get a filename for data logging and start a new file
logFullPath = [cfg.LogDirectory '\' cfg.LogName ' ' ...
    datestr(now, 'YYYY-mm-DD hh-MM-ss-fff.txt')];
logfile = fopen (logFullPath, 'wt+');
eventValue = 0;

% print file header 
fprintf (logfile, '%s\n', cfg.LogName);
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
if logical(cfg.PreviewMode)      

    % create a figure
    FF = figure(...
        'units','normalized',...
        'OuterPosition',[0.05 0.1 0.7 0.85],...
        'KeyPressFcn', @onKeyPress);
    grid on
    box on
    title('Data Preview')
    xlabel('Time Since Acquisition Start')
    ylabel('Voltage') 

    % only use pre-sized chart if isContinous is false
    if session.IsContinuous && cfg.PreviewMode > 2; 
        cfg.PreviewMode = 2; 
    end

    % chart or graph option?
    if cfg.PreviewMode >= 2
        nextPlot = 'add';
        % grow chart or start full size?
        if cfg.PreviewMode == 3; xlim([0, cfg.Duration]); end
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
ui = figure ( ...
    'OuterPosition', pos, ...
    'MenuBar', 'none', ...
    'Toolbar', 'none', ...
    'Name', 'STOP BUTTON', ...
    'NumberTitle', 'off', ...
    'KeyPressFcn', @onKeyPress);        

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
fprintf ('\n\tAcquiring Data ...\n\n');
session.startBackground;    
while session.IsRunning
    pause(1);            
end  

%% Cleanup 
close all
delete(lh);
if logical(cfg.PreviewMode); delete(ph); end
fclose('all');
fprintf('\n\n\tDAQ Complete.\n');

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
    fprintf('\n\tEvent %0.0f Registered.', evtIndex);
    if ishandle(FF)
        figure(FF);
        plot(DAQTime,DAQValue,'ro','markerfacecolor','r')
        text(DAQTime,DAQValue,[' EVT' num2str(evtIndex)])
    end
    figure(ui)
end

% callback for key presses
function onKeyPress(~, ~)
   key = get(gcf, 'CurrentCharacter');
   num = str2double(key);
   if isempty(num) || isnan(num) || num<1 || num>9; return; end
   onTriggerPressed(num);        
end

% function for printing error messages about input data type
function typeError (varstr, typestr)
   fprintf(['\n\nNI_Acquire: ' varstr ' argument invalid, '...
        'using default.\nArgument must be type ' upper(typestr) '.' ...
        '\nFor more information type: help NI_Acquire\n\n']); 
end

end
