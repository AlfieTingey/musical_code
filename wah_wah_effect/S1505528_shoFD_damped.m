clear all 
close all 

%% Preamble and set variables and error check

% For this assignment we need to work out values of alpha for different
% kinds of damping. Underdamping is when alpha<2w0, overdamping is when
% alpha > 2w0 and critical damping is when alpha = 2w0. I worked this out
% from the differential equation by solving the corresponding characterstic
% equation and observing for which values of alpha there will be sinusoidal
% motion or not. (from the sign of the alpha^2 - 4w0^2 in the square root).

f0 = 125; % set value of frequency for solution's oscillation given in the assignment.   
if f0 ~= 125
    error('Error: Assignment says f0 = 125');
end 
w0 =f0*2*pi; % Turn into angular frequency

Fs = 44100; % set sample rate and apply an error
if Fs <= 22050
    error('Error: sample rate must be above 22050');
end 

if Fs < 22050
    error('Error: sample rate must be above 22050');
end 

T = 1/Fs;

ts = 0.2; % Set value of ts given in assignment. 
if ts ~= 0.2
    error('Error: Assignment says ts must be 0.2');
end 

M = ts*Fs; % Set duration in terms of samples

f=0:T:M/Fs-1/Fs; % set a time axis for the graphs 

%%  Underdamped: we have that alpha < 2w0

% Define initial conditions to work out first and second terms in FD method
x_u(1) = 1;
v_u1 = 0.5;
x_u(2) =  T*v_u1 + x_u(1);

% Choose an alpha value that is less than 2*w0.

alpha_u = w0/16;
if alpha_u >= 2*w0
    error('Error: alpha_u must be less than 2*w0 for underdamping');
end 

% Work out Inv so there are no divisions in the for loop
Inv_u = 1/(1+(alpha_u*T)/2);

% For loop with damping involved. I just rearranged the equation in the
% assignment.

for n = 3:M
    x_u(n) = ((2 - w0^2*T^2)*x_u(n-1) + (alpha_u*T/2 - 1)*x_u(n-2))*Inv_u;
end 
x_u = x_u/max(abs(x_u));

%% Critically damped: we have that alpha = 2w0;

% Define initial conditions to work out first and second terms in FD method
x_c(1) = 1;
v_c1 = 0.5;
x_c(2) =  T*v_c1 + x_c(1);

% Choose the value of alpha that will lead to critical damping. (alpha =
% 2*w0).

alpha_c = 2*w0;

% Error check tomake sure alpha_c is correct.
if alpha_c ~= 2*w0
    error('Error: alpha_c must be equal to 2*w0');
end 

% Work out Inv so there are no divisions in the for loop
Inv_c = 1/(1+(alpha_c*T)/2);

% For loop with damping involved. I just rearranged the equation in the
% assignment.
for n = 3:M
    x_c(n) = ((2 - w0^2*T^2)*x_c(n-1) + (alpha_c*T/2 - 1)*x_c(n-2))*Inv_c;
end 
x_c = x_c/max(abs(x_c));

%% overdamped

% Set initial conditions
x_o(1) = 1;
v_o1 = 0.5;
x_o(2) =  T*v_o1 + x_o(1);

% Choose an alpha value that is greater than 2*w0
alpha_o = 16*w0;

if alpha_o <= 2*w0
    error('Error: alpha_u must be greater than 2*w0 for overdamping');
end 

Inv_o = 1/(1+(alpha_o*T)/2); % set inverse for no divisions

% For loop with damping involved. I just rearranged the equation in the
% assignment.
for n = 3:M
    x_o(n) = ((2 - w0^2*T^2)*x_o(n-1) + (alpha_o*T/2 - 1)*x_o(n-2))*Inv_o;
end 
x_o = x_o/max(abs(x_o));

%% Undamped

% This is just the same as in question 1. 
x(1) = 1;
v1 = 0.5;
x(2) =  T*v1 + x(1);

for k = 3:M
    x(k) = (2 - w0^2*T^2)*x(k-1)-x(k-2);
end 

%% Plot
% Plot all graphs in a subplot
subplot(2,2,2);
plot(f,x_u); xlabel('Time (s)'); ylabel('Amplitude'); title('Underdamped SHO');
subplot(2,2,3);
plot(f,x_c); xlabel('Time (s)'); ylabel('Amplitude'); title('Critically damped SHO');
subplot(2,2,4);
plot(f,x_o); xlabel('Time (s)'); ylabel('Amplitude'); title('Overdamped SHO');
subplot(2,2,1);
plot(f,x); xlabel('Time (s)'); ylabel('Amplitude'); title('Undamped SHO');






