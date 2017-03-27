% AC couples a signal to bring the DC level to zero
function acc = ACCouple ( signal, time )

    % calculate sample rate from time channel
    % (assumes constant sample rate)
    fs = 1/mean(diff(time));   
    
    % get the size of the vector and transpose if needed
    [nRows,~] = size(signal);  
    if nRows==1; signal=signal'; end;
    
    % process the signal
    n = size(signal,1);
    ffo = round(0.05 * n / fs);
    ff1 = round(1000000000 * n / fs);
    fb = fft(signal);    
    fb([1:ffo+1 ff1+1:n-ff1+1 n-ffo+1:n],:) = ...
        zeros(size(fb([1:ffo+1 ff1+1:n-ff1+1 n-ffo+1:n],:)));
    
    % return
    acc = real(ifft(fb));

end