function [E,t,file_name, ST, D, L] = get_ENF

% get_ENF
%   Import the ENF signal from a ENF data file (.csv or .xlsx). The
%   datafile can consist of multiple days of data. The option to select a
%   day is included. Can be used for NFI data, dependent on the format. The
%   second column should be the frequency, the fourth column time in
%   HH:MM:SS format.
% 
% SYNOPSIS:
%   ENF = get_ENF
% 
% OUTPUT:
%   - E (double array with frequencies)
%       The ENF pattern from the datafile
%   - t (double array with time indication)
%       The time axis from the datafile
%   - file_name (charstring with the name of the data)
%       The date from the datafile
%   - ST (duration with the starting time of the data)
%       Starting time of the ENF data, in case of the data not starting at
%       00:00
%   - D (integer)
%       Mulitplication factor in for the window used in the STFT
%   - L (integer)
%       Sampling rate (time-steps)
% 
% --------  Guus Frijters | Netherlands Forensic Institute --------


% GUI to select the ENF file, including the selection of the type,
% TenneT ENF (1 sample per 4 seconds) or NFI data (1 sample per ~second)
[file,~] = uigetfile('*.csv;*.xlsx;','Select a data file');

answer = questdlg('TenneT, NFI or other','ENF Type','TenneT','NFI', 'Other','TenneT');
    switch answer
        case 'TenneT'
            A = 1;
        case 'NFI'
            A = 2;
        case 'Other'
            A = 3;
    end

% Reading of the ENF file, for TenneT data
    if A == 1
        T = readtable(file);
        F = xlsread(file);

        lst = zeros(width(F),1);

        for i = 1:length(lst)
            a = (x2mdate(T.(i)(1), 0));
            lst(i,1) = a;
        end

        if width(F) > 1
            indx = listdlg('PromptString',{'Select the date of the database.',},'SelectionMode','single','ListString',datestr(lst));
        else 
            indx = 1;
        end
        
        file_name = 'TenneT ENF Data';
        E = T.(indx)((2:end),1);
        t = linspace(0,(86400),length(E));
        ST = seconds(0);

        % Multiplication factor for window size for the frequency estimation
        D = 2; 
        % Time-steps for the ENF data
        L = 4;
 
    % Reading of the ENF file, for NFI data    
    elseif A == 2
        file_name = 'NFI ENF data';
        F = xlsread(file);
        E = F(:,2);

        ST = timeofday(datetime((F(1,4)),'convertfrom','excel'));

        t = linspace(0,(length(E)-1),length(E));

        % Multiplication factor for window size for the frequency estimation
        D = 9; 
        % Time-steps for the ENF data
        L = 1.05403458213;
    % Reading of the ENF file, for other data-sources
    elseif A == 3
        file_name = 'Other ENF data'; 
        F = xlsread(file);
        E = F(:,1);
        
        t = linspace(0,(length(E)-1),length(E));
        % UI for selection of sample-rate
        answer = inputdlg('Seconds per sample','Fs of the ENF data');
        L = str2double(answer{1,1});
        D = round(10/L);
        
        ST = seconds(0);
end
