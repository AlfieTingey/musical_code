%% Pre-amble and assigning variables

W = 8; Q = 100;
Table = interptab_Tingey_s1505528(W,Q);

Table; % read in the interpolating table from q2

[x,Fs] = audioread('cath_cut.wav');

if size(x,2) == 2
    x = (x(:,1) + x(:,2))/2; % use 'if' loop to make sure stereo signals also work
end 

N = length(x);

x = x';

g1 = 0.5;
g2 = 0.5;

M01 = 400; 
M02 = 300;
Max = max(M01,M02);
x = [zeros(1,Max),x]; % preassign x and zero pad so that the for loop I use later will work.
D1 = 100/M01; D2 = 50/M02; % choose D1 so that D1 gives the effect oscillation and M1 chooses the starting point.
f1 = 1.75; f2 = 2; % choose some frequencies

n = 1:N;
Ts = 1/Fs;

%% Calculating M1 and M2 (sine functions)

M1 = M01*(1+D1*sin(2*pi*n*f1*Ts));
M2 = M02*(1+D2*sin(2*pi*n*f2*Ts));

M1 = [zeros(1,Max),M1];
M2 = [zeros(1,Max),M2];

v = zeros(1,N+Max);
u = zeros(1,N+Max);
j = zeros(1,N+Max);
X1 = zeros(1,N+Max);

%% Interpolate for M1 and M2

q = 1:Q; 
alpha = (-Q/2 +q -1)/Q;
ind = zeros(1,N+Max);
X2 = zeros(1,N+Max);

for k = Max+50:N+Max
    u(k) = k - M1(k);
    v(k) = u(k) - floor(u(k))-0.5;
    [j(k),ind(k)] = min(abs(alpha - v(k).*ones(Q,1)'));
    X1(k) = Table(ind(k),:)*x(round(u(k))-W/2:round(u(k))+W/2-1)';
end 

for k = Max+50:N+Max
    u(k) = k - M2(k);
    v(k) = u(k) - floor(u(k))-0.5;
    [j(k),ind(k)] = min(abs(alpha - v(k).*ones(Q,1)'));
    X2(k) = Table(ind(k),:)*x(round(u(k))-W/2:round(u(k))+W/2-1)';
end

%% Create Output signal for Left column of stereo output

y = zeros(1,N+Max);

for k = Max+50:N+Max

y(k) = x(k) + g1*X1(k) + g2*X2(k); % stick the formula for chorus into a for loop and read in values for output signal. 

end;

%% Calculate M3 and M4 (cosine functions)

M03 = M01;
M04 = M02;
D3 = D1;
D4 = D2;
f3 = f1;
f4 = f2;

M3 = M03*(1+D3*cos(2*pi*n*f3*Ts));
M4 = M04*(1+D4*cos(2*pi*n*f4*Ts));

M3 = [zeros(1,Max),M1];
M4 = [zeros(1,Max),M2];

X3 = zeros(1,N+Max);
X4 = zeros(1,N+Max);

%% Interpolate for M3 and M4 using same method as before

for k = Max+50:N+Max
    u(k) = k - M3(k);
    v(k) = u(k) - floor(u(k))-0.5;
    [j(k),ind(k)] = min(abs(alpha - v(k).*ones(Q,1)'));
    X3(k) = Table(ind(k),:)*x(round(u(k))-W/2:round(u(k))+W/2-1)';
end 

for k = Max+50:N+Max
    u(k) = k - M4(k);
    v(k) = u(k) - floor(u(k))-0.5;
    [j(k),ind(k)] = min(abs(alpha - v(k).*ones(Q,1)'));
    X4(k) = Table(ind(k),:)*x(round(u(k))-W/2:round(u(k))+W/2-1)';
end 


%% Create a an output signal for right column of stereo output

c = zeros(1,N+Max);

for k = Max+50:N+Max
    
c(k) = x(k) + g1*X3(k) + g2*X4(k);
    
end 

%% Create Stereo output Signal for y1
Stereo_Chorus = zeros(N+Max,2);

Stereo_Chorus(:,1) = y';
Stereo_Chorus(:,2) = c'; % Stereo_Chorus has two columns with first signal corresponding to signal y and second column corresponding to signal c.

Stereo_Chorus;

% Note: I have not commented much on this script as it is pretty much the 
% same method as the previous question. I create a second signal almost 
% exactly the same as in question 3 however just with a cosine instead 
% of a sine.  






