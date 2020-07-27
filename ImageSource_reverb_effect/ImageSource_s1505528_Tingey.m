clear all
close all

%% Preamble and assigning variables 

Fs = 44100; % select a sample rate for later calaculations

% Length of each wall:

% Large room
Lx = 15.1;
Ly = 20.25;
Lz = 20.78;

%small room
%Lx = 8.23;
%Ly = 6.12;
%Lz = 7.55;

L =[Lx,Ly,Lz];

if min(L) < 0
    error('Error, L values must be greater than 0.')
end 

% Position of listener. Add in an error to state that the listener must be
% inside the dimensions of the room (if any of the dimensions for the 
% listener are greater than the dimensions of the room then throw an error).
% Listener dimensions are irrational.

a = Lx/sqrt(2);
b = Ly/(2*sqrt(2));
c = Lz/sqrt(5);

if a > Lx
    error('Error, listener must be located inside of the room.')
end 

if b > Ly
    error('Error, listener must be located inside of the room.')
end 

if c > Lz
    error('Error, listener must be located inside of the room.')
end 

% Position of original source. Add in an error to state that the source must be
% inside the dimensions of the room. Choose irrational positions.

p = Lx/sqrt(3);
q = Ly/sqrt(7);
r = Lz/(2*sqrt(5));

if p > Lx
    error('Error, source must be located inside of the room.')
end 

if q > Ly
    error('Error, source must be located inside of the room.')
end 

if r > Lz
    error('Error, source must be located inside of the room.')
end 

% Assign the areas of each wall
Axy = Lx*Ly;
Axz = Lx*Lz;
Ayz = Ly*Lz;

% Assign the volume of the wall
V  = Lx*Ly*Lz;

%% Absorption coefficients

% set values for the absorption coefficient of each wall.

% Wet coeff: Used these for wet wav files
%alpha1 = 0.21; % absorption for xy (floor) Carpet
%alpha2 = 0.2; % absorption for yx (ceiling) Wood
%alpha3 = 0.2; % absorption for xz (wall 1) wood
%alpha4 = 0.03; % absorption for zx (wall 2 opposite wall 1) Brick
%alpha5 = 0.2; % absorption for yz (wall 3) wood
%alpha6 = 0.03; % absorption for zy (wall 4 opposite wall 3) Brick

% Dry Coeff: found some coefficients online: used these for dry wet wav files
 alpha1 = 0.5; % Heavy carpet on concrete
 alpha2 = 0.3; % Hardwood
 alpha3 = 0.2; % Plaster
 alpha4 = 0.95; % Polyurethane foam (interesting one. very insulated wall!)
 alpha5 = 0.2; % Plaster
 alpha6 = 0.2; % Wood

% Error check the alpha values. 

alpha = [alpha1, alpha2, alpha3, alpha4, alpha5, alpha6];
if max(alpha) >= 1
    error('Error, alpha values must be between 0 and 1.')
end 

alpha = [alpha1, alpha2, alpha3, alpha4, alpha5, alpha6];
if min(alpha) <= 0
    error('Error, alpha values must be between 0 and 1.')
end 

% Set the speed of sound
cair = 343;

% Set the value fo T_60
T = (24*log(10)*V)/(cair*(alpha1*Axy + alpha2*Axy + alpha3*Axz + alpha4*Axz + alpha5*Ayz + alpha6*Ayz));

%% For loop to calculate distances in x,y,z directions

% Firstly I calculate each value of N from Sabine's equation in the
% respective x, y, and z directions. To do this I modified the equation to
% divide by the respective length instead of the mininum length.

% Additionally, I have been a little bit cheeky. In my for loop below to
% be able to go through the loop for both even and odd numbers without
% indexing errors (such as negative indices or indices = 0) I have ensured
% that all values of N are always even numbers. I know this isn't
% necessarily great to do, but I really doubt it makes noticeable difference. 
% There is further explanation below. 

Nx = (cair*T)/Lx;
Nx = 2*ceil(Nx/2);
Ny = (cair*T)/Ly;
Ny = 2*ceil(Ny/2);
Nz = (cair*T)/Lz;
Nz = 2*ceil(Nz/2);

% Pre-allocate distance vectors 

