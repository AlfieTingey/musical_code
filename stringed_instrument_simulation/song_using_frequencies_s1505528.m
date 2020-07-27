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

% This is code that creates 10s of the song 'Stairway to Heaven'. I load in
% all of the different frequencies that I require and then I manipulate
% them to give the song. Obviously it sounds a bit silly.... quite fun
% though. There are many ways I could make this sound better... an obvious
% one would be to make the notes legato style but to do this I
% would have to create the vector individaully for each then add them all
% in at then end and pad with loads of zeros. I could try this. I work out
% all the different frequencies of each note using ratios to the
% fundamental... therefore we can play this song on any starting note we
% want. 

%% Create all the frequencies that we need 

% We create all the frequencies using the fundamental frequency and
% different ratios corresponding to the root note. 

%Low E note 

f = 150;

% create an error. any starting frequency less than 50 will give an ugly
% sound. 

if f <= 50
    error('f must be positive frequency less than 50.')
end 

%%%%% physical string parameters 
%phys_param.T = 67;                     % tension (N)
phys_param.r = 0.0005334;                 % string radius (m)
phys_param.rho = 6600;                 % density (kg/m^3)
phys_param.T60 = 4;                    % T60 (s)
phys_param.L = 0.69;                      % length (m)
phys_param.E = 1.88e11;                 % Young's modulus (Pa)
phys_param.f0 = f;
%%%%% simulation parameters 
sim_param.SR = 44100;                  % sample rate (Hz)
sim_param.Tf = 0.41666666666;                      % duration of simulation (s)
sim_param.xi = 0.9;                    % coordinate of excitation (normalised, 0-1)
sim_param.famp = 1;                    % peak amplitude of excitation (N)
sim_param.dur = 0.001;                 % duration of excitation (s)
sim_param.exc_st = 0.01;               % start time of excitation (s)
sim_param.xo = 0.1;                    % coordinate of output (normalised, 0-1)

yA = frequency_string_fdtd_s1505528(opts,phys_param,sim_param);
%soundsc(yA,sim_param.SR);

phys_param.r = 0.0005334;                 % string radius (m)
phys_param.rho = 6600;                 % density (kg/m^3)
phys_param.T60 = 4;                    % T60 (s)
phys_param.L = 0.69;                      % length (m)
phys_param.E = 1.88e11;                 % Young's modulus (Pa)
phys_param.f0 = f*(3/2);
%%%%% simulation parameters 
sim_param.SR = 44100;                  % sample rate (Hz)
sim_param.Tf = 0.41666666666;                      % duration of simulation (s)
sim_param.xi = 0.9;                    % coordinate of excitation (normalised, 0-1)
sim_param.famp = 1;                    % peak amplitude of excitation (N)
sim_param.dur = 0.001;                 % duration of excitation (s)
sim_param.exc_st = 0.01;               % start time of excitation (s)
sim_param.xo = 0.1;                    % coordinate of output (normalised, 0-1)


yE = frequency_string_fdtd_s1505528(opts,phys_param,sim_param);
%soundsc(yE,sim_param.SR);

phys_param.r = 0.0005334;                 % string radius (m)
phys_param.rho = 6600;                 % density (kg/m^3)
phys_param.T60 = 4;                    % T60 (s)
phys_param.L = 0.69;                      % length (m)
phys_param.E = 1.88e11;                 % Young's modulus (Pa)
phys_param.f0 = f*(6/5);
%%%%% simulation parameters 
sim_param.SR = 44100;                  % sample rate (Hz)
sim_param.Tf = 0.41666666666;                      % duration of simulation (s)
sim_param.xi = 0.9;                    % coordinate of excitation (normalised, 0-1)
sim_param.famp = 1;                    % peak amplitude of excitation (N)
sim_param.dur = 0.001;                 % duration of excitation (s)
sim_param.exc_st = 0.01;               % start time of excitation (s)
sim_param.xo = 0.1;                    % coordinate of output (normalised, 0-1)

yC = frequency_string_fdtd_s1505528(opts,phys_param,sim_param);


phys_param.r = 0.0005334;                 % string radius (m)
phys_param.rho = 6600;                 % density (kg/m^3)
phys_param.T60 = 4;                    % T60 (s)
phys_param.L = 0.69;                      % length (m)
phys_param.E = 1.88e11;                 % Young's modulus (Pa)
phys_param.f0 = f*(2);
%%%%% simulation parameters 
sim_param.SR = 44100;                  % sample rate (Hz)
sim_param.Tf = 0.41666666666;                      % duration of simulation (s)
sim_param.xi = 0.9;                    % coordinate of excitation (normalised, 0-1)
sim_param.famp = 1;                    % peak amplitude of excitation (N)
sim_param.dur = 0.001;                 % duration of excitation (s)
sim_param.exc_st = 0.01;               % start time of excitation (s)
sim_param.xo = 0.1;                    % coordinate of output (normalised, 0-1)

