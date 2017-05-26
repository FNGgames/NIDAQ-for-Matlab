function [session, device] = NI_CreateSession (cfg)
% Initialises a session interface for NI devices.
% print message
fprintf(1, 'DAQ Session Initialising ...\n');

% stop all currently running DAQ services
daq.reset;

% get the list of devices in the system   
devices = daq.getDevices;
if length(devices) <= 0; 
    error(['ERROR IN NI_CREATESESSION: No NI Device Detected - ' ...
        'Check power and cable connections to your device']);
end
device = devices(cfg.DeviceIndex);

% progress message
fprintf(1,['\n    Device ' device.ID ' - ' device.Model ' added to session']);

% create a hardware DAQ session
session = daq.createSession('ni');
nChannels = length(cfg.Channels);

% add the selected cfg.Channels
for i=1:nChannels
    addAnalogInputChannel(session, device.ID, cfg.Channels(i)-1, 'voltage');
    % progress message
    fprintf(1,['\n        Channel ' ...
        device.Subsystems(1).ChannelNames{cfg.Channels(i)} ...
        ' added to session'] );
end        

% set the sample rate
rateLimit = max(device.Subsystems(cfg.SubsystemIndex).RateLimit);
maxRatePer = floor(rateLimit/nChannels);

if cfg.SampleRate > maxRatePer
    fprintf(1, ['\n\n\tWARNING!'...
        '\n\tSpecified sample rate not supported by this device' ...
        '\n\tUsing Max Available Per-Channel Sample Rate'...
        '\n\t\tMax Rate: %d'...
        '\n\t\tNumber of channels: %d' ...
        '\n\t\tMax Per-Channel Rate: %d' ...
        '\n\t\tSpecified Rate: %d'], ...
        rateLimit, nChannels, maxRatePer, cfg.SampleRate);                
    session.Rate = maxRatePer;
else
    session.Rate = abs(cfg.SampleRate);
end        

% set the recording time for the session
if cfg.Duration <= 0
    session.IsContinuous = true;
else
    session.DurationInSeconds = cfg.Duration;
end  

% progress messages
fprintf(1, '\n\n\tSession Created');
fprintf(1, ['\n\t\tSample Rate: ' num2str(session.Rate)]);
fprintf(1, ['\n\t\tChannel Count: ' num2str(nChannels)]);        
if session.IsContinuous 
    fprintf(1, '\n\t\tContinuous Acquisition');
else
    fprintf(1, ['\n\t\tTarget Time: ' num2str(session.DurationInSeconds)]);
end
fprintf(1, '\n');