A = zeros(1,2*Nx);
B = zeros(1,2*Ny);
C = zeros(1,2*Nz);

% Explanation of for loop: my for loop is very convoluted but I am certain
% that it gets the job done. I will explain as I go through it.

% Firstly, I allocate what will be the first term in each A, B and C vector.
% This term will correlate to the '-N' term in the equation. Also, note
% that N will always be even, therefore we use the formula for an even
% index. 

A1 = -Nx*Lx + p -a;
B1 = -Ny*Ly + p -a;
C1 = -Nz+Lz + -a;

% Secondly, I run a loop through all of the odd indices up to each N value.
% I calculate the negative terms and positive terms individually. All of
% the negative values of each N will be put in the first half of each
% vector. All of the positive values of each N will be put in the second.
% The 0th term will be in the middle. (e.g. A(1) corresponds to the term
% involving (-Nx+1), A(3) to (-Nx+3), etc... etc...). 

for d = 1:2:Nx
    for e = 1:2:Ny
        for f = 1:2:Nz
    A(d) = (-Nx+d+1)*Lx - p - a;
    A(Nx+d) = (d+1)*Lx - p - a;
    B(e) = (-Ny+e+1)*Ly - q - b;
    B(Ny+e) = (e+1)*Ly - q - b;
    C(f) = (-Nz+f+1)*Lz - r - c;
    C(Nz+f) = (f+1)*Lz - r - c;
        end 
    end 
end 

% Thirdly I run through the loop through all of the even indices up to each
% N value. I calculate the negative and positive terms individually again.
% A(Nx) corresponds to zero term. 

    for d = 2:2:Nx
        for e = 2:2:Ny
            for f = 2:2:Nz
    A(d) = (-Nx+d)*Lx + p - a;
    A(Nx+d) = d*Lx + p - a;
    B(e) = (-Ny+e)*Ly + q - b;
    B(Ny+e) = e*Ly + q - b;
    C(f) = (-Nz+f)*Lz + r - c;
    C(Nz+f) = f*Lz + r - c;
            end 
        end 
    end 
    
% Finally add in the first term (corresponding to -N) into the vector A.
% Vector A will have length 2*Nx+1, B: 2*Ny+1 and C: 2*Nz+1. 
A = [A1, A];
B = [B1, B];
C = [C1, C];

%% Calculate the length of each virtual impulse

% Pre-allocate a vector that will take all the lengths.

l = zeros(2*Nx+1, 2*Ny+1, 2*Nz+1);

% Do a nested for loop to insert formula.

for d = 1:2*Nx+1
    for e = 1:2*Ny+1
        for f = 1:2*Nz+1
l(d,e,f) = sqrt(A(d)^2 + B(e)^2 + C(f)^2);
        end
    end
end

%% Allocate reflection coefficients

% Set the values of each of the reflection coefficients for each wall. 
% Pre-allocate the size for the magnitude vector.

g1 = zeros(2*Nx+1, 2*Ny+1, 2*Nz+1);
R1 = sqrt(1-alpha1);
R2 = sqrt(1-alpha2);
R3 = sqrt(1-alpha3);
R4 = sqrt(1-alpha4);
R5 = sqrt(1-alpha5);
R6 = sqrt(1-alpha6);

%% Calculate magnitude of each virtual source

% Start a for loop to calculate the magnitude of each virtual impulse
% response and store it in the vector g. Now, for only one alpha
% coefficient this equation is very simple, and is just like this:
% g1(d,e,f) = sqrt(1 - alpha1)^(abs(Nx-d) + abs(Ny-e) + abs(Nz - f)).
% However, when we consider 6 different R values it becomes tricky. The way
% I thought about it is like this: For a given value of d the sound will 
% collide with two different walls a maximum of Nx/2 times each. For a d that is
% even, it will hit both walls the same amount of times. For a d that is
% odd, one wall will be hit one more time than the other. Which wall
% depends on the sign of d. If d is odd and negative, then the left wall gets hit
% one more time, and if d is odd and positive then the right wall gets hit
% one more time. This is the same theory for e and f too.
% I have combined all of this information into one equation
% using powers of minus one. Matching each indice in the range -N < ind < N is
% why there is that factor of (N+1) in the equation. This was a hard
% calculation... I am not 100% positive I have the perfect theory.

