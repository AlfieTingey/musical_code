clear all
close all

%% Preamble, assigning variables and error checking

% This code demonstrates how to use the algorithm given for nonlinear FD to
% give a downward pitch glide.

w1 = sqrt(2*pi*400); % Set the value of omega as given in the assignment
if w1 ~= sqrt(2*pi*400)
    error('Error: Assignment says w1 = sqrt(2*pi*400)');
end 
Fs = 44100; % set the falue for Fs and apply an error
if Fs <= 22050
    error('Error: sample rate must be above 22050');
end 
T = 1/Fs; % set Ts
ts = 8; % Set a length in time with an error code
if ts <= 0
    error('Error: time must be greater than 0');
end 
M = ts*Fs; % Set length in samples for for loop

f=0:T:M/Fs-1/Fs; % set a time axis for graphing (if we want to graph)

alpha = 0.0000000001; % Set value of alpha as in assignment and error check
if alpha ~= 0.0000000001
    error('Error: Assignment says alpha = 0.0000000001');
end 

%% Code the nonlinear FD

% set some initial conditions. For the 2nd value I just used what I would
% in SHO.

x(1) = 1;
v1 = 0.1;
x(2) =  T*v1 + x(1);

% Set for loop with algorthm from assignment 

for n = 3:M
    x(n) = (4*x(n-1))*1/((1 + alpha/(2*T))*(2+w1^4*T^2*(x(n-1))^2)) - ((1 - alpha/(2*T))/(1+alpha/(2*T)))*x(n-2);
end 

% Normalise output
x = x/max(abs(x));

% Play the sound. Sounds like a downward pitch glide
soundsc(x,Fs);



