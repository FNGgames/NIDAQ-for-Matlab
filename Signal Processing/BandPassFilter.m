% BandPassFilter by D.Clarke
% Generic band-pass filter with maximal flatness. Operates on the
% FFT of the input signal, zeroing out terms that fall outside of 
% the pass-band. 
% 
% Input: 
%       signal: numeric vector
%       time: numeric vector with numel(time)==numel(signal)
%       lowCutoff: numeric scalar
%       highCutoff: numeric scalar where highCutoff>lowCutoff
%
% Output:
%       filteredSignal: numeric vector same size as input signal
%
% Notes:
%       requires a constant sample rate to function correctly
%       use 0 for lowCutoff to get an AC-Coupling filter
%
function filteredSignal = BandPassFilter( signal, time, lowCutoff, highCutoff)

    % check input
    assert(isvector(signal) && isnumeric(signal),...
        'Error: Input 1 (SIGNAL) must be numeric vector');
    assert(isvector(time) && isnumeric(time) && numel(time)==numel(signal), ...
        'Error: Input 2 (TIME) must be numeric vector with numel==numel(signal)');
    assert(isscalar(lowCutoff) && isnumeric(lowCutoff), ...
        'Error: Input 3 (LOWCUTOFF) must be numeric scalar');
    assert(isscalar(highCutoff) && isnumeric(highCutoff) && highCutoff > lowCutoff, ...
        'Error: Input 4 (HIGHCUTOFF) must be numeric scalar and larger than lowCutoff');

    % calculate sample rate from time channel
    % (assumes constant sample rate)
    fs = 1/mean(diff(time));   
    
    % get the size of the vector and transpose if needed
    nRows = size(signal,1); 
    if nRows==1; signal=signal'; end;
    
    % set filter parameters
    n = size(signal,1);
    ffo = round(lowCutoff * n / fs);
    ff1 = round(highCutoff * n / fs);
    
    % calculate the fft
    fb = fft(signal);    
    if lowCutoff == 0; ffo = -1; end;    
    
    % zero out the terms in the fft that are out of bandpass range
    fb([1:ffo+1 ff1+1:n-ff1+1 n-ffo+1:n],:) = ...
        zeros(size(fb([1:ffo+1 ff1+1:n-ff1+1 n-ffo+1:n],:)));
    
    % invert the fft and return the real component
    filteredSignal = real(ifft(fb));

end
