clear all
close all 

%% Pre-amble and assigning variables

% This script creates a nonlinear Moog filter. I do it by not using
% matrices, and instead creating vectors for each x1,x2,x3 and x4 and
% applying the tanh function and the algorithm in the assignment. More
% detail will be given later in the script. Also, this script creates and
% plots the impulse response. I will do another script that applies the
% nonlinear moog to a sound. 

% Set the sample rate, the resonant frequency, the tuning parameter, and
% the simulation duration. 

Fs = 44100;
f0 = 1000;

if f0 < 10
    error('resonant requency is too low')
end 

% set angular frequency

w0 = 2*pi*f0;

% Set value of r and error check r
r = 0.6;

if r <= 0
    error('r must be between 0 and 1')
end 

if r >= 1
    error('r must be between 0 and 1')
end 

% Set Tf and Nf (time in seconds and samples respectively).
Tf = 3;
Nf = Tf*Fs;

% Error check time... time can't be negative after all.
if Tf <= 0
    error('duration must be positive')
end 

% Set the input u... all zeros apart from the first value which is equal to
% 1
u = zeros(Nf,1);
u(1) = 1;

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

%% Hexact for plotting

A = w0*[-1,0,0,-4*r;1,-1,0,0;0,1,-1,0;0,0,1,-1];
I = [1,0,0,0;0,1,0,0;0,0,1,0;0,0,0,1];

% Set the vectors b and c
b = w0*[1,0,0,0]';
c = [0,0,0,1]';

F = 0:1/(2*Tf):Fs/2-1/Fs;
W = 2*pi*F;
s = 1i*W;
He = zeros(Fs/2,1);

for n = 1:Tf*Fs
    He(n) = c'*((s(n)*I - A) \ b);
end 

L2 = length(y);
N2=ceil(log2(L2));
f2=(Fs/2^N2)*(0:2^(N2-2)-1);
HN = abs(fft(y));


%% Plot each of the frequency responses logarithmically

% Plot the impulse response of the nonlinear method. I also plot it against
% Hexact. I don't really know if they are meant to be the same of if the
% nonlinear H purposefully looks a bit different. Still interesting to see
% them on the same graph though. 

HN = loglog(f2, (abs(HN(1:2^(N2-2)))),'r');
hold on
Hexact = loglog(f2, (abs(He(1:2^(N2-2)))), 'c');

xlabel('Logarithmic Frequency'); ylabel('Magnitude (db)'); title('Frequency Response for Nonlinear Moog');
    
H1 = 'HN'; H3 = 'Hexact';
legend([HN;Hexact],H1,H3);
    
    
    



