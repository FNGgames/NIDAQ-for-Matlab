function NI_Cleanup(session)
% Cleans up the NI DAQ session and associated objects. Run after all DAQ
% operations are complete.

    close all
    fclose('all');
    delete(timerfind);
    stop(session);
    delete(session);
    
    fprintf(1, '\nSession cleaned up Successfully\n');

end

