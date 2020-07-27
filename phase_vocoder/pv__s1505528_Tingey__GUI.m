%% Explanation

% This is my code generated using appdesigner to create a GUI for pitch
% shifting and time stretching. In the GUI the user will be able to specify 
% variables and subsequently press buttons to plot and play the sound of
% the original signal, the time stretched signal and the pitch shifted
% signal. In this GUI the signal I have used is 'mozart.wav' although
% any wav file could be used by the user with a slight change in code. If
% someone runs this code the GUI will pop up. I will also attach the GUI in
% .mlapp format.
 
classdef pv__s1505528_Tingey__GUI < matlab.apps.AppBase

    % Properties that correspond to app components
    properties (Access = public)
        UIFigure                   matlab.ui.Figure
        UIAxes                     matlab.ui.control.UIAxes
        QEditFieldLabel            matlab.ui.control.Label
        QEditField                 matlab.ui.control.NumericEditField
        Chooseavaluebetween02and2forQLabel  matlab.ui.control.Label
        PlotsPanel                 matlab.ui.container.Panel
        OriginalSignalButton       matlab.ui.control.Button
        TimeStretchedSignalButton  matlab.ui.control.Button
        PitchShiftedSignalButton   matlab.ui.control.Button
        PlaySoundPanel             matlab.ui.container.Panel
        OriginalSoundButton        matlab.ui.control.Button
        TimeStretchedSoundButton   matlab.ui.control.Button
        PitchShiftedSoundButton    matlab.ui.control.Button
        IntervalEditFieldLabel     matlab.ui.control.Label
        IntervalEditField          matlab.ui.control.NumericEditField
        Chooseavaluebetween12and12forthepitchshiftingintervalLabel  matlab.ui.control.Label
        Label                      matlab.ui.control.Label
        TimeStretchingandPitchShiftingGUILabel  matlab.ui.control.Label
    end

    methods (Access = private)

        % Button pushed function: OriginalSignalButton
        function OriginalSignalButtonPushed(app, event)
            [x,~] = audioread('mozart.wav');
            
            N = 2048;
            if size(x,2) == 2
            x = (x(:,1) + x(:,2))/2; % use if loop to make sure stereo signals also work
            end 
            x = [zeros(N,1); x]; % zero pad signal x with N zeroes at the start
            x = x'; % transpose x to make later calculations easier
            
           plot(app.UIAxes, x);
           xlabel(app.UIAxes, 'time'); ylabel(app.UIAxes, 'Amplitude')
        end

        % Button pushed function: TimeStretchedSignalButton
        function TimeStretchedSignalButtonPushed(app, event)
           
            
            N = 2048; 
            HA = N/8; 
            Q = app.QEditField.Value; % select Window Size, Analysis Hop size and ratio Q. For best results take 0.2 < Q < 2. 
            
            % add a warning to let users know acceptable conditions for variables.
            
            %q3: Work out HS
            
            HS = round(Q*HA); % set a synthesis Hop size
           
            
            %q4: Hann Window from w[n] = 0.5(1 - cos(2*pi*n/N))
            
            n = 0:1:N-1; 
            win = 0.5*(1-cos(2*pi*n/N)); % code in a Hann window by hand 
            
            %q5: Normalised angular frequency from -pi to pi with N bins
            
            omega1 = 0:2*pi/N:pi*(N-1)/N; 
            omega2 = -pi:2*pi/N:-pi/N;
            omega = [omega1,omega2]; 
            
            % Omega = 0:2*pi/N:2*pi*(N-1)/N; % Use this omega if you don't want negative angles  
            
            % select a normalised angular frequency ranging from -pi to pi with initial value 0, 
            % positive values in first half negative in second.
            
            %q6: Read in Wav file and take note of sample rate. Zero pad file at the 
            % start with N zeros. 
            
            [x,~] = audioread('mozart.wav'); % read in a wav file of your choice, note waveform signal x and sample rate Fs
            
            if size(x,2) == 2
                x = (x(:,1) + x(:,2))/2; % use if loop to make sure stereo signals also work
            end 
            x = [zeros(N,1); x]; % zero pad signal x with N zeroes at the start
            x = x'; % transpose x to make later calculations easier
            
            %q7: find the size of zero padded vector x and determine number of analysis
            % frames 
            
            L = length(x); 
            NF = ceil(L/HA); 
            a = (NF-1)*HA +(N-1); % assigning variables, a is used to zero pad the last frame
            
            zp = zeros(1,(a-L)); 
            x = [x zp];
            
            L1 = length(x);
            
            % now I have made sure the last frame of x will always 
            % contain N samples and L/HA will always be rounded to an integer.
            
            
            %% Reading x into columns of X and initialising Matrices
            
            %q8: Create empty matrices X, instFreq, thetaMat, YF, Y of size N rows, NF
            % columns.
            
            X = zeros(N,NF); 
            instFreq = zeros(N,NF);
            thetaMat = zeros(N,NF);
            YF = zeros(N,NF);
            Y = zeros(N,NF);
            
            %q9: create vector y initally all zeros to eventually store NF frames 
            % separated by HS
            
            y = zeros(1,NF*HS - HS+N); % preset a length for output signal y using synthesis Hop size
            
            %q10 and q11: Using a for loop, read the analysis frames from x, following application of the Hann window
            % vector, into the columns of X. Each frame should contain exactly N samples, and the frames
            % should be separated in time by HA samples. Take DFT of each frame
            % analysis with corresponding spectrum, magnitude and angle.
            
            X(:,1) = x(1:N).*win; % assign the first column of X to first N values of windowed signal x
            
            for m = 2:NF
                
                X(:,m) = x((m-1)*HA:(m-1)*HA+(N-1)).*win; % read windowed signal into each column of X.
            
            end
            
            %% Caluculating STFT, abs and angle of STFT and initialising Matrices
            
            X;
            XF = fft(X); % take the DFT of each column to give spectrum
            XFM = abs(XF); % take the magnitude of the DFT of each column
            XFP = angle(XF); % take the phase angle ofthe DFT of each column
            
            %q12: compute instantaneous frequencies for each bin k in each frame m
            
            % Formula 11: instfreq(m+1)(k) = 2*pi*k/N + (w(m+1)(k) - w(m)(k) -
            % (2*pi*k/N)*HA)/HA
            
            % preassign first column of matrices that I will use in next section
            
            instFreq(:,1) = XFP(:,1);
            thetaMat(:,1) = XFP(:,1);
            YF(:,1) = XFM(:,1).*exp(1j*(thetaMat(:,1)));
            Y(:,1) = ifft(YF(:,1));
            Ywin = zeros(N,NF);
            Ywin(:,1) = Y(:,1);
            y(1:N) = Ywin(:,1);
            
            InvHA = 1/HA; % For efficiency reasons calculate divisions before entering for loop. 
            Amp = 1/sqrt((N/HS)/2); % use this amplitude to scale the output vector y (q17)
            
            %% Calculating Phase differences and True Frequencies
            
            for m=2:NF % run loop from 2:NF to avoid any calculations involving 0 (such as (m-1)).
                
                instFreq(:,m) = omega' + (mod((XFP(:,m)-XFP(:,m-1) - omega'*HA)+ pi, 2*pi)-pi)*InvHA; % unwrap the frequencies to -pi pi
                thetaMat(:,m) = thetaMat(:,m-1) + instFreq(:,m)*HS; % output phases/frequencies for true frequency
                YF(:,m) = XFM(:,m).*exp(1j*(thetaMat(:,m))); % multiply magnitude of DFT of columns with phase differences
                Y(:,m) = ifft(YF(:,m)); % take the inverse DFT of each column
                Ywin(:,m) = Y(:,m).*win'*Amp; % window each column and multiply by 1/sqrt(((N/HS)/2) to give scaled amplitude
            
                Overlap = (m-1)*HS:(m-1)*HS+N-1; % index to use for overlap-adding of frames separated by HS
                
                y(Overlap) = y(Overlap)+Ywin(:,m)'; % overlap-add columns of Y into output vector y
                
            end
            
            %% Plotting output 
            y = real(y);
            plot(app.UIAxes, y, 'm');
            xlabel(app.UIAxes, 'time'); ylabel(app.UIAxes, 'Amplitude');
        end

        % Button pushed function: OriginalSoundButton
        function OriginalSoundButtonPushed(app, event)
            [x,Fs] = audioread('mozart.wav');
            
            N = 2048;
            if size(x,2) == 2
                x = (x(:,1) + x(:,2))/2; 
            end 
            x = [zeros(N,1); x]; 
            x = x'; 
            
            soundsc(x,Fs);
            
            
            
            
        end

        % Button pushed function: TimeStretchedSoundButton
        function TimeStretchedSoundButtonPushed(app, event)
           N = 2048; 
