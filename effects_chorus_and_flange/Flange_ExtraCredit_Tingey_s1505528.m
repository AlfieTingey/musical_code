%% Pre-Amble and variable assignment 

W = 8; Q = 100; % set values for the interpolating table... here I took N = 8, Q = 100. Make sure W is an even integer. 
Table = interptab_Tingey_s1505528(W,Q);

Table; % read in the interpolating table from q2

[x,Fs] = audioread('cath_cut.wav');

if size(x,2) == 2
    x = (x(:,1) + x(:,2))/2; % use 'if' loop to make sure stereo signals also work
end 

N = length(x);

x = x';

g1 = 0.5;

F01 = 25; % I find values for F01 that give the best effect are between 20 and 100. When I choose something like 400 I hear two voices... a bit like the chorus effect. 
f1 = 1.75;

n = 1:N;
Ts = 1/Fs;

F1 = F01*(1+sin(2*pi*n*f1*Ts)); % Here I use the equation for flange... almost same as Chorus Equation but without the D1.
F1 = [zeros(1,F01),F1];

x = [zeros(1,F01),x];

v = zeros(1,N+F01); % pre-assign some variables that I will use when I use interpolating table. 
u = zeros(1,N+F01);
j = zeros(1,N+F01);
X1 = zeros(1,N+F01);

q = 1:Q; 
alpha = (-Q/2 +q -1)/Q; % introduce alpha
ind = zeros(1,N+F01); % introduce position variable (of alpha)

for k = F01+50:N+F01
    u(k) = k - F1(k);
    v(k) = u(k) - floor(u(k))-0.5;
    [j(k),ind(k)] = min(abs(alpha - v(k).*ones(Q,1)')); 
    X1(k) = Table(ind(k),:)*x(round(u(k))-W/2:round(u(k))+W/2-1)';
end 

y = zeros(1,N+F01);

% Read in the values into my output signal y using the equation for flange
% effect. 
    
for k = F01+50:N+F01

y(k) = x(k) + g1*X1(k); % stick the formula for flange into a for loop and read in values for output signal. 

end;

soundsc(y,Fs); 
