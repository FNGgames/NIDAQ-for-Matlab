% Removes 50 or 60 hz noise from electrophys recordings. 
% Utilises a bandstop FIR filter
function humbucked = Humbucker (signal, time, stop, order)

    % apply defaults
    if nargin < 4; order = 10; end
    if nargin < 3; stop = 50; end
    if nargin < 2; error('Not enough input arguments'); end

    % calculate sample rate from time channel
    % (assumes constant sample rate)
    fs = 1/mean(diff(time));
    
    % get the nyquist rate (half the sample rate)
    f_nyquist = floor(fs/2);
    
    % normalise the stop frequency 
    fstop_normalised = stop / f_nyquist;    
    
    % get a range around that for the stop band
    stopband = [fstop_normalised * 0.8, fstop_normalised * 1.2];
    
    % design the bandstop FIR filter
    filter_spec = fir1(order, stopband, 'stop');
    
    % filter the signal
    humbucked = filter(filter_spec, 1, signal);    

end