% Allocate vectors for magnitude values in x,y and z directions

Rx = zeros(1,2*Nx);
Ry = zeros(1,2*Ny);
Rz = zeros(1,2*Nz);

for d = 1:2*Nx+1
    for e = 1:2*Ny+1
        for f = 1:2*Nz+1
            Rx(d) = R1^(abs(((Nx+1)-d)/2 + (-1 + (-1)^((Nx+1)-d)/2)*0.25))*R2^(abs(((Nx+1)-d)/2 + (1 - (-1)^((Nx+1)-d)/2)*0.25));
            Ry(e) = R3^(abs(((Ny+1)-e)/2 + (-1 + (-1)^((Ny+1)-e)/2)*0.25))*R4^(abs(((Ny+1)-e)/2 + (1 - (-1)^((Ny+1)-e)/2)*0.25));
            Rz(f) = R5^(abs(((Nz+1)-f)/2 + (-1 + (-1)^((Nz+1)-f)/2)*0.25))*R6^(abs(((Nz+1)-f)/2 + (1 - (-1)^((Nz+1)-f)/2)*0.25));
                g1(d,e,f) =  Rx(d)*Ry(e)*Rz(f);
        end 
    end 
end 
 
g = g1./l;

%% calculate time matrices

t = l/cair; % time in seconds of each 

t_samples = round(t*Fs)+1; % Calculate maximum amount of time for each distance. Also allocates time to nearest bin.

%% Make Impulse Response

% pre allocate IR value as the max amount of samples for the time of max distance

IR = zeros(1,max(t_samples(:)));

% After research into sparse and full functions I find this is the most
% efficient way of making the Impulse response IR. Sparse function breaks
% apart both t_samples and g and matches the g to the corresponding t_samples bin.
% The full function then makes the IR vector by piecing it together again in order. 

IR = full(sparse(t_samples(:),1,g(:)));

% Normalise the impulse response.

IR = IR/max(abs(IR));

% Plot the Impulse response to make sure it looks correct. Commented out
% for now.

% plot(IR); xlim([0,40000]); xlabel('Time (samples)'); ylabel('Magnitude'); title('Impulse Response');

%% Write wav files names:

% Round each dimension to 1 decimal place
Lzr = round(Lz,1);
Lxr = round(Lx,1);
Lyr = round(Ly,1);

% use num2str to write wav file later
roomsizex = num2str(Lxr);
roomsizey = num2str(Lyr);
roomsizez = num2str(Lzr);

% Calculate Alpha to find the mean absorption coefficient
Alpha = (alpha1*Axy + alpha2*Axy + alpha3*Axz + alpha4*Axz + alpha5*Ayz + alpha6*Ayz)/(2*Axy+2*Axz+2*Ayz);

% Set a loop to decide if the room is 'wet' or 'dry'. I set the cutoff
% between 'wet' and 'dry' as 0.2 but I don't really know what it would
% be. For me it is 0.2.

if Alpha < 0.25
    desc = 'wet';
end 

if Alpha >= 0.25
    desc = 'dry';
end 

% Use this for wav filename
descr = num2str(desc);
    
% Set the filename 

filename = ['IR_',roomsizex,'_',roomsizey,'_',roomsizez,'_',descr,'_s1505528_Tingey.wav'];
Fs = 44100;

% I used the code below to write my wav files. Sample rate is 44100 and
% bit depth is 16. It is commented out for submission.

% audiowrite(filename, IR, Fs, 'BitsPerSample',16);

% soundsc(IR,Fs); Play the sound

%% Conclusion
% Final comment: In the graph (which is commented out)
% there is an exponentially decaying signal with greater density as time
% increases, therefore the IR is definitely along the right lines. When I
% pair it to a wav signal it sounds fairly good... I don't know if it is
% correct though. To be honest I found this assignment very challenging and
% it took a lot of time. The reverb sounded a bit more accurate when I did
% the assignment with only one alpha... so maybe my magnitude calculations
% are slightly off for many alphas, or maybe this is just what it is meant 
% to sound like.
    
    
    
    










    
    
    
    










    
    
    
    







