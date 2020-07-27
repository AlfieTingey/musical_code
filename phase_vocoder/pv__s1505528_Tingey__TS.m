%% Preamble and Assigning variables 

%q1: Title of work Alfred Tingey s1505528

% question 2: Preamble, N HA and Q

tic % start stopwatch for timing 

N = 2048; 
HA = N/8; 
Q = 1.25; % select Window Size, Analysis Hop size and ratio Q. For best results take 0.2 < Q < 2.

warning('N must be a power of 2 and Q must be a value between 0.2 and 2'); 

% add a warning to let users know acceptable conditions for variables.

%q3: Work out HS

HS = round(Q*HA); % set a synthesis Hop size
Q = HS/HA; % select new value for Q after rounding to an integer for HS to limit errors 

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
    x = (x(:,1) + x(:,2))/2; % use 'if' loop to make sure stereo signals also work
end 
x = [zeros(N,1); x]; % zero pad signal x with N zeroes at the start
x = x'; % transpose x to make later calculations easier

%q7: find the size of zero padded vector x and determine number of analysis
% frames 

L = length(x); 
NF = ceil(L/HA); 
a = (NF-1)*HA+(N-1); % assigning variables, where 'a' is used to zero pad the last frame

zp = zeros(1,(a-L)); % length of zeros at end which will be less than N.
x = [x zp]; % New vector x defined with zero padding

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

%q12 - 17: 

% compute instantaneous frequencies for each bin k in each frame m

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

% (Methodology: I take the modulus of the angles with a +pi in the modulus to
% make sure the angles work for the modulus and will be mapped from 0:2pi. 
% Then I minus a pi outside the modulus to put the angles back into the range -pi to pi.) 

    thetaMat(:,m) = thetaMat(:,m-1) + instFreq(:,m)*HS; % output phases/frequencies for true frequency
    YF(:,m) = XFM(:,m).*exp(1j*(thetaMat(:,m))); % multiply the magnitude of the DFT of columns with phase differences
    Y(:,m) = ifft(YF(:,m)); % take the inverse DFT of each column
    Ywin(:,m) = Y(:,m).*win'*Amp; % window each column and multiply by 1/sqrt(((N/HS)/2) to give scaled amplitude

    Overlap = (m-1)*HS:(m-1)*HS+N-1; % index to use for overlap-adding of frames separated by HS
    
    y(Overlap) = y(Overlap)+Ywin(:,m)'; % overlap-add columns of Y into output vector y
    
end

%% Plotting output 

% q18:

y = real(y); % take out any small error rounding for imaginary parts of output signal y

soundsc(y,Fs); % play the time-stretched sound

% create a 2x2 array of plots showing original signal, output signal,
% output DFT spectrum and instantaneous frequencies

subplot(2,2,1); plot(x); ylabel('Amplitude'); xlabel('Time') 
subplot(2,2,3); plot(y); ylabel('Amplitude'); xlabel('Time')
subplot(2,2,2); imagesc(abs(YF)); ylabel('Frequency (Hz)'); xlabel('Time (window index)');
subplot(2,2,4); plot(instFreq); ylabel('Phase Angle (Frame index)'); xlabel('k (Bins)'); view([90,-90]); 

% plot instantaneous frequency and use 'view' to change y axis to bins. 

toc % take time required to implement script








