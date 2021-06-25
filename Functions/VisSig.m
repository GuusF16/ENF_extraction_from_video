function VisSig(S1, Dat_file, S2, Vid_file, ST, L,t)

% VisSig
% Visualizing the signal by padding the video ENF in order to match up with
% the database ENF. Visual inspection can be done on the final plot
%
% SYNOPSIS:
% VisSig(S1, Dat_file, S2, Vid_file, ST, L)
%
% INPUT:
%   - S1 (double array with frequencies)
%       ENF from the data file
%   - Dat_file (charstring with the name of the data)
%       Name of the data file for visualization purposes
%   - S2 (double array with frequencies exported from the video)
%       ENF from the video file
%   - Vid-file (charstring with the name of the video)
%       Name of the video file for visualization purposes
%   - ST (duration with the starting time of the data)
%       Starting time of the ENF data file
%   - L (integer)
%       The time-step (in seconds) between two frames.
%
% OUTPUT:
%   A single figure for visual inspection
%
%------  Made by: Guus Frijters | Netherlands Forensic Institute(2021)-----

    % Transposing the data-signal for the correlation
    S1 = S1';
    
    % Cross correlating the database with the video
    C = normxcorr2(S2,S1);
       
    % Finding the maximum correlation
    [~, ts]  = max(abs(C));
    % Determining the time matching with the highest correlation
    high = C(ts);
    dT = ts - length(S2);
    T = seconds(dT*L);
    Sec = T + ST;
    Sec.Format = 'hh:mm:ss';
    % Printing the result for the user
    txt = ['The recording ' Vid_file ' took ' num2str(length(S2)*L) ' seconds and started at:' ];
    disp(txt) 
    disp(Sec)
    txt = ['The correlation at this time is ' num2str(high)];
    disp(txt)
    
    % Inverting the ENF in case of aliasing
    if high < 0
        S2 = (S2)*-1;
    end
    
    t0 = hours(ST); 
    % Creating a time axis for the ENF database
    t1 = linspace(0, L*length(S1),length(S1));
    t1 = t1./3600;
    t1 = t0 + t1;


    
    % Padding the video signal to line up correctly with the database signal
    S2p = padarray(S2', dT, mean(S2), 'pre');
    t2 = linspace(0, L*length(S2p),length(S2p));
    t2 = t2./3600;
    t2 = t0 + t2;


    % Setup figure range
    a = t0 + (dT*L)/3600;
    b = t0 + (dT*L+length(S2)*L)/3600;
    c = (0.5*length(S2)*L)/3600;
    
    disp('Visualizing the signals...')
    % Plotting the figure
    fig = figure('Name', 'Shifted Signals','WindowState', 'maximized');        
        axes1 = axes('Parent',fig);
        hold(axes1,'on');
        set(axes1,'FontSize',12);
        plot(t2, (S2p-mean(S2p)),'LineWidth',3, 'DisplayName', Vid_file)
        hold on
        plot(t1, (S1-mean(S1)),'LineWidth',3, 'DisplayName', Dat_file)
        legend1 = legend('show');
        set(legend1,'LineWidth',1,'Interpreter','none','FontSize',16);           
        grid on

        title('Signals shifted according to time estimation','FontSize',20)
        xlabel('Time (h)','FontSize',18)
        xlim([a-c b+c])
        ylabel('Frequency Variation (Hz)','FontSize',18)
end