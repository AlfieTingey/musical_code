clear all 
close all 

%% Preamble and assigning variables 

Fs = 44100; % Set a variable for the sample rate. 44100 is a common one.
if Fs <= 22050
    error('Error: sample rate must be above 22050');
end 
T = 1/Fs;% Set a spacing between time instances.

ts = 6;% Set a constant to represent the duration in seconds of the output signal.
if ts <= 0
    error('Error: time must be greater than 0');
end 
M = ts*Fs; % Set a constant to represent how long the output signal will be in samples.

f0 = 3; % Choose a frequency for the oscillation in Hertz.
if f0 <= 0
    error('Error: frequency of oscillation must be greater than 0');
end 
w0 = 2*pi*f0; % Set the angular frequency.

v1 = 2; % set an initial velocity to determine x(1) and x(2)

f=0:T:ts-1/Fs; % Set a time axis to help with plotting

%% Calculate the SHO

% Set the first two values of x using the finite difference method for
% initial conditions
x(1) = 1;
x(2) = T*v1 + x(1);

% Code in a for loop to start the recursion using the formula specified in
% the assignment.

for k = 3:M
    x(k) = (2 - w0^2*T^2)*x(k-1)-x(k-2);
end 

%% Working out ws compared to w0:

plot(f,x); % Plot of our SHO against frequency
xlabel('Time (s)'); ylabel('Amplitude'); title('FD solution to SHO');

% From the plot of the FD solution we can see where the period of the graph
% is by looking at the position of the maximum values of the sinusoid in
% the graph. To work out the frequency I took the value of x in ranges such
% that the first maximum and the second maximum would arise, and then
% worked out where they are in terms of time. I then manipulated this result
% to give the angular frequency of the FD solution. This is represented in
% the following equations:

[x1,ind1] = max(x(1:1000)); % First maximum at position ind1.
[x2, ind2] = max(x(0.3*Fs:0.4*Fs)); % Second maximum at position 0.3*Fs + ind2.
f_s = 1/((0.3*Fs + ind2 - ind1)/Fs); % Work out frequency
w_s = f_s*2*pi; % Change to angular frequency

% The error between the analytic solution and the FD solution is therefore
% given by the following equation, which has a value of 0.0013 for the variables that 
% I assigned above:

Error = abs(w_s - w0); % Comparison of w_s and w0. Could plot this but it is just a single value. 

% S = x1*cos(w0*(f+ind1)); % Use this formula to plot the analytical
% solution.

