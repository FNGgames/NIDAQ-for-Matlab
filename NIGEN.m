% NIGEN
clear; clc; close all;

% find and load an audio file
[audiofilename, path] = uigetfile([pwd '\*.wav'], 'Select Audio File');
[Y, fs] = audioread([path filesep audiofilename]);

% normalize the file
Y = Y(:,1);
amplitude = 10;
Y = Normalize(Y)*amplitude;

% generate the sound from the NI device
NI_SignalGenerator(Y, fs, 0, true, false);



    
    







