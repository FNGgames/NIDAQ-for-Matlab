function NI_SignalGenerator(signal, sampleRate, duration, preview, log)
%   NI Signal Generator
%   generates arbitrary signals to send to NI analog output devices
% 
%   INPUTS:
%       signal - column vector of doubles, the signal you wish to generate
%       fs - sampling frequency of the signal
%       duration - duration in seconds of the generation
%           -1 = generate indefinately until stop button pressed
%           0 = generate the entire signal exactly once
%           >0 = generate for the specified number of seconds then stop
%       preview (bool) - show a plot of the signal before generating
%       log (bool) - write the signal to a text file

    % defaults
    if nargin < 5; log = true; else log = logical(log); end
    if nargin < 4; preview = true; else preview = logical(preview); end
    if nargin < 3; duration = 0; end
    if isvector(signal) && size(signal,2)>size(signal,1); 
        signal = signal';
    end
    repeat = duration ~= 0;

    % clear command window
    clc;
    fprintf('*** NI Signal Generator ***\n')

    % reset the daq drivers
    % find and add the first device on the system
    fprintf('\nFinding device ...')
    daq.reset;
    devices = daq.getDevices;
    device = devices(1);
    fprintf('\nCreating session ...')

    % create DAQ session
    session = daq.createSession('ni');
    session.Rate = sampleRate;
    session.IsContinuous = true; 
    elapsedTime = 0;

    % channels
    nChannels = size(signal, 2);
    for ch = 1:nChannels
        fprintf(['\nAdding Analog Output Channel (' num2str(ch-1) ') ...'])
        addAnalogOutputChannel(session, device.ID, ch-1, 'voltage');
    end
    % add listener
    lDataRequired = addlistener(session, 'DataRequired', @OnDataRequired);    

    % buffer the data
    fprintf('\nBuffering signal ...')
    sampleRate = ceil(sampleRate);
    bufferLength = sampleRate;     
    signalLength = size(signal, 1);
    while signalLength < 1000; 
        vertcat(signal, signal);
        signalLength = size(signal, 1);
    end    
    nBuffers = ceil(signalLength/bufferLength);
    dataBuffer = cell(nBuffers, 1);   
    for i = 1:nBuffers
        bufferStart = 1+(i-1)*bufferLength;
        bufferEnd = min(i*bufferLength, signalLength);
        dataBuffer{i} = signal(bufferStart:bufferEnd, :);
    end
    bufferIndex = 1;
    signalTime = (0:length(signal)-1)'*(1/sampleRate);

    % reset the voltage of the output channels to zero    
    outputSingleScan(session,zeros(1, nChannels));
    queueOutputData(session, dataBuffer{bufferIndex});    
    
    % create ui stop button
    if preview; PreviewSignal; end
    CreateStopButton;
    stopped = false;

    % create a file to log data  
    if log
        fprintf('\nCreating Log File ...')
        path = [fileparts(mfilename('fullpath')) filesep ...
            'Generator Logs' filesep];    
        filename = ['Generator Log ' ...
            datestr(now, 'yyyy-mm-dd HH-MM-SS') ...
            '.txt'];
        if ~exist(path, 'dir'); mkdir(path); end
        logfile = fopen ([path filename], 'wt+');
        fprintf(logfile, '%s\n', 'Generator Log');
        fprintf(logfile, '%s\n', datestr(now, 0));
        fprintf(logfile, '%d\n', sampleRate);
        fprintf(logfile, '%d\n\n', 1/sampleRate);
        fprintf(logfile, '%6.4f\n', signal);
        fclose(logfile);
    end
    
    % start the generation  
    dots = 1; fprintf('\n\nGenerating .');
    session.startBackground;
    while session.IsRunning && (duration <= 0 || elapsedTime < duration)
        pause(0.1); elapsedTime = elapsedTime + 0.1;
    end  
    
    % stop the generation and clean up
    Stop;
    delete(lDataRequired);
    delete(session);
    fprintf('\n\n*** Generation Complete ***\n\n') 
    

    %% SUBROUTINES %%

    %% queue data as it is requested by the device
    function OnDataRequired(s, ~, ~)           
        if stopped; return; end           
        queueOutputData(s, dataBuffer{bufferIndex});        
        bufferIndex = bufferIndex + 1;          
        if bufferIndex > length(dataBuffer); 
            if ~repeat; Stop; return; end
            bufferIndex = 1; 
        end        
        if dots<=4; fprintf('.'); dots = dots+1; else
            fprintf('\b\b\b\b'); dots = 1;
        end     
    end

    %% stop the active session and close open files and figures
    function Stop(~,~,~) 
        stopped = true;
        fclose('all');
        close all;
        stop(session);
        outputSingleScan(session,zeros(1,nChannels));
    end

    %% stop button
    function CreateStopButton   
        figurePos = [0.4 0.4 0.2 0.2];
        stopPos =[0.1 0.1 0.8 0.8];
        figure ( ...
            'Units', 'normalized', ...
            'OuterPosition', figurePos, ...
            'MenuBar', 'none', ...
            'Toolbar', 'none', ...
            'Name', 'CONTROLS', ...
            'NumberTitle', 'off' );
        uicontrol('Style', 'pushbutton', 'String', 'STOP',...
            'Units', 'normalized', ...
            'ForegroundColor', [1, 0 0], ...
            'FontWeight', 'bold', ...
            'FontSize', 12, ...
            'Position', stopPos,...
            'Callback', @Stop);   
        drawnow
    end

    %% signal preview
    function PreviewSignal
        figurePos = [0.2 0.2 0.6 0.6];
        figure( ...
            'Units', 'normalized', ...
            'OuterPosition', figurePos, ...
            'Name', 'Signal Preview', ...
            'NumberTitle', 'off');
        plot(signalTime, signal);
        drawnow
    end

end
