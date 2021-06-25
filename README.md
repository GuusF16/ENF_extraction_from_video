# ENF_extraction_from_video

Vid_ENF_Time_Detection.m is the MATLab program written with the paper “The use of Electric Network Frequency presence in video material for time estimation”

To run the full program, simply run Vid_ENF_Time_Detection.m. This will call on the functions needed. For this program to work, a video and an ENF dataset is needed. The code will determine a time of recording with respect to the ENF data, assuming the starting time of the ENF data.

The program is built around an ENF dataset with either a sampling frequency of 1/4 (data received from TenneT) or 1/1.05 (data received from the NFI). In the subfunction get_ENF.m, the choice can be made to select your own sample frequency by choosing other. The code will adjust to the sampling frequency.

A frequency-range and a peak height selection are both available. It is recommended to take the frequency range in between 30 and 150 (below 30, most likely no ENF will be found).
For the peak height, it is recommended to zoom in a few times in order to take the low-power peaks into account.

The full code is made with MATLAB version 9.9, and makes use of the following add-ons: 
-	Signal Processing Toolbox (version 8.5)
-	Image Processing Toolbox (version 11.2)
-	Financial Toolbox (version 6.0)
-	Parallel Computing Toolbox (version 7.3)
-	MATLAB Parallel Server (version 7.3)
-	Polyspace Bug Finder (version 3.3)
