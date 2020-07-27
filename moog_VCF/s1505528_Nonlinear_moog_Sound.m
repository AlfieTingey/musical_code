clear all
close all 

%% Pre-amble and assigning variables

% This script creates a nonlinear Moog filter. I do it by not using
% matrices, and instead creating vectors for each x1,x2,x3 and x4 and
% applying the tanh function and the algorithm in the assignment. More
% detail will be given later in the script. This script also applies the
% filter to a guitar sound. 

% Set the sample rate, the resonant frequency, the tuning parameter, and
% the simulation duration. 

f0 = 1000; % User can change this frequency... best range 100 < f0 < 1500.

if f0 < 10
    error('resonant requency is too low')
end 

if f0 > 1500
    error('resonant frequency too high')
end 

% set angular frequency

w0 = 2*pi*f0;

% Set value of r and error check r
r = 0.5;

if r <= 0
    error('r must be between 0 and 1')
end 

if r >= 1
    error('r must be between 0 and 1')
end 


% Set the input u... all zeros apart from the first value which is equal to
% 1
[u,Fs] = audioread('Guitar_Sequence.wav');

% Set Tf and Nf (time in seconds and samples respectively).
Tf = length(u)/Fs;
Nf = Tf*Fs;

% Error check time... time can't be negative after all.
if Tf <= 0
    error('duration must be positive')
end 

% I think for the nonlinear we have that stability is not an issue. I may
% be wrong though. Anyway this is my value for k... shouldn't be changed by
% user. 

k = 1/(0.5*Fs);

% Set the starting values for all of the different x values. 

x1 = zeros(Nf,1); x2 = zeros(Nf,1); x3 = zeros(Nf,1); x4 = zeros(Nf,1); y = zeros(Nf,1);

x1(1) = 0; x2(1)  = 0; x3(1) =  0; x4(1) = 0;
y(1) = 0;


%% For loop for the nonlinear method

% Here we take each xn separately and store them all in vectors that are NF
% values long. This way we can take the n-1 values as in the FD method. It
% seems to work pretty well as the graph below resembles that of a moog. 

for n = 2:Nf
    x1(n) = x1(n-1) + w0*k*(-tanh(x1(n-1)) - tanh(4*r*x4(n-1)+u(n-1)));
    x2(n) = x2(n-1) + w0*k*(-tanh(x2(n-1)) + tanh(x1(n-1)));
    x3(n) = x3(n-1) + w0*k*(-tanh(x3(n-1)) + tanh(x2(n-1)));
    x4(n) = x3(n-1) + w0*k*(-tanh(x4(n-1)) + tanh(x3(n-1)));
    y(n) = x4(n);
end 

%% Play the sound of the nonlinear filter applied to a wav file

soundsc(y,Fs); % Play sound with moog filter
% soundsc(u,Fs); % Play original sound (uncomment for original sound)



