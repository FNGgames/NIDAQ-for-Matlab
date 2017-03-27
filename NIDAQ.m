% clear Workspace
clear; clc; close all

% set up UI to allow user to select DAQ settings
Cfg = NI_ConfigureSession;

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
%       session - the session object that was crea  ted
%       device - the NI device that was chosen
S = NI_CreateSession (Cfg.SampleRate, Cfg.Duration); 

% Acquire data from NI devices 
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
NI_Acquire (S, Cfg.Duration, Cfg.PreviewMode, Cfg.LogName, 'same', 'ui');

% Cleans up the NI DAQ session and associated objects. Run after all DAQ
% operations are complete.
NI_Cleanup(S);

















