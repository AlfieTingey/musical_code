%% Preamble, error checking and defining variables + explanation

% So this code is the same as the wa wah but I made it so that the rate of
% the oscillation of the wahwah varies over time. To do this I made it so
% 'fwah' is the same size as length y, but fwah changes at every 4th of the
% wav signal. Therefore the oscillations are at a different rate! Sounds a bit like something out of Dubstep.
% Something very interesting would be if I could make the fwah a function of time
% also..... to give a continuous change in rate of oscillation. I will see
% if I can do that in time to hand in. It will be in the
% 'More_complex...Tingey.m' file. 

%%
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

%% Code the varying value for omega

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
f1 = 8;
f2 = 6;
f3 = 3;
f4 = 2;

% Set a changing oscillation rate at every length(y)/4 sample

fwah = [f1*ones(round(length(y)/4),1); f2*ones(round(length(y)/4),1); f3*ones(round(length(y)/4),1); f4*ones(round(length(y)/4)-1,1)]; 

w = (depth/2)*cos(2*pi*fwah'.*n*T)+ wmin + (depth/2); % Set an omega that oscillates between fmin and fmax.

%% A bit more defining of variables

M = length(y)*T; % Set the length in Samples

f=0:T:M-1/Fs; % Set this value to graph stuff later

alpha = 800; % Choose a decay value. Should be comparable to fmax and fmin for best sounds (I find).

% Set a warning for alpha... should be almost equal in value to fmax and fmin

if alpha < 100
    warning('alpha below 200 gives undesirable results')
end 

%% Finite Difference Method for Driven oscillation

Inv = 1/(1+(alpha*T)/2); % Set an inverse from the finite difference algorithm so there are no divisions in for loop

% Set some initial conditions so there are no indice problems
x(1) = 0;
v1 = 0.2;
x(2) =  T*v1 + x(1) + (T^2/2)*(-alpha*v1 + w(1)^2*x(1)+y(1));

% Run the for loop which makes use of finite difference algorithm to
% calculate driven oscillation solutions. I basically just rearranged the 
% equation with a f(t) driving function... in the equation f(t) would be
% multiplied by T^2 but this was causing issues so I took this out.

for k = 3:length(y)
    x(k) = (2*x(k-1) + ((alpha/2)*T - 1)*x(k-2) + T^2*(y(k-1)/T^2 - w(k)^2*x(k-1)))*Inv;  
end 

%% Play sound and plot graphs if desired

% Normalise the sound
x1 = x./max(abs(x));

% Play the sound 
soundsc(x1,Fs);

% Graph stuff if you want to
subplot(3,1,1)
plot(f,w); xlabel('Time (s)'); ylabel('Angular frequency Amplitude'); title('Varying angular frequency');
subplot(3,1,2)
plot(f,y); xlabel('Time (s)'); ylabel('Magnitude'); title('Original signal');
subplot(3,1,3)
plot(f,x1); xlabel('Time (s)'); ylabel('Magnitude'); title('Wah Wah signal');


