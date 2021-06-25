function [file,Frames] = select_video

% SELECT_VIDEO
% Function that lets you select a video and a length to use in the
% analysis. This is done by using a UI.
% 
% SYNOPSIS:
% [file, Frames] = select_video
% 
%  
% OUTPUT:
%   - file (video file as imported by user)
%       The selected video file
%   - Frames (integer)
%       The number of frames of the video needed for the selected length
% 
% ------  Made by: Guus Frijters | Netherlands Forensic Institute(2021)-----

% UI for the selection of a video file
[file,path] = uigetfile('*.asf;*.asx;*.avi;*.m4v;*.mj2;*.mov;*.mp4;*.mpg;*.wmv;,*.3gp;','Select a video file');
    if isequal(file,0) 
        disp('User selected Cancel');
    else
        disp(['User selected ', fullfile(path,file)]);
    end
videoObject = VideoReader(file);

% UI for the selection of the video length
Time = inputdlg('Select the length for the video in minutes','Time selection');
sec = str2double(Time) * 60;

% Determining the amount of frames accompanying the video length
Frames = sec * videoObject.FrameRate;
    if Frames < videoObject.NumFrames
        Frames = round(Frames);
    else
        Frames = videoObject.NumFrames;
    end