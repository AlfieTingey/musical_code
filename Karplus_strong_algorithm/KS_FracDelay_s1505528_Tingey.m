%% 1) Preamble and assigning variables 

% Assign variables similar to in the basic assignment. The only differences
% are in the 'Nexact' and the P variable. The P will be later to remove
% tuning errors.

Fs = 44100; f0 = 110; 
Nexact = Fs/f0 - 0.5;
N = floor(Nexact);
P = Nexact - N;
rho = 0.95; 
R = 0.95;

% set the length of the desired note in seconds and in samples. 

tEnd = 2; M = Fs*tEnd;  

%% Create white noise input vector  

v = 2*(rand(N,1)-0.5);
u = zeros(N,1);
u(1) = (1-R)*v(1);

for n = 2:N
    u(n) = (1-R) * v(n) + R * u(n-1);
end 

%% Use the Karplus-Strong algorithm

% Initialise the ynew vector to a length of N+M. Set the first N values of
% x to be the same as u. 

ynew = zeros(N+M,1);

x = zeros(N+M,1);
x(1:N) = u;

ynew(1:N) = x(1:N);

% Set the value of the N+1 term in the vector ynew. 

ynew(N+1) = (rho/2)*ynew(1);

% Use a for loop to implement the Karplus-Strong algorithm. Store the 
% output in the vector ynew to use later in a different loop. 

for n = N+2:M+N
    ynew(n) = x(n) + (rho/2)*(ynew(n-N) + ynew(n-(N+1)));
end 

% Normalise the ynew vector.

ynew = ynew/max(abs(ynew));

%% Use the fractional allpass algorithm

% Assign a value to the constant C using the formula in the assignment.
% Also, initialise the term ylast and set it equal to 0. 

C = (1-P)/(1+P);
ylast = 0;

% Initialise the y vector.

y = zeros(N+M,1);

% Use a for loop to implement the fractional delay all pass filter
% algorithm. Set ylast to equal ynew at the end of the loop through each
% iteration.

for n = 2:N+M
    y(n) = C*ynew(n) + ylast - C*y(n-1); 
    ylast = ynew(n);
end 

% Normalise the vector y.
y = y/max(abs(y));

%% Plotting the frequency spectrum

%Set L equal to the length of the output vector. Play the sound using
% soundsc.

L = N+M;
soundsc(y,Fs);

% Take the fast fourier transform of y so we can graph the frequency
% spectrum of y.

Y = abs(fft(y));

% Initialise variables so we can set the x-axis in terms of Frequency in
% Hz. Also, set the length of the x axis such that we can only see the
% frequency response up to around 1000Hz. 

bins = 0:(L)-1;
f_Hz = bins*Fs/(L);
S = ceil((L)/2);

%Plot the graph of the magnitude against frequency

plot(f_Hz(1:S/25), Y(1:S/25));

% Label the graph

xlabel('Frequency (Hz)')
ylabel('Magnitude');
title('Frequency spectrum (Hertz)');
axis tight

% From the graph we can see that there are noticeable magnitude peaks at
% frequencies of exactly every integer multiple of 110, which is the
% fundamental frequency. This shows that the note is more in tune than the
% basic assignment. 




