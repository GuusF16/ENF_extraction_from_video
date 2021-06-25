function [meanGrayVid, t, Fs] = means(video,numframe)

% MEANS
% Function to calculte the mean gray value for each seperate row of a
% video. This is done per row for the rolling shutter effect. The average
% gray value is calculated per row. This is done for each frame of the
% video. This results in a 'signal' that indicates the gray value of each
% row of each frame. This will show a potential light difference in a
% video. With the rolling shutter, light is captures row*framerate per
% seconds. This results in a new framerate high enough to visualize a 50Hz
% signal such as the ENF
% 
% SYNOPSIS:
% [meanGrayVid, t, Fs] = means(video, numframe)
% 
% INPUT:
%   - video (video file as imported from select_video)
%       The video from which the gray signal will be calculated
%   - numframes (integer)
%       The amount of frames that will be analyzed. This can create a
%       shorter video than the original video length.
% 
% 
% OUTPUT:
%   - meanGrayVid (double array with gray values)
%       The output gray signal of the input video
%   - t (double array with time indication)
%       The time-axis accompanying the gray signal
%   - Fs (integer)
%       The sampling frequency of the gray signal
% ------  Made by: Guus Frijters | Netherlands Forensic Institute(2021)-----


    % Read all information from the video
    videoObject = VideoReader(video);
    numberOfFrames = numframe;
    vidWidth = videoObject.Width;

    % Transform each frame to gray-value and calculate the average gray value
    % for each column

    meanGrayVid = zeros(numberOfFrames * vidWidth, 1);
    b = 0;
    h = waitbar(0,'Calculating mean gray values','name','means.m');
        for frame = 1 : numberOfFrames
            thisFrame = read(videoObject, frame);
            grayImage = rgb2gray(thisFrame);
            for Width = 1 : vidWidth 
                Column = grayImage(:, Width);
                meanGrayVid(b + Width) = mean(Column);
            end
            b = b + vidWidth;
            waitbar(frame/numberOfFrames) 
        end
    close(h)
    % Create a time axis as well as the sampling frequency
    Fs = videoObject.FrameRate * vidWidth;
    t = (0:length(meanGrayVid)-1)/Fs;

end