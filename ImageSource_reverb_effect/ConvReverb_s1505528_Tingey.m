clear all 
close all 
%% Read in IR script and read in a wav file

% Read in the script that produces an Impulse Response.

ImageSource_s1505528_Tingey;

% Read in a wav file of my choice. I have chosen 'cath_cut'.

[y, Fs] = audioread('cath_cut.wav');

%Error check to make sure stereo wav files will also work

if size(y,2) == 2
    y = (y(:,1) + y(:,2))/2; 
end 
y;

%% Frequency Domain Convolution

% Frequency Domain Convolution: The method here is to take the fast fourier
% transform of both the input wav file and the impulse response (from the
% image source method) to put them in the frequency domain and then 
% pointwise multiply them. We then take the inverse fft to put it back into
% the time domain.

% For Frequency domain convolution we take two vectors of length n and m,
% where their convolution has length n + m - 1. 

% The fft can take two values in the form fft(X,n) where n returns the 
% 'n point DFT'. 

% For greater efficiency of the convolution we take n to be a power of 2. 
% Ideally, we want it to be the smallest power of 2 that is greater than the value
% N. To do this we use the matlab function 'nextpow2'.

n = length(y); m = length(IR);
% length of convolution vector (determined by eqn for length of conv.
% vector).
N = n + m - 1; 
% Determine power of 2 to zero pad the fft for efficiency
N_conv = 2^(nextpow2(N)); 

% Take the fft of the wav file input
Y=fft(y, N_conv); 	
% Take the fft of the Impulse Response 
XIR=fft(IR, N_conv);  
% Take the pointwise multiplication of the two ffts
R=Y.*XIR;   

% Transfer signal back into time domain. Take the real part of the ifft.  
reverb_signal = real(ifft(R, N_conv));
% take only the length required (after N the vector is just zero padded)
reverb_signal = reverb_signal(1:N);    
% Obviously normalise the output
reverb_signal= reverb_signal/max(abs(reverb_signal)); 

%% Time domain convolution

% Here I use the Matlab function 'conv' for time domain convolution. I
% tried to code it myself using the formula for time domain convolution:
% w(k) = sum(u(j)*v(k+1-j)) but I was running out of time and it wasn't
% working very well. The 'conv' function is very easy coding.

t_conv = conv(y,IR);
t_conv = t_conv/max(abs(t_conv));

%% Equivalence between the 2

% To show equivalence between the two I have plotted the difference between
% them. The magnitude shows the difference to be absolutely minimal (order 10^-15)
% so it looks like they are pretty much equivalent. 

plot((t_conv) - (reverb_signal)); title('Error between time domain conv and frequency domain conv');

%% Finally, Play the reverb sound

soundsc(reverb_signal,Fs); % Play the sound using Freq domain conv.

%soundsc(t_conv,Fs); % Play the sound using time domain conv.








