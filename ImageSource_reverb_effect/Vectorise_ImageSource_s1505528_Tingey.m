clear all 
close all 

%% Vectorise and combine even and odd cases

% In this extra credit script I will attempt to vectorise the Image
% Source method, while also combining the even and odd cases using powers of minus 1.
% I then apply reverb to a wav file using the convolution method in the frequency domain
% and play the sound.

%% Preamble and assigning variables

% Set the sample rate
Fs = 44100;

% Give dimensions of the room
Lx = 15.1;
Ly = 20.25;
Lz = 20.78;

% Put them into vector form
L = [Lx, Ly, Lz];

% Give an error code
if min(L) < 0
    error('Error, L values must be greater than 0.')
end 

% Position of listener
a = Lx/sqrt(2);
b = Ly/(2*sqrt(2));
c = Lz/sqrt(5);

% Vectorised Listener position
P = [a,b,c];

% Position of source
p = Lx/sqrt(3);
q = Ly/sqrt(7);
r = Lz/(2*sqrt(5));

% Vectorised source
S = [p,q,r];

% Error code
if a > Lx
    error('Error, listener must be located inside of the room.')
end 

if b > Ly
    error('Error, listener must be located inside of the room.')
end 

if c > Lz
    error('Error, listener must be located inside of the room.')
end 

% Areas
Axy = Lx*Ly;
Axz = Lx*Lz;
Ayz = Ly*Lz;

% Area vectorised
A = [Axy, Axz, Ayz];

% Volume
V  = Lx*Ly*Lz;

% Dry Coeff: found some coefficients online

 alpha1 = 0.5; % Heavy carpet on concrete
 alpha2 = 0.3; % Hardwood
 alpha3 = 0.2; % Plaster
 alpha4 = 0.2; % plaster
 alpha5 = 0.2; % Plaster
 alpha6 = 0.2; % Wood
 
 % Vectorise alpha coefficients
 Alpha = [alpha1,alpha2,alpha3,alpha4,alpha5,alpha6];
 
 % Error chech alpha coefficients
 if max(Alpha) >= 1
    error('Error, alpha values must be between 0 and 1.')
 end 

 if min(Alpha) <= 0
    error('Error, alpha values must be between 0 and 1.')
 end 
 
% Set the speed of sound
cair = 343;

% Set the value fo T_60
T = (24*log(10)*V)/(cair*(alpha1*Axy + alpha2*Axy + alpha3*Axz + alpha4*Axz + alpha5*Ayz + alpha6*Ayz));

% Set values of N to integers (maybe I don't need to do this in vector
% format??)

Nx = round((cair*T)/Lx);
Ny = round((cair*T)/Ly);
Nz = round((cair*T)/Lz);

% Set vectors running from -N to N
X = -Nx:Nx;
Y = -Ny:Ny;
Z = -Nz:Nz;

%% Distance in x, y, z dimensions

% Calculate parts of the equation that I will use to work out distances in
% x,y,z dimensions. The power of minus one means that the formula given in
% the assignment handout will still hold: for every odd value of X we minus,
% for every even value of X we add.
CX = X + (1 + (-1).^X)/2;
CY = Y + (1 + (-1).^Y)/2;
CZ = Z + (1 + (-1).^Z)/2;

% Work out distances in respective dimensions using formula in assignment
% sheet, but manipulated for vector format.
x = CX*L(1) + ((-1).^X)*S(1) - P(1);
y = CY*L(2) + ((-1).^Y)*S(2) - P(2);
z = CZ*L(3) + ((-1).^Z)*S(3) - P(3);

% Make 3D matrices of all the distances using the hint in the assignment to
% use later.
[x,y,z] = ndgrid(x,y,z);

% work out distance using pythagoras in 3D matrix format

l = sqrt(x.^2 + y.^2 + z.^2);

%% Find magnitudes

% Set 3D matrices for the indices so we can use them later to find
% magnitudes

[X1, Y1, Z1] = ndgrid(X,Y,Z);

% Set reflection coefficients

R1 = sqrt(1-alpha1);
R2 = sqrt(1-alpha2);
R3 = sqrt(1-alpha3);
R4 = sqrt(1-alpha4);
R5 = sqrt(1-alpha5);
R6 = sqrt(1-alpha6);

% Vectorise reflection coefficients
R = [R1,R2,R3,R4,R5,R5];

% Find R^w values. Similar method as in with for loops but easier to
% implement as the indices are simple. All calculations are done
% simultaneously so its more efficient. Also much clearer. 
% Each R^w value is calculated for each dimension separately. As before,
% there are max N/2 collisions with each wall in each direction.

Rx = R(1).^(abs(0.5.*X1 + (-1 + (-1).^X1)*0.25)).*R(2).^(abs(0.5.*X1 + (1 - (-1).^X1)*0.25));
Ry = R(3).^(abs(0.5.*Y1 + (-1 + (-1).^Y1)*0.25)).*R(4).^(abs(0.5.*Y1 + (1 - (-1).^Y1)*0.25));
Rz = R(5).^(abs(0.5.*Z1 + (-1 + (-1).^Z1)*0.25)).*R(6).^(abs(0.5.*Z1 + (1 - (-1).^Z1)*0.25));

% Work out totoal magnitude by pointwise multiplication of the three 3D
% matrices andusing formula in assignment.

g1 = Rx.*Ry.*Rz;
g = g1./l;

%% Create Impulse Response vector

% Work out time
t = l/cair;
% Work out time in samples. Add one to make it max time.
t_samples = round(t*Fs)+1;

% calculate IR vector using sparse/full method. It matches up the matrices
% of magnitude and of time and adds them together very efficiently. 

IR_vectorise = full(sparse(t_samples(:),1,g(:)));

% Take absolute value

IR_vectorise = IR_vectorise/max(abs(IR_vectorise));

% Plot graph. Interestingly, this graph seems a bit more full than my graph
% when I use for loops. Perhaps I had some inaccuracies in the basic
% assignment that vanish when vectorising it all? Right now the plot is
% commented out.

% plot(IR_vectorise)

% Play the sound of the Impulse response. Right now it is commented out,
 % soundsc(IR_vectorise,Fs);
 
%% Match the IR with a wav file using convolution

% Read in wav file
[y, Fs] = audioread('cath_cut.wav');

%Error check to make sure stereo wav files will also work

if size(y,2) == 2
    y = (y(:,1) + y(:,2))/2; 
end 
y;

% use frequency domain convolution as detailed in the basic assignment:
n = length(y); m = length(IR_vectorise);

% length of convolution vector
N = n + m - 1; 

% Determine power of 2 to zero pad the fft for efficiency
N_conv = 2^(nextpow2(N)); 

% Take the fft of the wav file input
Y=fft(y, N_conv); 		

% Take the fft of the Impulse Response 
XIR=fft(IR_vectorise, N_conv); 

% Take the pointwise multiplication of the two ffts 
R=Y.*XIR;       	   
% Transfer signal back into time domain 
reverb_signal = real(ifft(R, N_conv));   
% take only the length required (after N the vector is just zero padded)
reverb_signal = reverb_signal(1:N);     
% Obviously normalise the output
reverb_signal= reverb_signal/max(abs(reverb_signal)); 

% Play the reverb added wav. file:
soundsc(reverb_signal,Fs);

%% Conclusion: 

% Suprisingly I found vectorising it to be a bit simpler. Maybe I struggled
% with the for loops a bit as indexing each thing was a hassle. NDgrid
% function also makes things slightly easier.








