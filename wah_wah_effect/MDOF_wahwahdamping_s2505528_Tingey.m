clear all 
close all

%% Preamble, error checking and defining variables

% This code assumes a 2 DOF model. It takes two vector quantites with two
% different wah wah frequencies and puts them together to give multiple
% mass, multiple damping and multiple wah wahing effect. I just made a
% second vector z with different variables to the original vector x with
% the same method for FD. Then I stuck them in a vector.... then I play the
% sound by changing them into non vector mode. Sounds kinda cool. Could
% easily do more times for more masses. 

% Read in wav file that I made. I made this wav file because it fit very
% well with the wah wah. The different chords have different driving
% frequencies. Nice!

[y,Fs] = audioread('Guitar_Sequence.wav'); 

% Take stereo files too
if size(y,2) == 2
    y = (y(:,1) + y(:,2))/2; 
end 
y;

y = y(22050:length(y) - 22050)'; % Set the desired length of the wav file (as at the start there is a bang)

T = 1/Fs; % Set the sample rate and the period between samples

n = 0:length(y)-1; % Set the values of n for the wah wah sinusoid Error check size of n;

if length(n) ~= length(y)
    error('code will not work')
end 

%% Set all the variables for the first oscillator

fmax = 600; % Set fmax
% Set a warning...I found that if I set fmax below around 200 the wah wah
% effect didn't work at all. It does still work though so I didn't put an
% error.

if fmax < 100
    warning('watch out: fmax below 300 will give undesirable results');
end 

fmin = 400; % Set fmin. Best range is somewhere around 300-1000. for fmax and fmin

% Set a warning... I found that if fmin was below 150 the wah wah effect
% gave undesirable results. It does still work though so I didn't put an
% error.

if fmin < 50
    warning('watch out: fmin below 150 will give undesirable results');
end 

% Error: fmax has to be greater than fmin:
if fmax <= fmin
    error('fmax has to be greater than fmin')
end 

wmax = 2*pi*fmax; % Set angular frequency max.

wmin = 2*pi*fmin; % Set angular frequency min.

depth = wmax - wmin; % Set the depth of the oscillation

fwah = 3; % Choose frequency for wahwah sinusoid

% fwah must be positive
if fwah <= 0
    error('Error: frequency of oscillation must be greater than 0');
end 
% fwah greater than 15 gives very crazy wah wah
if fwah >= 15
    warning('WahWah effect will be crazy')
end 

w = (depth/2)*cos(2*pi*fwah*n*T)+ wmin + (depth/2); % Set an omega that oscillates between fmin and fmax.

%% Set all the variables for the second oscillator

fmax2 = 150; % Set fmax

if fmax2 < 100
    warning('watch out: fmax below 300 will give undesirable results');
end 

fmin2 = 100; % Set fmin. Best range is somewhere around 300-1000. for fmax and fmin

% Set a warning... I found that if fmin was below 150 the wah wah effect
% gave undesirable results. It does still work though so I didn't put an
% error.

if fmin2 < 50
    warning('watch out: fmin below 150 will give undesirable results');
end 

% Error: fmax has to be greater than fmin:
if fmax2 <= fmin2
    error('fmax has to be greater than fmin')
end 

wmax2 = 2*pi*fmax2; % Set angular frequency max.

wmin2 = 2*pi*fmin2; % Set angular frequency min.

depth2 = wmax2 - wmin2; % Set the depth of the oscillation

fwah2 = 3; % Choose frequency for wahwah sinusoid

% fwah must be positive
if fwah2 <= 0
    error('Error: frequency of oscillation must be greater than 0');
end 
% fwah greater than 15 gives very crazy wah wah
if fwah2 >= 15
    warning('WahWah effect will be crazy')
end 

w2 = (depth2/2)*cos(2*pi*fwah2*n*T)+ wmin2 + (depth2/2); % Set an omega that oscillates between fmin and fmax.


%% A bit more defining of variables

M = length(y)*T; % Set the length in Samples

f=0:T:M-1/Fs; % Set this value to graph stuff later

alpha = 500; % Choose a decay value. Should be comparable to fmax and fmin for best sounds (I find).
alpha2 = 200;
% Set a warning for alpha... should be almost equal in value to fmax and fmin

if alpha < 100
    warning('alpha below 200 gives undesirable results')
end 

%% Finite Difference Method for Driven oscillation

Inv1 = 1/(1+(alpha*T)/2); % Set an inverse from the finite difference algorithm so there are no divisions in for loop
Inv2 = 1/(1+(alpha2*T)/2);

% Set some initial conditions so there are no indice problems
x(1) = 0;
v1 = 0.2;
x(2) =  T*v1 + x(1) + (T^2/2)*(-alpha*v1 + w(1)^2*x(1)+y(1));
z(1) = 1;
v1 = 0.2;
z(2) =  T*v1 + x(1) + (T^2/2)*(-alpha2*v1 + w2(1)^2*x(1)+y(1));

% Run the for loop which makes use of finite difference algorithm to
% calculate driven oscillation solutions. I basically just rearranged the 
% equation with a f(t) driving function... in the equation f(t) would be
% multiplied by T^2 but this was causing issues so I took this out.

for k = 3:length(y)
    x(k) = (2*x(k-1) + ((alpha/2)*T - 1)*x(k-2) + T^2*(y(k-1)/T^2 - w(k)^2*x(k-1)))*Inv1; 
    z(k) = (2*z(k-1) + ((alpha2/2)*T - 1)*z(k-2) + T^2*(y(k-1)/T^2 - w2(k)^2*z(k-1)))*Inv2;
end 

%% Play sound and plot graphs if desired

% set a vector that has both driven damped SHOs
s1(1,:) = x;
s1(2,:) = z;

% make it non stereo mode
s1 = (s1(1,:) + s1(2,:))/2; 

% Normalise the sound
s1 = s1./abs(max(s1));

% Play the sound 
soundsc(s1,Fs);

% Graph stuff if you want to
subplot(2,2,1)
plot(f,w); xlabel('Time (s)'); ylabel('Angular frequency Amplitude'); title('Varying angular frequency');
subplot(2,2,2)
plot(f,w2); xlabel('Time (s)'); ylabel('Angular frequency Amplitude'); title('Varying angular frequency');
subplot(2,2,3)
plot(f,y); xlabel('Time (s)'); ylabel('Magnitude'); title('Original signal');
subplot(2,2,4)
plot(f,s1); xlabel('Time (s)'); ylabel('Magnitude'); title('Wah Wah signal');