yA2 = frequency_string_fdtd_s1505528(opts,phys_param,sim_param);

phys_param.r = 0.0005334;                 % string radius (m)
phys_param.rho = 6600;                 % density (kg/m^3)
phys_param.T60 = 4;                    % T60 (s)
phys_param.L = 0.69;                      % length (m)
phys_param.E = 1.88e11;                 % Young's modulus (Pa)
phys_param.f0 = f*(15/16);
%%%%% simulation parameters 
sim_param.SR = 44100;                  % sample rate (Hz)
sim_param.Tf = 0.41666666666;                      % duration of simulation (s)
sim_param.xi = 0.9;                    % coordinate of excitation (normalised, 0-1)
sim_param.famp = 1;                    % peak amplitude of excitation (N)
sim_param.dur = 0.001;                 % duration of excitation (s)
sim_param.exc_st = 0.01;               % start time of excitation (s)
sim_param.xo = 0.1;                    % coordinate of output (normalised, 0-1)

yGs = frequency_string_fdtd_s1505528(opts,phys_param,sim_param);

phys_param.r = 0.0005334;                 % string radius (m)
phys_param.rho = 6600;                 % density (kg/m^3)
phys_param.T60 = 4;                    % T60 (s)
phys_param.L = 0.69;                      % length (m)
phys_param.E = 1.88e11;                 % Young's modulus (Pa)
phys_param.f0 = f*(18/8);
%%%%% simulation parameters 
sim_param.SR = 44100;                  % sample rate (Hz)
sim_param.Tf = 0.41666666666;                      % duration of simulation (s)
sim_param.xi = 0.9;                    % coordinate of excitation (normalised, 0-1)
sim_param.famp = 1;                    % peak amplitude of excitation (N)
sim_param.dur = 0.001;                 % duration of excitation (s)
sim_param.exc_st = 0.01;               % start time of excitation (s)
sim_param.xo = 0.1;                    % coordinate of output (normalised, 0-1)

yB2 = frequency_string_fdtd_s1505528(opts,phys_param,sim_param);

phys_param.r = 0.0005334;                 % string radius (m)
phys_param.rho = 6600;                 % density (kg/m^3)
phys_param.T60 = 4;                    % T60 (s)
phys_param.L = 0.69;                      % length (m)
phys_param.E = 1.88e11;                 % Young's modulus (Pa)
phys_param.f0 = f*(16/18);
%%%%% simulation parameters 
sim_param.SR = 44100;                  % sample rate (Hz)
sim_param.Tf = 0.41666666666;                      % duration of simulation (s)
sim_param.xi = 0.9;                    % coordinate of excitation (normalised, 0-1)
sim_param.famp = 1;                    % peak amplitude of excitation (N)
sim_param.dur = 0.001;                 % duration of excitation (s)
sim_param.exc_st = 0.01;               % start time of excitation (s)
sim_param.xo = 0.1;                    % coordinate of output (normalised, 0-1)

yG = frequency_string_fdtd_s1505528(opts,phys_param,sim_param);

phys_param.r = 0.0005334;                 % string radius (m)
phys_param.rho = 6600;                 % density (kg/m^3)
phys_param.T60 = 4;                    % T60 (s)
phys_param.L = 0.69;                      % length (m)
phys_param.E = 1.88e11;                 % Young's modulus (Pa)
phys_param.f0 = f*(12/5);
%%%%% simulation parameters 
sim_param.SR = 44100;                  % sample rate (Hz)
sim_param.Tf = 0.41666666666;                      % duration of simulation (s)
sim_param.xi = 0.9;                    % coordinate of excitation (normalised, 0-1)
sim_param.famp = 1;                    % peak amplitude of excitation (N)
sim_param.dur = 0.001;                 % duration of excitation (s)
sim_param.exc_st = 0.01;               % start time of excitation (s)
sim_param.xo = 0.1;                    % coordinate of output (normalised, 0-1)

yC2 = frequency_string_fdtd_s1505528(opts,phys_param,sim_param);

phys_param.r = 0.0005334;                 % string radius (m)
phys_param.rho = 6600;                 % density (kg/m^3)
phys_param.T60 = 4;                    % T60 (s)
phys_param.L = 0.69;                      % length (m)
phys_param.E = 1.88e11;                 % Young's modulus (Pa)
phys_param.f0 = f*(5/6);
%%%%% simulation parameters 
sim_param.SR = 44100;                  % sample rate (Hz)
sim_param.Tf = 0.41666666666;                      % duration of simulation (s)
sim_param.xi = 0.9;                    % coordinate of excitation (normalised, 0-1)
sim_param.famp = 1;                    % peak amplitude of excitation (N)
sim_param.dur = 0.001;                 % duration of excitation (s)
sim_param.exc_st = 0.01;               % start time of excitation (s)
sim_param.xo = 0.1;                    % coordinate of output (normalised, 0-1)

