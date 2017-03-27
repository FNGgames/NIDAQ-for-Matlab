function [session, device] = NI_CreateSession (sampleRate, defaultRecordingTime)
% Initialises a session interface for NI devices. A Labview-like UI
% provides device and channel selection.
%
%   Input Params: 
%
%       sampleRate (optional) - the sampling frequency of the session
%           Default: 1kHz
%       defaultRecordingTime - the length of each acquistion operation in
%           seconds. Default: 10s. Enter 0 for continuous recording.
%           This can be overridden in the NI_Acquire function.
%
%   Output:
%
%       session - the session object that was created
%       device - the NI device that was chosen

    % print message
    fprintf(1, 'DAQ Session Initialising ...\n');
    
    % handle input
    if nargin < 2; defaultRecordingTime = 10; end
    if nargin < 1; sampleRate = 1000; end

    % stop all currently running DAQ services
    daq.reset;

    % get the list of devices in the system   
    devices = daq.getDevices;
    if length(devices) <= 0; 
        error(['ERROR IN NI_CREATESESSION: No NI Device Detected - ' ...
            'Check power and cable connections to your device']);
    end

    % get the names of those devices
    deviceNames = cell(length(devices), 1);
    for i=1:length(devices)
        deviceNames{i} = [devices(i).ID ' - ' devices(i).Model];
    end

    % display a dialog for the user to select a device
    [deviceIndex,check] = listdlg ( ...
        'PromptString', 'Select Device', ...
        'ListSize', [300,300], ...
        'Name', 'Available NI DAQ Devices', ...
        'SelectionMode', 'single', ...
        'ListString', deviceNames );  

    % check that correct input is given and cache the device
    assert(logical(check), 'Error: No Item Selected');
    assert(isscalar(deviceIndex), 'Error: Multiple devices are not allowed');
    device = devices(deviceIndex);

    % display a dialog for the user to select channels
    [channels, check] = listdlg ( ...
        'PromptString', 'Select Channels', ...
        'ListSize', [300,300], ...
        'Name', [device.ID ' - ' device.Model], ...
        'ListString', device.Subsystems(1).ChannelNames );

    % check that a selection has been made
    assert(logical(check), 'Error, No Channels Selected');

    % progress message
    fprintf(1,['\n    Device ' device.ID ' - ' device.Model ' added to session']);

    % create a hardward DAQ session
    session = daq.createSession('ni');

    % add the selected channels
    for i=1:length(channels)
        addAnalogInputChannel(session, device.ID, channels(i)-1, 'voltage');
        % progress message
        fprintf(1,['\n        Channel ' ...
            device.Subsystems(1).ChannelNames{channels(i)} ...
            ' added to session'] );
    end        

    % set the sample rate
    if sampleRate < device.Subsystems(1).RateLimit(1) || sampleRate > device.Subsystems(1).RateLimit(2);
        fprintf(1, ['\n\nSpecified sample rate not supported by this device' ...
            '\nDevice: ' device.ID ' - ' device.Model ...
            '\nMax Rate: %d\n Default Rate: %d\n'], ...
            device.Subsystems(1).RateLimit(2), 1000);                
        session.Rate = 1000;
    else
        session.Rate = abs(sampleRate);
    end        

    % set the recording time for the session
    if defaultRecordingTime <= 0
        session.IsContinuous = true;
    else
        session.DurationInSeconds = defaultRecordingTime;
    end  

    % progress messages
    fprintf(1, '\n\n\tSession Created');
    fprintf(1, ['\n\t\tSample Rate: ' num2str(session.Rate)]);
    fprintf(1, ['\n\t\tChannel Count: ' num2str(length(channels))]);        
    if session.IsContinuous 
        fprintf(1, '\n\t\tContinuous Acquisition');
    else
        fprintf(1, ['\n\t\tTarget Time: ' num2str(defaultRecordingTime)]);
    end
    fprintf(1, '\n');

end

