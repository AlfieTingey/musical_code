function y = frequency_string_fdtd_s1505528(opts,phys_param,sim_param)
   
% This function creates a model for a stiff string vibrating but uses a
% frequency variable instead of tension, density etc. to find the frequency

%% print options and parameters
   opts;phys_param;sim_param;

%% copy over parameters, taking into account some options

% We set the frequency in the variables for the function.
   
   r = phys_param.r;          % string radius (m)
   if opts.add_stiffness
      E = phys_param.E;       % Young's modulus (Pa)
   else
      E = 0;
   end      
   
   % Set the value for f0.
   f0 = phys_param.f0;         % fundamental frequency (Hz)
   T60 = phys_param.T60;      % T60 (s)
   L = phys_param.L;             % length (m)
   rho = phys_param.rho;     

   SR = sim_param.SR;         % sample rate (Hz)

   Tf = sim_param.Tf;         % duration of simulation (s)

   xi = sim_param.xi;         % coordinate of excitation (normalised, 0-1)
   famp = sim_param.famp;     % peak amplitude of excitation (N)
   dur = sim_param.dur;       % duration of excitation (s)
   exc_st = sim_param.exc_st; % start time of excitation (s)
   xo = sim_param.xo;         % coordinate of output (normalised, 0-1)

  %% Derived parameters 
  
  % We just assign some variables here defined in the lecturenotes
  
   A = pi*r^2;          % string cross-sectional area
   I = pi*r^4/4;         % string moment of inertia
   c = 2*f0;             % wave speed
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

   %% I/O 
   % Here we set the readout locations of the string.

   Nf = floor(Tf*SR);         % number of time steps for simulation (based on Tf, SR)

   li = ceil(xi*N);         % grid index of excitation (based on xi,N,L)
   lo = ceil(xo*N);         % grid index of output (based on xo,N,L)
   
   % Error check the readout and plucking positions. They must be in the
   % same range as the string.
   
   if (xo>L) && (xo<=0) 
       error('xo must be less than L and greater than zero')
   end 
   
    if (xi>L) && (xi<=0) 
       error('xi must be less than L and greater than zero')
   end 
   
   %assert(is_pinteger(li))
   %assert(is_pinteger(lo))

   %% create force signal
   
   f = zeros(Nf,1);           % input force signal
   durint = round(dur*SR);     % duration of force signal, in samples
   exc_st_int = round(exc_st*SR); % start time index for excitation
   
   %assert(is_pinteger(durint))
   %assert(is_pinteger(exc_st_int))
   
