function F = STFT_peakVid(in,Fs,L,D,b,x)

% STFT_PEAK
%   Calculate Short Time Fourier Transform of a signal and estimate the 
%   peak frequency for each frame.
% 
% SYNOPSIS:
%   F = STFT(in, Fs, L, D, b, x)
% 
% INPUT:
%   - in (double array with gray values around a specific frequency)
%       Input signal.
%   - Fs (integer)
%       Sampling frequency of <in>.
%   - L (integer)
%       The time-step (in seconds) between two frames.
%   - D (integer)
%       Multiplication factor. Each frame will be of length L*D seconds.
%   - b (integer)
%       Zeropadding factor. For each frame an N-point FFT is calculated,
%       with N = Fs*L*D*b -> rounded to the nearest higher power of 2.
%   - x (integer)
%       Frequency around which the variaton will be looked for
% 
% OUTPUT:
%   - F (double array with a frequency pattern)
%       A vector of peak frequencies. For each frame the peak frequency is
%       estimated by quadratic interpolation around the log-power spectral
%       bin with maximum magnitude.
% 
% 
% -------- (c) Maarten Huijbregtse | Netherlands Forensic Institute --------
% ---- Edit made by: Guus Frijters | Netherlands Forensic Institute(2021)---

% Frame length (in samples)
LF = floor(Fs*L*D);
% Step between frames (in samples)
LS = Fs*L;
% Total number of frames
J = ceil((length(in)-(LF-1))/(LS));

% FFT size
p = nextpow2(LF*b);
N = 2^p;

% Assuming the input signal is real, take only positive frequencies up to
% 1/2*Fs into account
NumUniquePts = ceil((N+1)/2);
Freqs = (0:(NumUniquePts-1))*Fs/(N);
% Isolate ENF region of interest (0.4 Hz around x)
low = x - 0.2;
high = x + 0.2;

FROI = find( ((Freqs>low) & (Freqs<high)) );

% Estimate peak frequencies
F = zeros(1,J);

h = waitbar(0,'Estimating peak frequencies','name','STFT_peak.m');
parfor i = 1:J
%-------------------------------- FFT -------------------------------------
    % Isolate frame number i
    X = in(floor((i-1)*LS+1):(floor((i-1)*LS+LF)));
        
    % Calculate magnitude FFT spectrum
    FX = abs( fft(X,N) );
    
    % Keep only the part corresponding to <Freqs>
    FX = 2*FX(1:NumUniquePts);
    FX(1) = FX(1)/2;
    FX(length(FX)) = FX(length(FX))/2;
    
    % Turn into log-power spectrum
    S = 20*log10(FX);
%------------------------------ END FFT -----------------------------------

%------------------------ PEAK INTERPOLATION ------------------------------
    % Zoom in on the ENF region of interest
    ROI = S(FROI);
    % <ROI> extended with appending values
    ROIext = [S(FROI(1)-1) ROI S(FROI(length(FROI))+1)];
    
    % Take difference to locate extremes -> extreme at location k if 
    % sign(DS(k)) ~= sign(DS(k-1))
    DS = diff(ROIext);
    DS(DS > 0) = 1;
    DS(DS < 0) = -1;
    % Take second difference to locate only maxima -> maximum if DS2 < 0
    DS2 = diff(DS);
    loc = find(DS2 < 0);
    % If DS2(k) < 0, then ROI(k) is a local maximum -> find global maximum
    RL = max(ROI(loc));
    if length(RL) ~= 0
        mx = find(ROI == RL);
    else
        % If no maximum is present, just take the location of the maximum 
        % value.
        mx = find(ROI == max(ROI));
    end
    
    % Quadratic interpolation to refine global maximum
    A = ROIext(mx);
    B = ROIext(mx+1);
    C = ROIext(mx+2);
    
    P = 1/2*(A-C)/(A-2*B+C);
    
    % Find corresponding frequency
    Floc = FROI(1)+mx+P-1;
    F(i) = (Fs/2)*(Floc-1)/(length(Freqs)-1);
%---------------------- END PEAK INTERPOLATION ----------------------------
    
    waitbar(i/J)
end
close(h);
