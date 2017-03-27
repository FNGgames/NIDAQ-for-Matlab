function A = NI_FFT( log, range, acc, showPlot )
    % Perform an FFT on a data log, returning the amplitude spectrum of the
    % signal. Option to ac-couple the data ignoring DC components
    if nargin < 4; showPlot = false; end
    if nargin < 3; acc = true; end  
    if nargin < 2; range = [0, 10000]; end

    % pull time and data channels from the log
    t = log.time;
    data = log.data;
    
    % AC-couple the data
    if acc
        for i=1:size(data,2)
            data(:,i) = BandPassFilter(data(:,i),t,10,10000);
        end
    end
    
    % calculate the sampling frequency
    dt = log.dt;
    fs = 1/dt;
    l = length(t);
    y = fft(data, [], 1);
    f = (fs/2)*linspace(0,1,(l/2)+1);
    if size(f,2)>size(f,1); f = f'; end
    
    % Compute the two-sided spectrum p2. Then compute the single-sided spectrum 
    % p1 based on p2 and the even-valued signal length l.
    p2 = abs(y/l);
    p1 = p2(1:floor(l/2+1),:);
    p1(2:end-1,:) = 2*p1(2:end-1,:);    
    
    % truncate to range
    ind = f >= range(1) & f <= range(2);
    f=f(ind,:);
    p1=p1(ind,:);
    
    % plot
    if showPlot
        figure;
        plot(f, p1)
        title(['FFT: ', log.name]);
        ylabel('Amplitude')
        xlabel('Frequency (Hz)')
        zoom('off')
        zoom('xon')
    end
    
    %return result    
    A = [f,p1];

end

