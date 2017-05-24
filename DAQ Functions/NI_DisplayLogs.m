function f = NI_DisplayLogs (logs, showSpectrum)
% Quickly display data acquired using the NI_Acquire function
%
%       logs: structure containing data logs
%           (use NI_ImportLogs to create the structure)
%       spectrum: (bool) show FFT

    if nargin < 2; showSpectrum = false; end
  
    % get log names from files
    names = cell(1,length(logs));
    for j=1:length(logs)
        names{j} = logs(j).name;
    end
    
    % prepare dialog to open logs
    [ind,check] = listdlg ( ...
        'PromptString', 'Select Log To Display', ...
        'ListSize', [300,300], ...
        'Name', 'Available Logs', ...
        'SelectionMode', 'single', ...
        'ListString', names ...
    ); 
    
    % make sure something was selected
    assert(logical(check), 'User did not select option')

    % select the chosen log from the array
    log = logs(ind);
    name = log.name;
    
    % start the figure
    f =  figure ('units','normalized','OuterPosition',[0 0 1 1]);
    
    % first pane
    if showSpectrum; subplot(2,1,1); end     
    hold on
    box on
    xlabel('Time (s)')
    ylabel('Amplitude (V)')      
    
    % plot the data
    time = log.time;
    data = log.data; 
    events = log.events;
    plot(time, data);
    
    % find the user events
    evtInds = find(log.events > 0);    
    yMin = min(min(data));
    yMax = max(max(data));
    yLabelPos = (yMax-yMin)/4;  
    
    % plot lines to mark user events
    for k=1:length(time(evtInds))
        plot([time(evtInds(k)), time(evtInds(k))], ...
            [yMin, yMax], ...
            'r-', 'MarkerFaceColor', [1 0 0]); 
        text(log.time(evtInds(k)), yMin+yLabelPos, ...
            [' evt ' num2str(events(evtInds(k)))]);
    end
    
    % set axis limits and title
    title(name)
    
    % show the fft of the signal below it
    if showSpectrum        
        subplot(2,1,2);   
        spectrum = NI_FFT(log);
        plot(spectrum(:,1),spectrum(:,2:end))
        title('Signal Spectrum')
        ylabel('Amplitude')
        xlabel('Frequency')
    end
    
    % set all the text in the figure to size 14
    set(findall(gcf,'type','text'),'FontSize',14)        

end