HA = N/8; 
Q = app.QEditField.Value; % select Window Size, Analysis Hop size and ratio Q. For best results take 0.2 < Q < 2. 

%q3: Work out HS

HS = round(Q*HA); % set a synthesis Hop size

%q4: Hann Window from w[n] = 0.5(1 - cos(2*pi*n/N))

n = 0:1:N-1; 
win = 0.5*(1-cos(2*pi*n/N)); % code in a Hann window by hand 

%q5: Normalised angular frequency from -pi to pi with N bins

omega1 = 0:2*pi/N:pi*(N-1)/N; 
omega2 = -pi:2*pi/N:-pi/N;
omega = [omega1,omega2]; 

% Omega = 0:2*pi/N:2*pi*(N-1)/N; % Use this omega if you don't want negative angles  

% select a normalised angular frequency ranging from -pi to pi with initial value 0, 
% positive values in first half negative in second.

%q6: Read in Wav file and take note of sample rate. Zero pad file at the 
% start with N zeros. 

[x,Fs] = audioread('mozart.wav'); % read in a wav file of your choice, note waveform signal x and sample rate Fs

if size(x,2) == 2
    x = (x(:,1) + x(:,2))/2; % use if loop to make sure stereo signals also work
end 
x = [zeros(N,1); x]; % zero pad signal x with N zeroes at the start
x = x'; % transpose x to make later calculations easier

