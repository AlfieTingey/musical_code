clear all
close all

%% Introduction

% This script is the same as the basic assignment but we consider less
% modes, which will make the script run faster. We will delete modes that
% have very similar frequencies to other modes.

% Read in input forcing signal. I have chosen the cath_cut wav file as it
% has a sample rate of 44.1kHz.

[F,Fs] = audioread('cath_cut.wav');

% Make sure that stereo wav files will also work.

if size(F,2) == 2
    F = (F(:,1) + F(:,2))/2; 
end 

%% Set up some parameters for the two plates.

% Steel plate: found parameters from assignment sheet.
rho = 8000;
alpha = 0.0005;
T = 700;
E = 2e11;
v = 0.3;

% Set length and width of the plate
Lx = 2;
Ly = 1;

% Specify T60 max and min times
Ts1 = 8; % T60 max
Ts0 = 1; % T60 min

% Titanium plate: found all the paramaters online.
%rho = 4480;
%alpha = 0.0005;
%T = 500;
%E = 1.12e11;
%v = 0.35;

% Set length and width of the plate
%Lx = 2.5;
%Ly = 0.95;

% Specify T60 max and min times
%Ts1 = 4; % T60 max
%Ts0 = 1; % T60 min

% Error check plate dimensions and T60 times

if Lx <= 0 
    error('Dimensions of plate must be positive')
end 

if Ly <= 0
    error('Dimensions of plate must be positive')
end 

if Ts1 <= 0
    error('T60 times must be positive')
end 

if Ts0 <= 0 
    error('T60 times must be positive')
end 

if Ts1 < Ts0
    error('Max T60 Ts1 must be bigger than min T60 Ts0')
end 


%% Work out derived parameters

c = sqrt(T/(rho*alpha));
K = sqrt((E*alpha^2)/(12*rho*(1-v^2)));

% These are the two extreme values for sigma

sigma0 = 6*(log(10))/Ts0; 
sigma1 = 6*(log(10))/Ts1; 

assert(sigma0 >= 0)
assert(sigma1 >= 0)

% Set the value of k
k = 1/Fs;

% Set a value for fmax such that stability conditions are assured
fmax = 1/(pi*k);

% Set a max for omega using the value for fmax.
wmax = 2*pi*fmax;

%% Set input and output positions and error check them

% Set input positions for the plate

xi = 0.1;
yi = 0.5;

% Error check input positions: they must be within the dimensions of the
% plate.

assert(xi > 0)
assert(xi < Lx)

assert(yi > 0)
assert(yi < Ly)

% Set output positions for the plate. 2 of them for stereo output. 

xo1 = 1.5;
yo1 = 0.8;
xo2 = 1.25;
yo2 = 0.9;

% Error check the two output positions: they must be within the dimensions of the
% plate.

assert(xo1 > 0)
assert(xo1 < Lx)

assert(xo2 > 0)
assert(xo2 < Lx)

assert(yo1 > 0)
assert(yo1 < Ly)

assert(yo2 > 0)
assert(yo2 < Ly)

%% Create eigenfrequencies and work out Qx and Qy

% This loop goes through all the values for omega and makes sure that
% stability conditions are satisfied. We set up a while loop that goes
% through all of the different integer pairs associated with q and gives values of
% omega such that the stability conditions are always satisfied. 

Omega = 0;
qx = 1;
qy = 1;
q = 1;
omega = zeros(2*Fs,3);

 % We have that Omega represents all of the frequencies squared.
 % So we set the following stability condition. We then work out a
 % matrix with all of the omega^2s, all the qx values and all the qy values.
    
while sqrt(Omega) < wmax
    Omega = c^2*((qx*pi/Lx)^2 + (qy*pi/Ly)^2) + K^2*((qx*pi/Lx)^2 + (qy*pi/Ly)^2)^2; 
    if sqrt(Omega) < floor(2/k)
        omega(q,1) = Omega;
        omega(q,2) = qx;
        omega(q,3) = qy;
        qy = qy + 1;
        q = q+1;
        
    else 
        qy = 1;
        qx = qx+1;
        Omega = c^2*((qx*pi/Lx)^2 + (qy*pi/Ly)^2) + K^2*((qx*pi/Lx)^2 + (qy*pi/Ly)^2)^2;
    end 
end 

% Take omega only up to the qth value

omega = omega(1:q-1,:);

% Sort omega such that it goes from minimum to maximum.

omega = sortrows(omega,1);

%% Take out modes that have frequencies that are very close together 

% This is the extra credit section where we take out some modes to improve
% the efficiency of the script. I have specified a range of frequency at
% which we can remove modes. The aim is to get the modes into the range
% 4000-5000 modes so that the script will run fairly quickly and we won't
% lose too much in terms of the sound. 

% Take sqrt of omega to give angular frequencies
sqrtomega = omega;
sqrtomega(:,1) = sqrt(omega(:,1));

% We set up a while loop and go through all of the different frequency
% values. We see if the frequencies are close together and if they are we
% delete them from the vector. 

m = 1;
sqrtomega1 = 0;

% This give the range at which we take out the modes.
cents = nthroot(2, 12)^(0.7/100) * (sqrtomega(1,1) / (2 * pi)) - sqrtomega(1,1) / (2 * pi);

