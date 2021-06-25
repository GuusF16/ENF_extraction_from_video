% Vid_ENF_Time_Detection
%
% SYNOPSIS:
% 
% The overall codefile which uses different functions in order to estimate
% a time of recording for a input video with a given ENF date file. Can use
% different video types and is built around 2 ENF data types. Can be run
% without any need for inputs
%
% Functions needed:
%   - select_video.m
%       Used to select the video file
%   - get_ENF.m
%       Used to select the ENF file, either from TenneT or the NFI
%   - means.m
%       Used to calculate the Light Intensity Signal (LIS) for a vertical rolling
%       shutter
%   - ENF_from_Vid_D.m
%       Used to extract the ENF from the LIS, uses multiple subfunctions
%       - PeakPlot.m
%           Uses the FFT in order to find the frequency components and the
%           signal within
%       - STFT_peakVid.m
%           Short Time Fourier Transform to determine the ENF by instant
%           frequency estimation
%   - VisSig.m
%       Used to visualize the (user-)selected frequency component to
%       visualize with the ENF data signal
%
%------  Made by: Guus Frijters | Netherlands Forensic Institute(2021)-----

%% Clear all windows

clc;    % Clear the command window.
close all;  % Close all figures (except those of imtool.) 
imtool close all;  % Close all imtool figures.
clear;  % Erase all existing variables.
% clearvars -except ENF_Dat t_Dat ENF_name StartTime D L
workspace;  % Make sure the workspace panel is showing.

%% Load Video File
    [movie,NumF] = select_video;
    file_name = movie;

%% Load ENF Data File
     [ENF_Dat, t_Dat, ENF_name, StartTime, D, L] = get_ENF;
    
%% Calculate Light Intensity Signal
    txt = ['Creating mean gray values for video ' movie '...'];
    disp(txt);
    [meanGrayVid, t, Fs] = means(movie,NumF);
    disp('Mean gray values created')
    
%% Light Intensity Signal Plot
    disp('High pass filtering')
    meanGrayVidHP = highpass(meanGrayVid,10,Fs);
    
    figsamp = figure('Name', 'MeanGrayVid','WindowState', 'maximized');        
        axes1 = axes('Parent',figsamp);
        hold(axes1,'on');
        set(axes1,'FontSize',12);
        plot(t(1:0.5*end), meanGrayVid(1:0.5*end),'LineWidth',3, 'DisplayName', 'Light Intensity before High Pass filtering')
        hold on
        plot(t(0.5*end:end), meanGrayVidHP(0.5*end:end),'LineWidth',3, 'DisplayName', 'Light Intensity after High Pass filtering')
        legend1 = legend('show');
        set(legend1,'LineWidth',1,'Interpreter','none','FontSize',16);           
        grid on

        title('Light Intensity Signals','FontSize',20)
        xlabel('Time (s)','FontSize',18)
        ylabel('Gray Value','FontSize',18)

%% Gathering the ENF signal and match
    [ENF_Vid, t_Vid, TableFull] = ENF_from_Vid_D(movie, meanGrayVidHP, Fs, ENF_Dat', L, D, StartTime);
    
    % Saving te resulting data
    answer = questdlg('Save the results table?','Save Table','Yes','No','Yes');
    switch answer
        case 'Yes'
            disp('Saving file')
            oldfolder = cd;
            currDate = strrep(datestr(date), ':', '_');
            mkdir('Results',currDate)
            cd(['Results\',date])
            writetable(TableFull,file_name(1:end-4),'FileType', 'spreadsheet');
            cd(oldfolder);
            disp('File saved')
        case 'No'
            disp('Continueing without saving')
    end
    
%% Visualizing the result
    
    VisSig(ENF_Dat, ENF_name, ENF_Vid, file_name, StartTime, L);