%q7: find the size of zero padded vector x and determine number of analysis
% frames 

L = length(x); 
NF = ceil(L/HA); 
a = (NF-1)*HA+(N-1); % assigning variables, a is used to zero pad the last frame

zp = zeros(1,(a-L)); 
x = [x zp];

L1 = length(x);

% now I have made sure the last frame of x will always 
% contain N samples and L/HA will always be rounded to an integer.


%% Reading x into columns of X and initialising Matrices

%q8: Create empty matrices X, instFreq, thetaMat, YF, Y of size N rows, NF
%columns.

X = zeros(N,NF); 
instFreq = zeros(N,NF);
thetaMat = zeros(N,NF);
YF = zeros(N,NF);
Y = zeros(N,NF);

%q9: create vector y initally all zeros to eventually store NF frames 
% separated by HS

y = zeros(1,NF*HS - HS+N); % preset a length for output signal y using synthesis Hop size

%q10 and q11: Using a for loop, read the analysis frames from x, following application of the Hann window
% vector, into the columns of X. Each frame should contain exactly N samples, and the frames
% should be separated in time by HA samples. Take DFT of each frame
% analysis with corresponding spectrum, magnitude and angle.

X(:,1) = x(1:N).*win; % assign the first column of X to first N values of windowed signal x

for m = 2:NF
    
    X(:,m) = x((m-1)*HA:(m-1)*HA+(N-1)).*win; % read windowed signal into each column of X.

end

%% Caluculating STFT, abs and angle of STFT and initialising Matrices

X;
XF = fft(X); % take the DFT of each column to give spectrum
XFM = abs(XF); % take the magnitude of the DFT of each column
XFP = angle(XF); % take the phase angle ofthe DFT of each column

%q12: compute instantaneous frequencies for each bin k in each frame m
% Formula 11: instfreq(m+1)(k) = 2*pi*k/N + (w(m+1)(k) - w(m)(k) -
% (2*pi*k/N)*HA)/HA

% preassign first column of matrices that I will use in next section

instFreq(:,1) = XFP(:,1);
thetaMat(:,1) = XFP(:,1);
YF(:,1) = XFM(:,1).*exp(1j*(thetaMat(:,1)));
Y(:,1) = ifft(YF(:,1));
Ywin = zeros(N,NF);
Ywin(:,1) = Y(:,1);
y(1:N) = Ywin(:,1);

