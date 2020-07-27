clear all
close all

%% Preamble, assigning variables and error checking 

% This code gives a nonlinear wah-overdrive effect. I will set the
% variables so they can't be changedas for this code I just want a relatively nice
% sounding distortion effect. 

[y,Fs] = audioread('Guitar_Sequence.wav'); 
if size(y,2) == 2
    y = (y(:,1) + y(:,2))/2; 
end 
y;

y = y(22050:length(y) - 22050)'; % Set the desired length of the wav file (as at the start there is a bang)
T = 1/Fs; % Set the sample rate and the period between samples

n = 0:length(y)-1; % Set the values of n for the wah wah sinusoid. Error check it. 

if length(n) ~= length(y)
    error('code will not work')
end 

alpha = 0.00001; % Set this decay value for the overdrive. Gives a nice distortion level

if alpha ~= 0.00001
    error('I want my code to have an alpha value of 0.00001');
end 

%% Code the wahwah sinusoid for omega

% These two values of fmax and fmin work really well. I'm sure others do
% too.

fmax = 40; % Set fmax
fmin = 30; % Set fmin. 

if fmin < 0
    error('fmax must be greater than 0');
end 

if fmax <= fmin
    error('fmax has to be greater than fmin')
end 

wmax = 2*pi*fmax; % Set angular frequency max.
wmin = 2*pi*fmin; % Set angular frequency min.
depth = wmax - wmin; % Set the depth of the oscillation
fwah = 2; % Choose frequency for wahwah sinusoid
w1 = (depth/2)*cos(2*pi*fwah*n*T)+ wmin + (depth/2); % Choose equation for changing omega
M = length(y)*T; % Set the length in Samples
f=0:T:M-1/Fs; % Set this value to graph stuff later

r = 5; % set a value that scales the input signal
if (0.1 < r) && (r > 10)
    error('can only choose values in range 0.1 to 10')
end 

%% Code the nonlinear wah-overdrive effect

x(1) = 1;
v1 = 0.1;
x(2) =  T*v1 + x(1);

% For loop with algorithm

for n = 3:length(y)
    x(n) = (4*x(n-1))*1/((1 + alpha/(2*T))*(2+w1(n)^4*T^2*(x(n-1))^2)) - ((1 - alpha/(2*T))/(1+alpha/(2*T)))*x(n-2) + r*y(n-1)/((1 + alpha/(2*T)));
end 

% Normalise output
x = x/max(abs(x));

% sound the output
soundsc(x,Fs);