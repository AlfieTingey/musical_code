%% Pre-Amble and variable assignment 
tic
W = 8; Q = 100; % set values for the interpolating table... here I took N = 8, Q = 100.
Table = interptab_Tingey_s1505528(W,Q);

Table; % read in the interpolating table from q2

[x,Fs] = audioread('cath_cut.wav');

if size(x,2) == 2
    x = (x(:,1) + x(:,2))/2; % use 'if' loop to make sure stereo signals also work
end 

N = length(x);

x = x';

g1 = 0.5; % set gain values between -1 and 1
g2 = 0.5;

M01 = 600; % choose appropriate values for M01 and M02. 
M02 = 400;
Max = max(M01,M02); % here I take the max of the two values for later calculationd to make sure i never get negative indices for a matrix. 
x = [zeros(1,Max),x]; % preassign x and zero pad so that the for loop I use later will work. 
D1 = 200/M01; D2 = 100/M02; % choose D1 so that D1 gives the effect oscillation and M1 chooses the starting point.
f1 = 1.75; f2 = 2; % choose some frequencies

n = 1:N;
Ts = 1/Fs;

%% Caluculating M1 and M2

M1 = M01*(1+D1*sin(2*pi*n*f1*Ts)); % equation to compute M1 and M2 from lecture notes.
M2 = M02*(1+D2*sin(2*pi*n*f2*Ts)); % the D1 and D2 are important so that the graphs look very similar to those shown in the lecture notes. 

M1 = [zeros(1,Max),M1]; % zero pad a little bit to make sure I can do calculations later with no errors occurring. 
M2 = [zeros(1,Max),M2];

v = zeros(1,N+Max); % pre-assign some variables that I will use when I use interpolating table. 
u = zeros(1,N+Max);
j = zeros(1,N+Max);
X1 = zeros(1,N+Max);

q = 1:Q; 
alpha = (-Q/2 +q -1)/Q; % introduce alpha
ind = zeros(1,N+Max); % introduce position variable (of alpha)
X2 = zeros(1,N+Max);

%% Using the Interpolating table to Smooth results

% I will quickly comment here about my method for the next section. I have two
% for loops which interpolate the M1 term and the M2 term respectively with x. 
% To implement my table I take each individual value of n - M1(n) (or n - M2(n)) and put
% it into the range (-0.5,0.5) so each value can be associated with a
% certain 'alpha' value from question 2 (this is v(k) in the for loop). 
% Then I try and find which value of alpha each n - M1 value is closest to
% using the 'min' function with ind(k). Then I use the coefficients from
% the table, with W (in this case 8) neighbouring values from my x signal which are
% closest to the respective M1 value, to create a smooth output signal x(n-M(n)). 
% Kind of complicated! Also, I take the starting point in the for loop to be 'Max +
% 50' so the indices never go minus. 


for k = Max+50:N+Max
    u(k) = k - M1(k);
    v(k) = u(k) - floor(u(k))-0.5;
    [j(k),ind(k)] = min(abs(alpha - v(k).*ones(Q,1)')); % the Ones matrix here is to make matrix dimensions agree
    X1(k) = Table(ind(k),:)*x(round(u(k))-W/2:round(u(k))+W/2-1)';
end 

for k = Max+50:N+Max
    u(k) = k - M2(k);
    v(k) = u(k) - floor(u(k))-0.5;
    [j(k),ind(k)] = min(abs(alpha - v(k).*ones(Q,1)'));
    X2(k) = Table(ind(k),:)*x(round(u(k))-W/2:round(u(k))+W/2-1)';
end 

%% Produce an output signal

y = zeros(1,N+Max);

% Read in the values into my output signal y using the equation for chorus
% effect. 
    
for k = Max+50:N+Max

y(k) = x(k) + g1*X1(k) + g2*X2(k); % stick the formula for chorus into a for loop and read in values for output signal. 

end;

soundsc(y,Fs); % play the sound. 
toc 