InvHA = 1/HA;  % For efficiency reasons calculate divisions before entering for loop. 
Amp = 1/sqrt((N/HS)/2);  % use this amplitude to scale the output vector y (q17)

 %% Calculating Phase differences and True Frequencies

for m=2:NF  % run loop from 2:NF to avoid any calculations involving 0 (such as (m-1)).
    
    instFreq(:,m) = omega' + (mod((XFP(:,m)-XFP(:,m-1) - omega'*HA)+ pi, 2*pi)-pi)*InvHA;  % unwrap the frequencies to -pi pi
    thetaMat(:,m) = thetaMat(:,m-1) + instFreq(:,m)*HS;  % output phases/frequencies for true frequency
    YF(:,m) = XFM(:,m).*exp(1j*(thetaMat(:,m)));  % multiply magnitude of DFT of columns with phase differences
    Y(:,m) = ifft(YF(:,m));  % take the inverse DFT of each column
    Ywin(:,m) = Y(:,m).*win'*Amp;  % window each column and multiply by 1/sqrt(((N/HS)/2) to give scaled amplitude

    Overlap = (m-1)*HS:(m-1)*HS+N-1;  % index to use for overlap-adding of frames separated by HS
    
    y(Overlap) = y(Overlap)+Ywin(:,m)';  % overlap-add columns of Y into output vector y
    
end