yFs = frequency_string_fdtd_s1505528(opts,phys_param,sim_param);

phys_param.r = 0.0005334;                 % string radius (m)
phys_param.rho = 6600;                 % density (kg/m^3)
phys_param.T60 = 4;                    % T60 (s)
phys_param.L = 0.69;                      % length (m)
phys_param.E = 1.88e11;                 % Young's modulus (Pa)
phys_param.f0 = f*(4/3);
%%%%% simulation parameters 
sim_param.SR = 44100;                  % sample rate (Hz)
sim_param.Tf = 0.41666666666;                      % duration of simulation (s)
sim_param.xi = 0.9;                    % coordinate of excitation (normalised, 0-1)
sim_param.famp = 1;                    % peak amplitude of excitation (N)
sim_param.dur = 0.001;                 % duration of excitation (s)
sim_param.exc_st = 0.01;               % start time of excitation (s)
sim_param.xo = 0.1;                    % coordinate of output (normalised, 0-1)

yD = frequency_string_fdtd_s1505528(opts,phys_param,sim_param);


phys_param.r = 0.0005334;                 % string radius (m)
phys_param.rho = 6600;                 % density (kg/m^3)
phys_param.T60 = 4;                    % T60 (s)
phys_param.L = 0.69;                      % length (m)
phys_param.E = 1.88e11;                 % Young's modulus (Pa)
phys_param.f0 = f*(5/3);
%%%%% simulation parameters 
sim_param.SR = 44100;                  % sample rate (Hz)
sim_param.Tf = 0.41666666666;                      % duration of simulation (s)
sim_param.xi = 0.9;                    % coordinate of excitation (normalised, 0-1)
sim_param.famp = 1;                    % peak amplitude of excitation (N)
sim_param.dur = 0.001;                 % duration of excitation (s)
sim_param.exc_st = 0.01;               % start time of excitation (s)
sim_param.xo = 0.1;                    % coordinate of output (normalised, 0-1)

yFs2 = frequency_string_fdtd_s1505528(opts,phys_param,sim_param);

phys_param.r = 0.0005334;                 % string radius (m)
phys_param.rho = 6600;                 % density (kg/m^3)
phys_param.T60 = 4;                    % T60 (s)
phys_param.L = 0.69;                      % length (m)
phys_param.E = 1.88e11;                 % Young's modulus (Pa)
phys_param.f0 = f*(8/10);
%%%%% simulation parameters 
sim_param.SR = 44100;                  % sample rate (Hz)
sim_param.Tf = 0.41666666666;                      % duration of simulation (s)
sim_param.xi = 0.9;                    % coordinate of excitation (normalised, 0-1)
sim_param.famp = 1;                    % peak amplitude of excitation (N)
sim_param.dur = 0.001;                 % duration of excitation (s)
sim_param.exc_st = 0.01;               % start time of excitation (s)
sim_param.xo = 0.1;                    % coordinate of output (normalised, 0-1)

yF = frequency_string_fdtd_s1505528(opts,phys_param,sim_param);

phys_param.r = 0.0005334;                 % string radius (m)
phys_param.rho = 6600;                 % density (kg/m^3)
phys_param.T60 = 4;                    % T60 (s)
phys_param.L = 0.69;                      % length (m)
phys_param.E = 1.88e11;                 % Young's modulus (Pa)
phys_param.f0 = f*(8/10);
%%%%% simulation parameters 
sim_param.SR = 44100;                  % sample rate (Hz)
sim_param.Tf = 0.41666666666*4;                      % duration of simulation (s)
sim_param.xi = 0.9;                    % coordinate of excitation (normalised, 0-1)
sim_param.famp = 1;                    % peak amplitude of excitation (N)
sim_param.dur = 0.001;                 % duration of excitation (s)
sim_param.exc_st = 0.01;               % start time of excitation (s)
sim_param.xo = 0.1;                    % coordinate of output (normalised, 0-1)

yF2 = frequency_string_fdtd_s1505528(opts,phys_param,sim_param);


%y = zeros(10*sim_param.SR,1);

%% Create the song 
% Put all the notes in the required order to give the song. Luckily this
% intro has very simple rhythms. 

y = [yA;yC;yE;yA2;yGs+yB2;yE;yC;yB2;yG+yC2;yE;yC;yC2;yFs+yFs2;yD;yA;yFs2;yF+yE;yC;yA;yE;yF2];

y = y/max(abs(y));

% Play the sound
soundsc(y,sim_param.SR);






