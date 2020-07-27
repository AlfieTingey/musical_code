close all
clear all 

%%%%% physical string parameters 
phys_param.T = 67;                     % tension (N)
phys_param.r = 0.0005334;                 % string radius (m)
phys_param.rho = 6600;                 % density (kg/m^3)
phys_param.T60 = 4;                    % T60 (s)
phys_param.L = 0.69;                      % length (m)
phys_param.E = 1.88e11;                  % Young's modulus (Pa)

%%%%% simulation parameters 
%%%%% simulation parameters 
sim_param.SR = 44100;                  % sample rate (Hz)
sim_param.Tf = 4;                      % duration of simulation (s)
sim_param.xi = 0.9;                    % coordinate of excitation (normalised, 0-1)
sim_param.famp = 1;                    % peak amplitude of excitation (N)
sim_param.dur = 0.001;                 % duration of excitation (s)
sim_param.exc_st = 0.01;               % start time of excitation (s)
sim_param.xo = 0.1;                    % coordinate of output (normalised, 0-1)
   % coordinate of output (normalised, 0-1)


T = phys_param.T;          % tension (N)
   r = phys_param.r;          % string radius (m)
     E = phys_param.E;       % Young's modulus (Pa)
   rho = phys_param.rho;      % density (ρ) (kg/m^3) 

   T60 = phys_param.T60;      % T60 (s)
   L = phys_param.L;          % length (m)

   SR = sim_param.SR;         % sample rate (Hz)

   Tf = sim_param.Tf;         % duration of simulation (s)

   xi = sim_param.xi;         % coordinate of excitation (normalised, 0-1)
   famp = sim_param.famp;     % peak amplitude of excitation (N)
   dur = sim_param.dur;       % duration of excitation (s)
   exc_st = sim_param.exc_st; % start time of excitation (s)
   xo = sim_param.xo;         % coordinate of output (normalised, 0-1)

   %%%%% Derived parameters (to complete)
   A = pi*r^2;          % string cross-sectional area
   I = pi*r^4/4;         % string moment of inertia
   c = sqrt(T/(rho*A));         % wave speed
   sig = 6*(log(10))/T60;        % loss parameter (σ)
   K = sqrt((E*I)/(rho*A));        % stiffness constant (κ)
   k = 1/SR;          % time step
   
   hmin = sqrt((c^2*k^2+sqrt(c^4*k^4+16*K^2*k^2))/2);       % minimal grid spacing for stability
   N = floor(L/hmin);         % number of grid points to update
   h = L/(N);         % actual grid spacing used

   assert(h>=hmin) %for stability
   assert(sig>=0) %for stability

   lambda = (c*k)/h;     % Courant number (λ)
   mu = K*k/h^2;         % numerical stiffness constant (μ)

   %%%%% I/O (to complete)

   Nf = floor(Tf*SR);         % number of time steps for simulation (based on Tf, SR)

   li = ceil(xi*N);         % grid index of excitation (based on xi,N,L)
   lo = ceil(xo*N);         % grid index of output (based on xo,N,L)
   
   %assert(is_pinteger(li))
   %assert(is_pinteger(lo))

   % create force signal
   f = zeros(Nf,1);           % input force signal
   durint = dur*SR;     % duration of force signal, in samples
   exc_st_int = round(exc_st*SR); % start time index for excitation

   for n=exc_st_int:exc_st_int+durint-1
         f(n) = famp*(0.5 - 0.5*cos(2*pi*(n-(exc_st_int))/(durint-1)));
   end 
   
   g = zeros(Nf,1);
   
   for n=exc_st_int:exc_st_int+durint-1
       g(n) = famp*(0.5 - 0.5*cos(2*pi*(n-(exc_st_int))/(durint-1)/2));
   end
   
     %%%%% state variables
   u0 = zeros(N,1);           % state at time index n+1
   u1 = zeros(N,1);           % state at time index n
   u2 = zeros(N,1);           % state at time index n-1
   
   y = zeros(Nf,1);           % output vector

   %start and end l-index for your for-loop update (see below)
   lstart = 3;
   lend = N-2;

   %assert(is_pinteger(lstart)) 
   %assert(is_pinteger(lend))
   c6 = (mu^2/(1+sig*k)); c1 = 2/(1+sig*k); c2 = (1 - lambda^2); c3 = (lambda^2/2); c4 = (1-sig*k); c5 = (1+sig*k);
   %%%%% main loop
   for n=1:Nf
         for l = lstart:lend
            u0(l) = c1*(c2*u1(l)+c3*(u1(l+1)+u1(l-1)))-c4*u2(l)/c5 - c6*(u1(l+2)-4*u1(l+1)+6*u1(l)-4*u1(l-1)+u1(l-2));
         end
         % Vectorised
         %u0(3:N-2) = c1*(c2*u1(3:N-2)+c3*(u1(4:N-1)+u1(2:N-3)))-c4*u2(3:N-2)/c5 - c6*(u1(5:N)-4*u1(4:N-1)+6*u1(3:N-2)-4*u1(2:N-3)+u1(1:N-4));
      %boundary updates
      %clamped
      %u0(1) = 0; u0(N) = 0; u1(1) = 0; u1(N) = 0; u2(1) = 0; u2(N) = 0;
      %u0(2) = c1*(c2*u1(2)+c3*(u1(3)+u1(1)))-c4*u2(2)/c5 - c6*(u1(4)-4*u1(3)+6*u1(2)-4*u1(1));
      %u0(N-1) = c1*(c2*u1(N-1)+c3*(u1(N)+u1(N-2)))-c4*u2(N-1)/c5 - c6*(-4*u1(N)+6*u1(N-1)-4*u1(N-2)+u1(N-3));
      
      %simply supported
      u0(1) = 0; u0(N) = 0; u1(1) = 0; u1(N) = 0; u2(1) = 0; u2(N) = 0;
      u0(2) = c1*(c2*u1(2)+c3*(u1(3)+u1(1)))-c4*u2(2)/c5 - c6*(u1(4)-4*u1(3)+5*u1(2));
      %u0(N-1) = c1*(c2*u1(N-1)+c3*(u1(N)+u1(N-2)))-c4*u2(N-1)/c5 - c6*(-4*u1(N)+5*u1(N-1)-4*u1(N-2));
      
      % send in input
      u0(li) = u0(li) + (k^2/(rho*A*h))/(1+sig*k)*g(n);
      % read output
      y(n) = u0(lo); 
      
      % Velocity:
      %y(n) = (1/2*k)*(u0(lo) - u2(lo));
      % shift states to step forward in time
      u2 = u1;
      u1 = u0;
   end
   
   y = y/max(abs(y));
   plot(y)
   soundsc(y,SR);