while m < length(sqrtomega(:,1))
    if sqrtomega(m,1)/(2*pi) - sqrtomega1/(2*pi) < cents % If in the specified range... identify modes
        sqrtomega(m,:) = []; % Delete modes from vector. 
    else 
        sqrtomega1 = sqrtomega(m,1);
        m = m+1;
        cents = nthroot(2, 12)^(0.7/100) * (sqrtomega(m,1) / (2 * pi)) - sqrtomega(m,1) / (2 * pi);
    end 
end 

omega = sqrtomega;
% Square omega again.
omega(:,1) = omega(:,1).^2;


% From the while and if loops we can find the values for Q, Qx and Qy. Q
% will be much smaller than in the basic script. 

Q = length(omega(:,1)) % Display number of modes
Qx = max(omega(:,2));
Qy = max(omega(:,3));

% Assert that the stability condition is satisfied 

assert(sqrt(max(omega(:,1))) <= 2/k)


%% Find sigma from frequencies 

% To find epsilon0 and epsilon1 I basically just re-arranged the equations
% given in the assignment (9 & 10) and made them into a system of two equations that
% I subsequently solved, setting the max omega to the min T60 and the min
% omega to the max T60. All the other omegas have T60s somewhere inbetween
% these two extremes.

% Set the initial values that we use to find sigma

q1 = (omega(1,2)*pi/Lx)^2 + (omega(1,3)*pi/Ly)^2;
qQ = (omega(Q,2)*pi/Lx)^2 + (omega(Q,3)*pi/Ly)^2;

% Work out the values of epsilon0 and epsilon1 such that the lowest
% frequency has the max T60 and the highest frequency has the min T60.

e1 = (sigma1-sigma0)/(q1 - qQ);
e0 = sigma0 - e1*(qQ);

assert(e1 > 0)
assert(e0 > 0)

% Find sigma as a vector of length Q.

sigma = e0 + e1*((omega(:,2)*pi/Lx).^2 + (omega(:,3)*pi/Ly).^2);

% Finally, assert that damping is small

assert(max(omega(:,1) - sigma) >= 0)

%% Do the main for loop

% Find the values for the different modes denoted by Phi. Then Phio1 and Phio2 are the
% modes associated with the output positions. 

Phi = (2/sqrt(Lx*Ly)).*sin(omega(:,2).*pi*xi/Lx).*sin(omega(:,3).*pi.*yi/Ly);
Phio = (2/sqrt(Lx*Ly)).*sin(omega(:,2).*pi*xo1/Lx).*sin(omega(:,3).*pi.*yo1/Ly);
Phio2 = (2/sqrt(Lx*Ly)).*sin(omega(:,2).*pi*xo2/Lx).*sin(omega(:,3).*pi.*yo2/Ly);

% Nf is the length of the output vectors.

Nf = length(F) + Ts1*Fs;

% Set initial vector states

u0 = zeros(Q,1);
u1 = zeros(Q,1);
u2 = zeros(Q,1);
IR0 = zeros(Q,1);
IR1 = zeros(Q,1);
IR2 = zeros(Q,1);
y = zeros(Nf,2);
ir = zeros(Nf,2);
F = [F;zeros(Ts1*Fs,1)]; % Set the length of the audio file that drives the plate
Delta = zeros(Nf,1);
Delta(1) = 1; % Set the kronecker delta function

% Specify coefficients to be used in the loop (from FD algorithm).

C1 = (1./((1/k^2+sigma/(k)))); C2 = (2/k^2 - omega(:,1)); C3 = (sigma/(k)-1/k^2); C4 = Phi*(1/(rho*alpha));

% Set up the main loop using the finite difference algorithms. We are
% working out two different things: the impulse response ir and the audio
% file y.

for n = 1:Nf
    u0 = C1.*(C2.*u1 + C3.*u2) + C1.*C4*F(n);
    IR0 = C1.*(C2.*IR1 + C3.*IR2) + C1.*C4*Delta(n);
    ir(n,1) = sum(IR0.*Phio);
    ir(n,2) = sum(IR0.*Phio2);
    y(n,1) = sum(u0.*Phio);
    y(n,2) = sum(u0.*Phio2);
    u2 = u1;
    u1 = u0;
    IR2 = IR1;
    IR1 = IR0;
end 

%% Create the audio files, play the sounds, plot spectograms.

% Plate reverb audio
y(:,1) = y(:,1)/max(abs(y(:,1)));
y(:,2) = y(:,2)/max(abs(y(:,2)));

% Create audio file

% Make it mono just so we can listen to it in the script
Y = (y(:,1) + y(:,2))/2;
Y = Y/max(abs(Y));
soundsc(Y,Fs);

% Impulse response
ir(:,1) = ir(:,1)/max(abs(ir(:,1)));
ir(:,2) = ir(:,2)/max(abs(ir(:,2)));

% Create impulse response

% sum the impulse response to mono
ir = (ir(:,1) + ir(:,2))/2;
ir = ir/max(abs(ir));
%soundsc(ir,Fs);

spectrogram(ir,round(Nf/8),round(Nf/16),round(Nf/8),Fs)
title('Spectogram of impulse response');





