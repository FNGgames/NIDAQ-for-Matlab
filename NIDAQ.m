% clear workspace
clear; clc; close all

% configure the session
cfg = NI_ConfigureSession;

% create the session according to the configuration
[session, device] = NI_CreateSession(cfg);

% do data acquisition
NI_Acquire(session, cfg);

% cleanup the session once we're done
NI_Cleanup(session);

















