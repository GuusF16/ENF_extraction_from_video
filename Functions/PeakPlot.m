function [tabfull] = PeakPlot(X,FR,Fs,ENF, StartTime, L, D)

% PEAKPLOT
% Function that first creates a FFT of the input signal. From this FFT a
% heigth-threshold can be chosen. All FFT peaks above this height will be
% used in the analysis. For the analysis, the signal present around a
% certain frequency will be extracted and matched against the input ENF
% data. The correlation will be calculated after which a time estimation is
% done. This is saved in a elaborate table. The highest correlation is
% saved in a small table.
% 
% SYNOPSIS:
% [tabfull] = PeakPlot(X, FR, Fs, ENF, StartTime, L, D)
% 
% INPUT:
%   - X (double array with frequencies exported from the video)
%       Input signal extracted from a video
%   - FR (integer)
%       FrameRate of the input video
%   - Fs (integer)
%        Sampling frequency of the input signal
%   - ENF (double array with frequencies)
%       ENF data to be matched with the input signal
%   - StartTime (duration with the starting time of the data)
%       The StartTime of the ENF data
%   - L (integer)
%       The time-step (in seconds) between two frames.
%   - D  (integer)
%       Multiplication factor. Each frame will be of length L*D seconds.
%  
% OUTPUT:
%   - tabfull (table with results with different correlations)
%       Large table containing all correlations at different times for all
%       the peaks above a certain threshold
% 
% ------  Made by: Guus Frijters | Netherlands Forensic Institute(2021)-----

    % Setting up the FFT
    Lx = length(X);
    Y = fft(X);
    Y = Y(5:end);
    
    P2 = abs(Y/Lx);
    P1 = P2(1:Lx/2+1);
    P1(2:end-1) = 2*P1(2:end-1);

    f = Fs*(0:(Lx/2))/Lx;

    % UI for selecting the frequency range of interest
    txt1 = ('Select frequency region of interest (lower bound)');
    txt2 = ('Select frequency region of interest (upper bound)');
    
    answer = inputdlg({txt1, txt2},'frequency region of interest');
    lf = str2double(answer{1,1});
    hf = str2double(answer{2,1});

    % Removing the frequency outside the range of interest
    c = 1;
    for i = 1:length(f)
        if f(:,i) > lf && f(:,i) < hf
            fz(:,c) = f(:,i);
            P1z(c,:) = P1(i,:);
            c = c+1;
        end
    end
    
    % Removing the FPS-frequencies
    for i = 1:length(fz)
        for z = 1:1:4
            if fz(:,i) > z*FR - 1 && fz(:,i) < z*FR + 1
                P1z(i,:) = 0;
            end
        end
    end
    
    % Setting a zoom-factor
    Z = 1;
    phans = [];

    % Full FFT
    figFFT = figure('Name', 'FFT','WindowState', 'maximized');        
 
        axes1 = axes('Parent',figFFT);
        hold(axes1,'on');
        set(axes1,'FontSize',12);
        axis([0 200 0 1])
        plot(f, P1,'LineWidth',3)    
        grid on
        title('Single sided frequency spectrum','FontSize',20)
        xlabel('Frequency (Hz)','FontSize',18)
        ylabel('|Power(f)|','FontSize',18)    

    % Changing FFT to select the threshold
    while isempty(phans) == 1
        figure('Name', 'FFT','WindowState', 'maximized');
        plot(fz,P1z)
        axis([lf-10 hf+10 0 Z])
        title('Single-Sided Amplitude Spectrum of Mean gray value(t)')
        xlabel('f (Hz)')
        ylabel('|P1(f)|')
        grid on

        phans = inputdlg('Minimal Peak Height (select cancel to zoom in)','Peak finder');

        Z = Z/10;
        close
    end
    % The threshold for peak selection
    ph = str2double(phans{1,1});
    txt = ['Finding peaks above ', num2str(ph)];
    disp(txt)
    % Finding all the frequency peaks to search for the ENF
    [~,x]=findpeaks(P1z,fz,'MinPeakDistance', 0.1, 'MinPeakHeight',ph);

    tabfull = zeros(width(x),3);
    tic
    % Creating the ENF for all the seperate frequency-peaks
    parfor i = 1:width(x)
        % Upper and lower bound for the ENF signal
        l = x(1,i) - 0.2;
        h = x(1,i) + 0.2;
        
        % Bandpassing the signal
        Xf = bandpass(X, [l h], Fs,'ImpulseResponse','iir','Steepness',0.85);
        % Transpose if necessary
        if width(Xf) == 1
            Xf = Xf';
        end   
        
        % Performng the STFT to find the ENF
        Y = gather(gpuArray(STFT_peakVid(Xf,Fs,L,D,4,(x(1,i)))));
        % Remove the outliers
        Y = filloutliers(Y,'linear','mean');

        % Transpose if necessary
        if width(Y) == 1
            Y = Y';
        end
 
        % Correlate the database ENF with the video ENF to find the highest correlation
        if length(ENF) > length(Y)
            C = gather(gpuArray(normxcorr2(Y, ENF)));
        else
            C = gather(gpuArray(normxcorr2(ENF,Y)));
        end

        [~, T]  = max(abs(C)); 
        M = C(T);
        % Transform the highest correlation to the starting time      
        dT = T - length(Y);
        Sec = seconds((dT)*L);
        Sec = Sec + StartTime;
        Sec.Format = 'hh:mm:ss';

        % Saving the results in the table
        tabfull(i,:) = [x(1,i),abs(M),hours(Sec)];
    end
    % Adding the run-time to the table
    Et = toc
    tabfull(end+1,[1,2]) = [Et,L];
end