y = real(y); % take out any small error rounding for imaginary parts of output signal y
soundsc(y,Fs);
        end

        % Button pushed function: PitchShiftedSignalButton
        function PitchShiftedSignalButtonPushed(app, event)
           
            N = 2048; HA = N/8; interval = app.IntervalEditField.Value; 
            s = 2^(interval/12); 
            
            % select Window Size, Analysis Hop size and pitch shift 'interval'. For
            % best results take -12 < interval < 12. Minus values lower the pitch
            % positive values increase the pitch. 0 gives same signal. The interval determines how many
            % semitones the pitch has changed.  
            
            % add a warning to let users know acceptable conditions for variables.
            
            %q3: Work out HS
            
            HS = round(s*HA); % set a synthesis Hop size 
            
            %q4: Hann Window from w[n] = 0.5(1 - cos(2*pi*n/N))
            
            n = 0:1:N-1; win = 0.5*(1-cos(2*pi*n/N)); % code in a Hann window by hand 
            
            %q5: Normalised angular frequency from -pi to pi with N bins
            
            omega1 = 0:2*pi/N:pi*(N-1)/N; omega2 = -pi:2*pi/N:-pi/N;
            omega = [omega1,omega2]; 
            
            % Omega = 0:2*pi/N:2*pi*(N-1)/N; % Use this omega if you don't want negative angles  
            
            % select a normalised angular frequency ranging from -pi to pi with initial value 0, 
            % positive values in first half negative in second.
            
            %q6: Read in Wav file and take note of sample rate. Zero pad file at the 
            % start with N zeros. 
            
            [x,Fs] = audioread('mozart.wav'); % read in a wav file of your choice, note waveform signal x and sample rate Fs
            
            if size(x,2) == 2
    x = (x(:,1) + x(:,2))/2; % use if loop to make sure stereo signals also work
            end 
            x = [zeros(N,1); x]; % zero pad signal x with N zeroes at the start
            x = x'; % transpose x to make later calculations easier
            
            %q7: find the size of zero padded vector x and determine number of analysis
            % frames 
            
            L = length(x); NF = ceil(L/HA); a = (NF-1)*HA+(N-1); % assigning variables, a is used to zero pad the last frame
            
            zp = zeros(1,(a-L)); x = [x zp];
            
            L1 = length(x);
            
            % now I have made sure the last frame of x will always 
            % contain N samples and L/HA will always be rounded to an integer.
            
            
            %% Reading x into columns of X and initialising Matrices
            
            %q8: Create empty matrices X, instFreq, thetaMat, YF, Y of size N rows, NF
            %columns.
            
            X = zeros(N,NF); 
            instFreq = zeros(N,NF);
            thetaMat = zeros(N,NF);
            YF = zeros(N,NF);
            Y = zeros(N,NF);
            
            %q9: create vector y initally all zeros to eventually store NF frames 
            % separated by HS
            
            y = zeros(1,NF*HS - HS+N); % preset a length for output signal y using synthesis Hop size
            
            %q10 and q11: Using a for loop, read the analysis frames from x, following application of the Hann window
            % vector, into the columns of X. Each frame should contain exactly N samples, and the frames
            % should be separated in time by HA samples. Take DFT of each frame
            % analysis with corresponding spectrum, magnitude and angle.
            
            X(:,1) = x(1:N).*win; % assign the first column of X to first N values of signal x
            
            for m = 2:NF
    
    X(:,m) = x((m-1)*HA:(m-1)*HA+(N-1)).*win; % read windowed signal into each column of X.
            
            end
            
            %% Caluculating STFT, abs and angle of STFT
            
            X;
            XF = fft(X); %take the DFT of each column to give spectrum
            XFM = abs(XF); % take the magnitude of the DFT of each column
            XFP = angle(XF); % take the phase angle ofthe DFT of each column
            
            %q12: compute instantaneous frequencies for each bin k in each frame m
            
            % Formula 11: instfreq(m+1)(k) = 2*pi*k/N + (w(m+1)(k) - w(m)(k) -
            % (2*pi*k/N)*HA)/HA
            
            % preassign first column of matrices that I will use in next section
            
            instFreq(:,1) = XFP(:,1);
            thetaMat(:,1) = XFP(:,1);
            YF(:,1) = XFM(:,1).*exp(1j*(thetaMat(:,1)));
            Y(:,1) = ifft(YF(:,1));
            Ywin = zeros(N,NF);
            Ywin(:,1) = Y(:,1);
            y(1:N) = Ywin(:,1);
            Overlap = zeros(N,NF);
            
            InvHA = 1/HA; % For efficiency reasons calculate divisions before entering for loop. 
            Amp = 1/sqrt((N/HS)/2); % use this amplitude to scale the output vector y (q17)
            
            %% Calculating Phase differences and True Frequencies
            
            for m=2:NF % run loop from 2:NF to avoid any calculations involving 0 (such as (m-1)).
    
    instFreq(:,m) = omega' + (mod((XFP(:,m)-XFP(:,m-1) - omega'*HA)+ pi, 2*pi)-pi)*InvHA; % unwrap the frequencies to -pi pi
    thetaMat(:,m) = thetaMat(:,m-1) + instFreq(:,m)*HS; % output phases/frequencies for true frequency
    YF(:,m) = XFM(:,m).*exp(1j*(thetaMat(:,m))); % multiply magnitude of DFT of columns with phase differences
    Y(:,m) = ifft(YF(:,m)); % take the inverse DFT of each column
    Ywin(:,m) = Y(:,m).*win'*Amp; % window each column and multiply by 1/sqrt(((N/HS)/2) to give scaled amplitude
            
    Overlap = (m-1)*HS:(m-1)*HS+N-1; % index to use for overlap-adding of frames separated by HS
    
    y(Overlap) = y(Overlap)+Ywin(:,m)'; % overlap-add columns of Y into output vector y
    
            end
            
            %% Plotting output
            
            
            y = real(y); % take out any small error rounding for imaginary parts of output signal y
            outputy = interp1((0:(length(y)-1)),y,(0:s:(length(y)-1)),'linear'); 
            y = outputy;
            plot(app.UIAxes, y, 'b');
            xlabel(app.UIAxes, 'time'); ylabel(app.UIAxes, 'Amplitude');
            
        end

        % Button pushed function: PitchShiftedSoundButton
        function PitchShiftedSoundButtonPushed(app, event)
            N = 2048; HA = N/8; interval = app.IntervalEditField.Value; 
            s = 2^(interval/12); 
            
            % select Window Size, Analysis Hop size and pitch shift 'interval'. For
            % best results take -12 < interval < 12. Minus values lower the pitch
            % positive values increase the pitch. 0 gives same signal. The interval determines how many
            % semitones the pitch has changed.  
            
            %q3: Work out HS
            
            HS = round(s*HA); % set a synthesis Hop size
             % select new value for Q after rounding to an integer for HS to limit errors 
            
            %q4: Hann Window from w[n] = 0.5(1 - cos(2*pi*n/N))
            
            n = 0:1:N-1; win = 0.5*(1-cos(2*pi*n/N)); % code in a Hann window by hand 
            
            %q5: Normalised angular frequency from -pi to pi with N bins
            
            omega1 = 0:2*pi/N:pi*(N-1)/N; omega2 = -pi:2*pi/N:-pi/N;
            omega = [omega1,omega2]; 
            
            % Omega = 0:2*pi/N:2*pi*(N-1)/N; % Use this omega if you don't want negative angles  
            
            % select a normalised angular frequency ranging from -pi to pi with initial value 0, 
            % positive values in first half negative in second.
            
            %q6: Read in Wav file and take note of sample rate. Zero pad file at the 
            % start with N zeros. 
            
            [x,Fs] = audioread('mozart.wav'); % read in a wav file of your choice, note waveform signal x and sample rate Fs
            
            if size(x,2) == 2
    x = (x(:,1) + x(:,2))/2; % use if loop to make sure stereo signals also work
            end 
            x = [zeros(N,1); x]; % zero pad signal x with N zeroes at the start
            x = x'; % transpose x to make later calculations easier
            
            %q7: find the size of zero padded vector x and determine number of analysis
            % frames 
            
            L = length(x); NF = ceil(L/HA); a = (NF-1)*HA+(N-1); % assigning variables, a is used to zero pad the last frame
            
            zp = zeros(1,(a-L)); x = [x zp];
            
            L1 = length(x);
            
            % now I have made sure the last frame of x will always 
            % contain N samples and L/HA will always be rounded to an integer.
            
            
            %% Reading x into columns of X and initialising Matrices
            
            %q8: Create empty matrices X, instFreq, thetaMat, YF, Y of size N rows, NF
            %columns.
            
            X = zeros(N,NF); 
            instFreq = zeros(N,NF);
            thetaMat = zeros(N,NF);
            YF = zeros(N,NF);
            Y = zeros(N,NF);
            
            %q9: create vector y initally all zeros to eventually store NF frames 
            % separated by HS
            
            y = zeros(1,NF*HS - HS+N); % preset a length for output signal y using synthesis Hop size
            
            %q10 and q11: Using a for loop, read the analysis frames from x, following application of the Hann window
            % vector, into the columns of X. Each frame should contain exactly N samples, and the frames
            % should be separated in time by HA samples. Take DFT of each frame
            % analysis with corresponding spectrum, magnitude and angle.
            
            X(:,1) = x(1:N).*win; % assign the first column of X to first N values of signal x
            
            for m = 2:NF
    
    X(:,m) = x((m-1)*HA:(m-1)*HA+(N-1)).*win; % read windowed signal into each column of X.
            
            end
            
            %% Caluculating STFT, abs and angle of STFT
            
            X;
            XF = fft(X); %take the DFT of each column to give spectrum
            XFM = abs(XF); % take the magnitude of the DFT of each column
            XFP = angle(XF); % take the phase angle ofthe DFT of each column
            
            %q12: compute instantaneous frequencies for each bin k in each frame m
            
            % Formula 11: instfreq(m+1)(k) = 2*pi*k/N + (w(m+1)(k) - w(m)(k) -
            % (2*pi*k/N)*HA)/HA
            
            % preassign first column of matrices that I will use in next section
            
            instFreq(:,1) = XFP(:,1);
            thetaMat(:,1) = XFP(:,1);
            YF(:,1) = XFM(:,1).*exp(1j*(thetaMat(:,1)));
            Y(:,1) = ifft(YF(:,1));
            Ywin = zeros(N,NF);
            Ywin(:,1) = Y(:,1);
            y(1:N) = Ywin(:,1);
            Overlap = zeros(N,NF);
            
            InvHA = 1/HA; % For efficiency reasons calculate divisions before entering for loop. 
            Amp = 1/sqrt((N/HS)/2); % use this amplitude to scale the output vector y (q17)
            
            %% Calculating Phase differences and True Frequencies
            
            for m=2:NF % run loop from 2:NF to avoid any calculations involving 0 (such as (m-1)).
    
    instFreq(:,m) = omega' + (mod((XFP(:,m)-XFP(:,m-1) - omega'*HA)+ pi, 2*pi)-pi)*InvHA; % unwrap the frequencies to -pi pi
    thetaMat(:,m) = thetaMat(:,m-1) + instFreq(:,m)*HS; % output phases/frequencies for true frequency
    YF(:,m) = XFM(:,m).*exp(1j*(thetaMat(:,m))); % multiply magnitude of DFT of columns with phase differences
    Y(:,m) = ifft(YF(:,m)); % take the inverse DFT of each column
    Ywin(:,m) = Y(:,m).*win'*Amp; % window each column and multiply by 1/sqrt(((N/HS)/2) to give scaled amplitude
            
    Overlap = (m-1)*HS:(m-1)*HS+N-1; % index to use for overlap-adding of frames separated by HS
    
    y(Overlap) = y(Overlap)+Ywin(:,m)'; % overlap-add columns of Y into output vector y
    
            end
            
            %% Plotting output
            
            
            y = real(y); % take out any small error rounding for imaginary parts of output signal y
            outputy = interp1((0:(length(y)-1)),y,(0:s:(length(y)-1)),'linear'); 
            y = outputy;
            
            soundsc(y,Fs);
        end
    end

    % App initialization and construction
    methods (Access = private)

        % Create UIFigure and components
        function createComponents(app)

            % Create UIFigure
            app.UIFigure = uifigure;
            app.UIFigure.Color = [1 1 1];
            app.UIFigure.Position = [100 100 667 549];
            app.UIFigure.Name = 'UI Figure';
            setAutoResize(app, app.UIFigure, true)

            % Create UIAxes
            app.UIAxes = uiaxes(app.UIFigure);
            title(app.UIAxes, 'Axes');
            xlabel(app.UIAxes, 'X');
            ylabel(app.UIAxes, 'Y');
            app.UIAxes.Position = [51 113 360 259];

            % Create QEditFieldLabel
            app.QEditFieldLabel = uilabel(app.UIFigure);
            app.QEditFieldLabel.HorizontalAlignment = 'right';
            app.QEditFieldLabel.FontAngle = 'italic';
            app.QEditFieldLabel.Position = [85.03125 394 25 15];
            app.QEditFieldLabel.Text = 'Q';

            % Create QEditField
            app.QEditField = uieditfield(app.UIFigure, 'numeric');
            app.QEditField.FontAngle = 'italic';
            app.QEditField.Position = [125.03125 390 100 22];

            % Create Chooseavaluebetween02and2forQLabel
            app.Chooseavaluebetween02and2forQLabel = uilabel(app.UIFigure);
            app.Chooseavaluebetween02and2forQLabel.HorizontalAlignment = 'center';
            app.Chooseavaluebetween02and2forQLabel.FontAngle = 'italic';
            app.Chooseavaluebetween02and2forQLabel.Position = [51 426 221 15];
            app.Chooseavaluebetween02and2forQLabel.Text = 'Choose a value between 0.2 and 2 for Q';

            % Create PlotsPanel
            app.PlotsPanel = uipanel(app.UIFigure);
            app.PlotsPanel.Title = 'Plots';
            app.PlotsPanel.BackgroundColor = [0.9373 0.9373 0.9373];
            app.PlotsPanel.Position = [450 129 171 226];

            % Create OriginalSignalButton
            app.OriginalSignalButton = uibutton(app.PlotsPanel, 'push');
            app.OriginalSignalButton.ButtonPushedFcn = createCallbackFcn(app, @OriginalSignalButtonPushed, true);
            app.OriginalSignalButton.Position = [36 169 100 22];
            app.OriginalSignalButton.Text = 'Original Signal';

            % Create TimeStretchedSignalButton
            app.TimeStretchedSignalButton = uibutton(app.PlotsPanel, 'push');
            app.TimeStretchedSignalButton.ButtonPushedFcn = createCallbackFcn(app, @TimeStretchedSignalButtonPushed, true);
            app.TimeStretchedSignalButton.Position = [18.5 102 135 22];
            app.TimeStretchedSignalButton.Text = 'Time-Stretched Signal';

            % Create PitchShiftedSignalButton
            app.PitchShiftedSignalButton = uibutton(app.PlotsPanel, 'push');
            app.PitchShiftedSignalButton.ButtonPushedFcn = createCallbackFcn(app, @PitchShiftedSignalButtonPushed, true);
            app.PitchShiftedSignalButton.Position = [25 36 122 22];
            app.PitchShiftedSignalButton.Text = 'Pitch-Shifted Signal';

            % Create PlaySoundPanel
            app.PlaySoundPanel = uipanel(app.UIFigure);
            app.PlaySoundPanel.Title = 'Play Sound';
            app.PlaySoundPanel.BackgroundColor = [0.9373 0.9373 0.9373];
            app.PlaySoundPanel.Position = [51 21 484 69];

            % Create OriginalSoundButton
            app.OriginalSoundButton = uibutton(app.PlaySoundPanel, 'push');
            app.OriginalSoundButton.ButtonPushedFcn = createCallbackFcn(app, @OriginalSoundButtonPushed, true);
            app.OriginalSoundButton.Position = [11 12 100 22];
            app.OriginalSoundButton.Text = 'Original Sound';

            % Create TimeStretchedSoundButton
            app.TimeStretchedSoundButton = uibutton(app.PlaySoundPanel, 'push');
            app.TimeStretchedSoundButton.ButtonPushedFcn = createCallbackFcn(app, @TimeStretchedSoundButtonPushed, true);
            app.TimeStretchedSoundButton.Position = [144.5 12 137 22];
            app.TimeStretchedSoundButton.Text = 'Time-Stretched Sound';

            % Create PitchShiftedSoundButton
            app.PitchShiftedSoundButton = uibutton(app.PlaySoundPanel, 'push');
            app.PitchShiftedSoundButton.ButtonPushedFcn = createCallbackFcn(app, @PitchShiftedSoundButtonPushed, true);
            app.PitchShiftedSoundButton.Position = [319 12 124 22];
            app.PitchShiftedSoundButton.Text = 'Pitch-Shifted Sound';

            % Create IntervalEditFieldLabel
            app.IntervalEditFieldLabel = uilabel(app.UIFigure);
            app.IntervalEditFieldLabel.HorizontalAlignment = 'right';
            app.IntervalEditFieldLabel.FontAngle = 'italic';
            app.IntervalEditFieldLabel.Position = [431.03125 391 44 15];
            app.IntervalEditFieldLabel.Text = 'Interval';

            % Create IntervalEditField
            app.IntervalEditField = uieditfield(app.UIFigure, 'numeric');
            app.IntervalEditField.FontAngle = 'italic';
            app.IntervalEditField.Position = [490.03125 387 100 22];

            % Create Chooseavaluebetween12and12forthepitchshiftingintervalLabel
            app.Chooseavaluebetween12and12forthepitchshiftingintervalLabel = uilabel(app.UIFigure);
            app.Chooseavaluebetween12and12forthepitchshiftingintervalLabel.HorizontalAlignment = 'center';
            app.Chooseavaluebetween12and12forthepitchshiftingintervalLabel.FontAngle = 'italic';
            app.Chooseavaluebetween12and12forthepitchshiftingintervalLabel.Position = [409.5 416 199 28];
            app.Chooseavaluebetween12and12forthepitchshiftingintervalLabel.Text = {'Choose a value between -12 and 12'; 'for the pitch-shifting interval'};

            % Create Label
            app.Label = uilabel(app.UIFigure);
            app.Label.FontAngle = 'italic';
            app.Label.Position = [51 482 421 15];
            app.Label.Text = 'Note: Values for Q and for Interval must be assigned before pressing buttons';

            % Create TimeStretchingandPitchShiftingGUILabel
            app.TimeStretchingandPitchShiftingGUILabel = uilabel(app.UIFigure);
            app.TimeStretchingandPitchShiftingGUILabel.FontWeight = 'bold';
            app.TimeStretchingandPitchShiftingGUILabel.Position = [214 526 228 15];
            app.TimeStretchingandPitchShiftingGUILabel.Text = 'Time Stretching and Pitch Shifting GUI';
        end
    end

    methods (Access = public)

        % Construct app
        function app = pv__s1505528_Tingey__GUI()

            % Create and configure components
            createComponents(app)

            % Register the app with App Designer
            registerApp(app, app.UIFigure)

            if nargout == 0
                clear app
            end
        end

        % Code that executes before app deletion
        function delete(app)

            % Delete UIFigure when app is deleted
            delete(app.UIFigure)
        end
    end
end