%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%% ASSIGNMENT 6: PMMI
%%%%% 
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
clear all

%%%%% options
opts.plot_on = false;
opts.useforloop = true;
opts.add_stiffness = true;
opts.input_type = 'plucked';
opts.output_type = 'displacement';
opts.bctype = 'clamped';
%opts.bctype = 'simply_supported';

%% Explanation

% I found lots of variables online corresponding to a Fender acoustic guitar. I did
% a little bit of tweaking aurally to get the notes as closely in tune as I could. 
% I then provide both a staccato and legato style ascending order of open strings
% with standard tuning... as I didn't know which type you wanted. 

%% Low E note 

%%%%% physical string parameters 
phys_param.T = 67;                     % tension (N)
phys_param.r = 0.0005334;                 % string radius (m)
phys_param.rho = 6600;                 % density (kg/m^3)
phys_param.T60 = 4;                    % T60 (s)
phys_param.L = 0.69;                      % length (m)
phys_param.E = 1.88e11;                   % Young's modulus (Pa)

%%%%% simulation parameters 
sim_param.SR = 44100;                  % sample rate (Hz)
sim_param.Tf = 4;                      % duration of simulation (s)
sim_param.xi = 0.9;                    % coordinate of excitation (normalised, 0-1)
sim_param.famp = 1;                    % peak amplitude of excitation (N)
sim_param.dur = 0.001;                 % duration of excitation (s)
sim_param.exc_st = 0.01;               % start time of excitation (s)
sim_param.xo = 0.1;                    % coordinate of output (normalised, 0-1)

yE1 = string_fdtd_s1505528(opts,phys_param,sim_param);
%soundsc(yE1,sim_param.SR);

%% A note
phys_param.T = 76.5;                     % tension (N)
phys_param.r = 0.0004064;                 % string radius (m)
phys_param.rho = 6750;                 % density (kg/m^3)
phys_param.T60 = 4;                    % T60 (s)
phys_param.L = 0.69;                      % length (m)
phys_param.E = 1.88e11;                   % Young's modulus (Pa)

sim_param.SR = 44100;                  % sample rate (Hz)
sim_param.Tf = 4;                      % duration of simulation (s)
sim_param.xi = 0.7;                    % coordinate of excitation (normalised, 0-1)
sim_param.famp = 0.95;                    % peak amplitude of excitation (N)
sim_param.dur = 0.0005;                 % duration of excitation (s)
sim_param.exc_st = 0.001;               % start time of excitation (s)
sim_param.xo = 0.05;                    % coordinate of output (normalised, 0-1)

yA = string_fdtd_s1505528(opts,phys_param,sim_param);
%soundsc(yA,sim_param.SR);

%% D note
phys_param.T = 63.5;                     % tension (N)
phys_param.r = 0.0003048;                 % string radius (m)
phys_param.rho = 5480;                 % density (kg/m^3)
phys_param.T60 = 4;                    % T60 (s)
phys_param.L = 0.69;                      % length (m)
phys_param.E = 1.88e11;                   % Young's modulus (Pa)

sim_param.SR = 44100;                  % sample rate (Hz)
sim_param.Tf = 4;                      % duration of simulation (s)
sim_param.xi = 0.75;                    % coordinate of excitation (normalised, 0-1)
sim_param.famp = 0.9;                    % peak amplitude of excitation (N)
sim_param.dur = 0.0005;                 % duration of excitation (s)
sim_param.exc_st = 0.003;               % start time of excitation (s)
sim_param.xo = 0.12;                    % coordinate of output (normalised, 0-1)

yD = string_fdtd_s1505528(opts,phys_param,sim_param);
%soundsc(yD,sim_param.SR);

%% G note

phys_param.T = 73.7;                     % tension (N)
phys_param.r = 0.0002032;                 % string radius (m)
phys_param.rho = 7990;                 % density (kg/m^3)
phys_param.T60 = 4;                    % T60 (s)
phys_param.L = 0.69;                      % length (m)
phys_param.E = 1.88e11;                   % Young's modulus (Pa)

