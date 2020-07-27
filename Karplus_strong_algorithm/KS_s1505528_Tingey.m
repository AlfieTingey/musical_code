%% Preamble and defining variables 

% This is the code for the basic Karplus-Strong Algorithm. 

% 2)
% Firstly, I assign values to some necessary variables: the sample rate,
% the frequency of the desired pitch, the length of the input vector, the 
% damping and the decay. 

Fs = 44100; f0 = 110;
N = round(Fs/f0 - 0.5); rho = 0.95; 
R = 0.95;

% 3) 
% set the length in seconds of the output note. I have gone for a 2 second
% note. The M helps define the size of the ouput vector.

tEnd = 2; M = Fs*tEnd; 

%% 4) 

% create a vector that represents white noise. I have scaled it so all
% values lie within the range [-1,1].

v = 2*(rand(N,1)-0.5);

%5) 

% this section I use a for loop to create an initial dynamics filter on the
% white noise. I assign the n = 1 term independently so there are no errors
% in the for loop. I use the algorithm as defined in the notes. 

u = zeros(N,1);

u(1) = (1-R)*v(1);

for n = 2:N
    u(n) = (1-R) * v(n) + R * u(n-1);
end 

%% 6) Karplus Strong algorithm implementation

% Firstly, I initialise the length of the output vector, which will be N+M
% samples long. I let the vector x be the same length as the y vector so
% there are no errors, and I assign the first N values of the x vector as
% that of the u vector. 

y = zeros(N+M,1);

x = zeros(N+M,1);
x(1:N) = u;

% I then set the first N+1 values of the y vector as that of the u vector. I
% do this outside the for loop so there are no negative indeces used in the
% loop which would cause an error.

y(1:N) = x(1:N);
y(N+1) = (rho/2)*y(1);

% Now I use a for loop to implement the Karplus-Strong algorithm. 

for n = N+2:M+N
    y(n) = x(n) + (rho/2)*(y(n-N) + y(n-(N+1)));
end 

%% Sound

% 7)

% Here I normalise the output vector so all amplitudes are less than or
% equal to 1. 

y = y/max(abs(y));

% create the sound of the plucked guitar string using soundsc command. 

soundsc(y,Fs);

% 8)
% write the sound into a wav file

% audiowrite('A_string_110_0.95_0.95.wav', y, Fs);






    







