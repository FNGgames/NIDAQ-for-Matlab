% import the logs
clear; clc; close all;

% import the logs from a folder
Logs = NI_ImportLogs();

% display the logs
F = NI_DisplayLogs(Logs, true); 
 