sim_param.SR = 44100;                  % sample rate (Hz)
sim_param.Tf = 4;                      % duration of simulation (s)
sim_param.xi = 0.79;                    % coordinate of excitation (normalised, 0-1)
sim_param.famp = 0.85;                    % peak amplitude of excitation (N)
sim_param.dur = 0.0015;                 % duration of excitation (s)
sim_param.exc_st = 0.008;               % start time of excitation (s)
sim_param.xo = 0.18;                    % coordinate of output (normalised, 0-1)

yG = string_fdtd_s1505528(opts,phys_param,sim_param);
%soundsc(yG,sim_param.SR);

%% B note
phys_param.T = 54;                     % tension (N)
phys_param.r = 0.0001397;                 % string radius (m)
phys_param.rho = 7830;                 % density (kg/m^3)
phys_param.T60 = 4;                    % T60 (s)
phys_param.L = 0.69;                      % length (m)
phys_param.E = 1.88e11;                   % Young's modulus (Pa)

sim_param.SR = 44100;                  % sample rate (Hz)
sim_param.Tf = 4;                      % duration of simulation (s)
sim_param.xi = 0.14;                    % coordinate of excitation (normalised, 0-1)
sim_param.famp = 0.8;                    % peak amplitude of excitation (N)
sim_param.dur = 0.0015;                 % duration of excitation (s)
sim_param.exc_st = 0.004;               % start time of excitation (s)
sim_param.xo = 0.2;                    % coordinate of output (normalised, 0-1)

yB = string_fdtd_s1505528(opts,phys_param,sim_param);
%soundsc(yB,sim_param.SR);

%% E2 note
phys_param.T = 65.5;                     % tension (N)
phys_param.r = 0.0001143;                 % string radius (m)
phys_param.rho = 7970;                 % density (kg/m^3)
phys_param.T60 = 4;                    % T60 (s)
phys_param.L = 0.69;                      % length (m)
phys_param.E = 1.88e11;                   % Young's modulus (Pa)

sim_param.SR = 44100;                  % sample rate (Hz)
sim_param.Tf = 4;                      % duration of simulation (s)
sim_param.xi = 0.18;                    % coordinate of excitation (normalised, 0-1)
sim_param.famp = 0.75;                    % peak amplitude of excitation (N)
sim_param.dur = 0.0012;                 % duration of excitation (s)
sim_param.exc_st = 0.004;               % start time of excitation (s)
sim_param.xo = 0.1;                    % coordinate of output (normalised, 0-1)

yE2 = string_fdtd_s1505528(opts,phys_param,sim_param);
%soundsc(yE2,sim_param.SR);

%% Play ascending open strings on guitar 

% I have given two options, either staccato style where there is no overlap
% between the strings (i.e. the guitar player stops the string at the
% same time as playing the next one) and legato style where there is no
% stopping of the strings and they overlap. Just uncomment the sound that
% you want to hear. 

% Play staccato style separated by 0.5 seconds
Ys = [yE1(1:0.5*sim_param.SR); yA(1:0.5*sim_param.SR); yD(1:0.5*sim_param.SR); yG(1:0.5*sim_param.SR); yB(1:0.5*sim_param.SR); yE2(1:0.5*sim_param.SR)];
Ys = Ys/max(abs(Ys));
%soundsc(Ys,sim_param.SR);

% Play legato style separated by 0.5 seconds
yE1l = [yE1;zeros(2.5*sim_param.SR,1)];
yAl = [zeros(0.5*sim_param.SR,1);yA;zeros(2*sim_param.SR,1)]; yDl = [zeros(sim_param.SR,1);yD;zeros(1.5*sim_param.SR,1)]; yGl = [zeros(1.5*sim_param.SR,1);yG;zeros(1*sim_param.SR,1)]; yBl = [zeros(2*sim_param.SR,1);yB;zeros(0.5*sim_param.SR,1)]; yE2l = [zeros(2.5*sim_param.SR,1);yE2];
Yl = [yE1l + yAl + yDl + yGl + yBl + yE2l];
Yl = Yl/max(abs(Yl));
soundsc(Yl,sim_param.SR);



