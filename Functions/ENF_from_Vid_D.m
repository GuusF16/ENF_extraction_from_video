function [Y, T, TableFull] = ENF_from_Vid_D(movFile, meanGrayVid, Fs, ENF, L, D, StartTime)

% ENF_FROM_VID_D
% All functions needed to get a ENF signal from a video. Starting with the
% gray value creation of each frame of the video using the means-function.
% The grayvalues are filtered. After filtering the signals is comparred
% with all the ENF signal in order to get the best match possible from the
% video file. This is done by comparing the signals acquired from different
% frequencies with the ENF data. The highest correlation would be the best
% match.
% 
% SYNOPSIS:
% [Y, T, TableFull] = ENF_from_Vid_D(movFile, meanGrayVid, Fs, ENF, L, D, StartTime)
% 
% INPUT:
%   - movFile (video file as imported from select_video)
%       The input video file
%   - meanGrayVid (double array with gray values)
%       Light Intensity Signal for the input video
%   - Fs (integer)
%       Sample frequency of the Light Intensity Signal
%   - ENF (double array with frequencies)
%       The ENF data from a database.
%   - L (integer)
%       The time-step (in seconds) between two frames.
%   - D  (integer)
%       Multiplication factor. Each frame will be of length L*D seconds.
%   - StartTime (duration with the starting time of the data)
%       The StartTime of the ENF data
% 
% OUTPUT:
%   - Y (double array with frequencies exported from the video)
%       ENF signal extracted from the video file 
%   - T (double array with time indication for the ENF)
%        Time axis accompanying the ENF signal from the video file
%   - TableFull (table with results with different correlations)
%       Elaborate table with all results from the video comparison. The
%       different frequencies show the correlation at different times.
% 
% 
% ------  Made by: Guus Frijters | Netherlands Forensic Institute(2021)-----

    % Selecting the FPS
    videoObject = VideoReader(movFile);
    FR = videoObject.FrameRate;
    
    % Applying the function to find all the possible ENF patterns
    disp('Finding maximum correlation...')
    [tabfull] = PeakPlot(meanGrayVid, FR, Fs, ENF, StartTime, L, D);

    % Creating the results-table
    TableFull = table('Size', [0 5], 'VariableTypes', {'double', 'double', 'duration','double','double'}, 'VariableNames', {'Peak', 'Correlation', 'Time','RunTime','SampleTime'});
    
    for i = 1:length(tabfull(:,1))-1
        if tabfull(i,2) > 0.4
            S = hours(tabfull(i,3));
            S.Format = 'hh:mm:ss';
            TableFull(end+1, {'Peak', 'Correlation', 'Time','RunTime','SampleTime'}) = {tabfull(i,1), tabfull(i,2), S, 0, 0};
        end
    end
    
    TableFull(1,{'RunTime', 'SampleTime'}) = {tabfull(end,1), tabfull(end,2)};
    
    % Sorting highest to lowest for selection of the visualization
    TopR = topkrows(TableFull,10,{'Correlation'}); %TOP X
    lst = strings(height(TopR),1);
    for i = 1:length(lst)
      txt = ['At ', num2str(TopR{i,1}), ' Hz the correlation is ', num2str(TopR{i,2}), ' for time estimation: ', datestr(TopR{i,3},'HH:MM:SS')];
      lst(i,1) = (txt);
    end

    % Selecting the value to visualize with the ENF signal
    indx = listdlg('PromptString',{'Select the result to visualize',},'ListSize',[400,100],'SelectionMode','single','ListString',lst);
    i = indx;
    x = TopR{i,1};

    l = (x-0.2);
    h = (x+0.2);

    % Rerunning for the selected frequency to visualize
    disp('Filtering')
    FiltVid = bandpass(meanGrayVid,[l h],Fs,'ImpulseResponse','iir','Steepness',0.85);

    Y = STFT_peakVid(FiltVid',Fs,L,D,4,x);
    Y = filloutliers(Y,'linear','mean');
    Y = Y(2:end);

    T = linspace(0, L*length(Y),length(Y));
    
    % Plotting the final ENF of the questioned video
    figenf = figure('Name', 'ENF from video','WindowState', 'maximized');        
 
        axes1 = axes('Parent',figenf);
        hold(axes1,'on');
        set(axes1,'FontSize',12);
        plot(T, Y,'LineWidth',3, 'DisplayName', 'ENF signal around specified frequency')
        legend1 = legend('show');
        set(legend1,'LineWidth',1,'Interpreter','none','FontSize',16);           
        grid on

        title('Electric Network Frequency from video','FontSize',20)
        xlabel('Time (s)','FontSize',18)
        ylabel('F (Hz)','FontSize',18)

end