% Start for loop to create a hann window for struck and half a hann window
% for plucked.

   for n=exc_st_int:exc_st_int+durint-1
      if strcmp(opts.input_type,'struck')
         f(n) = famp*(0.5 - 0.5*cos(2*pi*(n-(exc_st_int))/(durint-1)));
      elseif strcmp(opts.input_type,'plucked')
         f(n) = famp*(0.5 - 0.5*cos(2*pi*(n-(exc_st_int))/(durint-1)/2));
      end
   end
   
   % Error check the excitation and the duration signals. They must be
   % within the time of the simulation.
   
   if (exc_st <= 0) && (exc_st >= Tf)
       error('Excitation time must be within the range of the string time')
   end 
   
   if (dur <= 0) && (dur >= Tf)
       error('duration time must be within the range of the string time')
   end 

   %% state variables
   
   u0 = zeros(N,1);           % state at time index n+1
   u1 = zeros(N,1);           % state at time index n
   u2 = zeros(N,1);           % state at time index n-1

   y = zeros(Nf,1);           % output vector

   %start and end l-index for your for-loop update (see below)
   lstart = 3;
   lend = N-2;

   %assert(is_pinteger(lstart)) 
   %assert(is_pinteger(lend)) 
   
   % Define constants to use in for loop. I worked these out mathematically
   % from the stiff string Fdtd scheme.
   
   c6 = (mu^2/(1+sig*k)); c1 = 2/(1+sig*k); c2 = (1 - lambda^2); c3 = (lambda^2/2); c4 = (1-sig*k); c5 = (1+sig*k);
   
   %% main loop
   tic
   for n=1:Nf
      % interior update: for loop using fdtd scheme
      if opts.useforloop
         for l = lstart:lend
            u0(l) = c1*(c2*u1(l)+c3*(u1(l+1)+u1(l-1)))-c4*u2(l)/c5 - c6*(u1(l+2)-4*u1(l+1)+6*u1(l)-4*u1(l-1)+u1(l-2));
         end
      else % vectorized: Basically just work out all values simultaneously
         u0(3:N-2) = c1*(c2*u1(3:N-2)+c3*(u1(4:N-1)+u1(2:N-3)))-c4*u2(3:N-2)/c5 - c6*(u1(5:N)-4*u1(4:N-1)+6*u1(3:N-2)-4*u1(2:N-3)+u1(1:N-4));
      end
      
      %boundary updates: applied fdtd to first, second, second last and
      %last terms. First and last will just be 0 always of course.
      
      if strcmp(opts.bctype,'clamped')
      u0(1) = 0; u0(N) = 0; u1(1) = 0; u1(N) = 0; u2(1) = 0; u2(N) = 0;
      u0(2) = c1*(c2*u1(2)+c3*(u1(3)+u1(1)))-c4*u2(2)/c5 - c6*(u1(4)-4*u1(3)+6*u1(2)-4*u1(1));
      u0(N-1) = c1*(c2*u1(N-1)+c3*(u1(N)+u1(N-2)))-c4*u2(N-1)/c5 - c6*(-4*u1(N)+6*u1(N-1)-4*u1(N-2)+u1(N-3));
      elseif strcmp(opts.bctype,'simply_supported')
      u0(1) = 0; u0(N) = 0; u1(1) = 0; u1(N) = 0; u2(1) = 0; u2(N) = 0;
      u0(2) = c1*(c2*u1(2)+c3*(u1(3)+u1(1)))-c4*u2(2)/c5 - c6*(u1(4)-4*u1(3)+5*u1(2));
      u0(N-1) = c1*(c2*u1(N-1)+c3*(u1(N)+u1(N-2)))-c4*u2(N-1)/c5 - c6*(-4*u1(N)+7*u1(N-1)-4*u1(N-2)+u1(N-3));
      end

      % send in input
      u0(li) = u0(li) + (k^2/(rho*A*h))/(1+sig*k)*f(n);

      % read output
      if strcmp(opts.output_type,'displacement')
         y(n) = u0(lo);
      elseif strcmp(opts.output_type,'velocity')
         % implement ''velocity'' read-out here: for velocity i just
         % applied the delta(t.) fdtd to the displacement
         y(n) = (1/2*k)*(u0(lo) - u2(lo));
      end

      % plotting
      if (opts.plot_on)
         % draw current state
         if n==1
            figure
            h1=plot([1:N]'*h, u0, 'k');
            axis([0 L -0.005 0.005])
            xlabel('position (m)')
         else
            set(h1,'ydata',u0);
            drawnow;
         end
         fprintf('n=%d out of %d\n',n,Nf);
      end

      % shift states to step forward in time
      u2 = u1;
      u1 = u0;
   end

   %read last samples of output
   %for n=Nf-4:Nf
     % fprintf('y(%d) = %.15g\n',n,y(n));
   %end
   toc

   %%%%% plot spectrum
   if (opts.plot_on)
      figure
      yfft = 10*log10(abs(fft(y)));
      plot([0:Nf-1]'/Nf*SR, yfft, 'k')
      xlabel('freq (Hz)')
   end
end

%is positive integer?
function y=is_pinteger(x)
   y=((mod(x,1)==0) && (x>0));
end


