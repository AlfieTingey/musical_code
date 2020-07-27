clear all 
close all 

%% Pre-amble and assigning variables

% This is the basic assignment. I apply the forward and backward algorithms
% to give a moog filter. Then I graph the impulse responses logarithmically
% along the the exact impulse response.

% Set the sample rate, the resonant frequency, the tuning parameter, and
% the simulation duration. 

Fs = 44100;

f0 = 1000; % User can change this. Best values are 100 < f0 < 1500. 

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

%% Error check k using w0 and r: 

% Error check k so that stability is always good using values for w0 and r.
% Method: I took abs(1+k*eig(s1)) <= 1 and abs(1+k*eig(s3)) <= 1 and calculated
% them directly. s2 and s4 are the same calculations as s1 and s3
% respectively. I won't go through all the steps, but the general method
% was to split the eigenvalues into imaginary and real parts, re-write the
% complex number inside the magnitude as an imaginary and real part,
% take that magnitude and set it less than 1.... then re-arrange the
% resulting formula for k in terms of w0 and r. My results are this: 

% For stability of s3: k <= (1/w0)*(2(1+r^(1/4))/(1+2r^(1/4)+2r^(1/2))).
% For stability of s1: k <= (1/w0)*(2(1-r^(1/4))/(1 - 2r^(1/4) + 2r^(1/2))). 

% So these are the conditions... I think I caluclated it right but I'm not
% 100% sure. 

% Implement error check: 

if k >= (1/w0)*(2*(1+r^(1/4))/(1+2*r^(1/4)+2*r^(1/2)))
    error('This value of k will not give a stable system for eigenvalues s3 and s4')
end 

if k >= (1/w0)*(2*(1-r^(1/4))/(1 - 2*r^(1/4) + 2*r^(1/2)))
    error('This value of k will not give a stable system for eigenvalues s1 and s2')
end 

%% Error check k with eigenvalues just in case my method above doesn't quite work.

abs(1+k*eig(A));

% Error check k so that stability is always good using the eigenvalues of A
% directly. This is just incase the method above doesn't pickup all the cases of stability.
% One must always make sure there is stability. 

if max(abs(1+k*eig(A))) > 1
    error('Error: the system will not be stable')
end 

%% Start for loop for the forward method

% Set the first initial values of the output y from the first state of the
% xf vector.

yf = zeros(Nf,1);
yff = zeros(Nf,1);

% yff denotes the impulse response yforward... which is the last value in the xf
% vector.
yff(1) = xf(4);

% yf deontes y(n)
yf(1) = c'*xf;

% For loop to calculate forward method. xf changes values in each
% iteration... then we get values for yff and yf. 

for n = 2:Nf
    xf = (I + k*A)*xf + k*b*u(n-1);
    yff(n) = xf(4);
    yf(n) = c'*xf;
end

%% Start for loop for the backwards method using matrix inverse

% Set sizes of vectors and their initial states
xb = [0;0;0;0];
yb = zeros(Nf,1);
ybb = zeros(Nf,1);

% Ak is the matrix I will use in the for loop
Ak = (I - k*A);
% This is the first value of xb
xb = Ak \ (xb + k*b*u(1));
% yb is the y(n) vector
yb(1) = c'*xb;
% ybb is the ybackward vector (output)
ybb(1) = xb(4);

% Use a for loop that takes the inverse of the matrix Ak. Calculate new
% values of xb each time
for n = 2:Nf
    xb = Ak \ (xb + k*b*u(n));
    ybb(n) = xb(4);
    yb(n) = c'*xb;
end 

%% Find the exact frequency response from the equation using a matrix inversion and setting s equal to a range of frequencies

% Here I just use equally spaced frequencies and set a vector s full of
% them. The length of s is the same as the length of the two output y
% vectors. I then make use of the formula in the assignment, for discrete
% variables, and work out Hexact. 

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
L1 = length(yff);
N1 = ceil(log2(L1));
f1 = (Fs/2^N1)*(0:2^(N1-2)-1);
N2=ceil(log2(L2));
f2=(Fs/2^N2)*(0:2^(N2-2)-1);
Hf = abs(fft(yff));
Hb = abs(fft(ybb));

%% Plot each of the frequency responses logarithmically

% How to plot with logarithms on both axes. 

Hforward = loglog(f2, (abs(Hf(1:2^(N2-2)))));
hold on 
Hbackward = loglog(f2, (abs(Hb(1:2^(N2-2)))));
hold on 
Hexact = loglog(f2, (abs(He(1:2^(N2-2)))));

M = max(Hf);
xlim([1,f0*10]); ylim([10^(-3),M+5]);

xlabel('Logarithmic Frequency'); ylabel('Magnitude (db)'); title('Frequency Response for Hf, Hb and Hexact');

H1 = 'Hforward'; H2 = 'Hbackward'; H3 = 'Hexact';
legend([Hforward;Hbackward;Hexact],H1,H2,H3);



