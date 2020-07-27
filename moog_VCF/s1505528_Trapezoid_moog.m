clear all 
close all 

%% Pre-amble and assigning variables

% This script makes use of the trapezoid numerical way of finding the
% impulse function. I then plot it along with the exact impulse response
% As we can see by the plot, it is much more accurate
% compared to the methods in the basic assignment. 

% Set the sample rate, the resonant frequency, the tuning parameter, and
% the simulation duration. 

Fs = 44100;
f0 = 1000;

if f0 < 10
    error('resonant requency is too low')
end 

if f0 > 2000
    error('resonant frequency is too high')
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

% Set the matrix A
A = w0*[-1,0,0,-4*r;1,-1,0,0;0,1,-1,0;0,0,1,-1];

% Set the vectors b and c
b = w0*[1,0,0,0]';
c = [0,0,0,1]';

% Set the starting vector Xf and the Identity matrix
xf = [0;0;0;0];
I = [1,0,0,0;0,1,0,0;0,0,1,0;0,0,0,1];

%% Determine k values 

% Set k equal to the time step... worked out from FD algorithm to see
% what the constant k is equal to. For certain f0 and r this value will not
% be stable. 

k = 1/(0.5*Fs);


%% Start for loop for the Trapezoid method using matrix inverse

% Set sizes of vectors and their initial states
xT = [0;0;0;0];
yT = zeros(Nf,1);

% Ak is the matrix I will use in the for loop. A_k is matrix we need to
% take the inverse.

Ak = (I - k*A/2);
A_k = (I + k*A/2);
% This is the first value of xb
xT = Ak \ (A_k*xT + k*A_k*b*u(1));
% yb is the y(n) vector
yT(1) = c'*xT;

% Use a for loop that takes the inverse of the matrix Ak. Calculate new
% values of xb each time

for n = 2:Nf
    xT = Ak \ (A_k*xT + k*A_k*b*u(n));
    yT(n) = c'*xT;
end 

%% Find the exact frequency response from the equation using a matrix inversion and setting s equal to a range of frequencies

F = 0:1/(2*Tf):Fs/2-1/Fs;
W = 2*pi*F;
s = 1i*W;
He = zeros(Fs/2,1);

for n = 1:Tf*Fs
    He(n) = c'*((s(n)*I - A) \ b);
end 

%% Assign some variables to help with the graphs... take ffts etc. 

% set some lengths to help graph the x-axis and the y-axis

L2 = length(F);
L1 = length(yT);
N1 = ceil(log2(L1));
f1 = (Fs/2^N1)*(0:2^(N1-2)-1);
N2=ceil(log2(L2));
f2=(Fs/2^N2)*(0:2^(N2-2)-1);
HT = abs(fft(yT));


%% Plot each of the frequency responses logarithmically

% How to plot with logarithms on both axes. 

HTrap = loglog(f2, (abs(HT(1:2^(N2-2)))),'r');
hold on 
Hexact = loglog(f2, (abs(He(1:2^(N2-2)))), 'c');

M = max(HT);
xlim([1,f0*10]); ylim([10^(-3),M + 5]);

xlabel('Logarithmic Frequency'); ylabel('Magnitude (db)'); title('Frequency Response for HTrap Hexact');

H1 = 'HTrap'; H3 = 'Hexact';
legend([HTrap;Hexact],H1,H3);
