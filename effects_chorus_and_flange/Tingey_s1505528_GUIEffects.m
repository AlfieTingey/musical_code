classdef Tingey_s1505528_GUIEffects < matlab.apps.AppBase

    % Properties that correspond to app components
    properties (Access = public)
        AudioEffectsGUIUIFigure  matlab.ui.Figure
        UIAxes                   matlab.ui.control.UIAxes
        PlotthesignalafterapplyingtheeffectPanel  matlab.ui.container.Panel
        FeedForwardPlotButton    matlab.ui.control.Button
        FeedBackPlotButton       matlab.ui.control.Button
        ChorusPlotButton         matlab.ui.control.Button
        FlangePlotButton         matlab.ui.control.Button
        OriginalButton           matlab.ui.control.Button
        M02EditFieldLabel        matlab.ui.control.Label
        M02EditField             matlab.ui.control.NumericEditField
        M01EditFieldLabel        matlab.ui.control.Label
        M01EditField             matlab.ui.control.NumericEditField
        PlaytheSoundPanel        matlab.ui.container.Panel
        FeedForwardSoundButton   matlab.ui.control.Button
        FeedBackSoundButton      matlab.ui.control.Button
        ChorusSoundButton        matlab.ui.control.Button
        FlangeSoundButton        matlab.ui.control.Button
        OriginalSoundButton      matlab.ui.control.Button
        Label                    matlab.ui.control.Label
        PlotM1andM2Panel         matlab.ui.container.Panel
        M1PlotButton             matlab.ui.control.Button
        M2PlotButton             matlab.ui.control.Button
        F01EditFieldLabel        matlab.ui.control.Label
        F01EditField             matlab.ui.control.NumericEditField
    end

    methods (Access = private)

        % Button pushed function: FeedForwardPlotButton
        function FeedForwardPlotButtonPushed(app, event)
            M = 1000; g = 0.5; 
            
            
            [x,Fs] = audioread('cath_cut.wav'); % read in a wav file of your choice, note waveform signal x and sample rate Fs
            
            if size(x,2) == 2
    x = (x(:,1) + x(:,2))/2; % use 'if' loop to make sure stereo signals also work
            end 
            x1 = [zeros(M,1); x]; % zero pad signal x with M zeroes at the start for later calculations
            
            L = length(x); % pre-assign the length of the output signal, yFF and yFB
            yFF = zeros(1,L);
            
            for k = M+1:L % create a for loop that reads in values for yFF. Start at M+1 so the (k-M) will never be negative
            
            yFF(k) = x(k) + g*x(k-M); % formula for comb filter Feed Forward.
            
            end;
            
            plot(app.UIAxes,yFF); xlabel(app.UIAxes, 'time'); ylabel(app.UIAxes, 'Amplitude'); ylim(app.UIAxes, [-0.7,0.7]); title(app.UIAxes, 'Feed Forward Effect');
        end

        % Button pushed function: FeedBackPlotButton
        function FeedBackPlotButtonPushed(app, event)
            M = 1000; g = 0.5; 
            
            [x,Fs] = audioread('cath_cut.wav'); % read in a wav file of your choice, note waveform signal x and sample rate Fs
            
            if size(x,2) == 2
    x = (x(:,1) + x(:,2))/2; % use 'if' loop to make sure stereo signals also work
            end 
            x1 = [zeros(M,1); x]; % zero pad signal x with M zeroes at the start for later calculations
            
            
            L = length(x); % pre-assign the length of the output signal, yFF and yFB
            yFB = zeros(1,L);
            
            for k = M+1:L % create a for loop that reads in values for yFB. Start at M+1 so the (k-M) will never be negative. 
            
            yFB(k) = x(k) - g*yFB(k-M); % formila for comb filter Feed Backwards
            
            end;
            
            plot(app.UIAxes, yFB); xlabel(app.UIAxes, 'time'); ylabel(app.UIAxes, 'Amplitude'); ylim(app.UIAxes, [-0.7,0.7]); title(app.UIAxes, 'Feed Back Effect');
            
        end

        % Button pushed function: ChorusPlotButton
        function ChorusPlotButtonPushed(app, event)
            W = 8; Q = 50;
            
            q = 1:Q; 
            alpha = (-Q/2 +q -1)/Q; 
            beta = -(W-1)/2:1:(W-1)/2; 
            
            L = zeros(W,W,Q); 
            L1 = zeros(W,Q); 
            
            for i = 1:W
    for j = 1:Q
        L1(i,j) = alpha(j)-beta(i); 
    end 
            end 
            
            for i = 1:W
    for j = 1:W
        for k = 1:Q
    L(:,j,k) = L1(:,k);
        end
    end 
            end 
            
            for k = 1:Q
            L(:,:,k) = L(:,:,k) - diag(diag(L(:,:,k))-1); 
            end 
            
            H = zeros(W,W);
            
            for i = 1:W
    for h = 1:W
        H(i,h) = beta(h) - beta(i); 
    end
            end
            
            H = H + eye(W);  
            
            Num = zeros(W,Q); 
            Denom = zeros(1,W); 
            Table = zeros(Q,W); 
            
            for i = 1:Q
    for j = 1:W
    Num(1:W,i) = prod(L(:,:,i)); 
    Denom(1,j) = prod(H(:,j));   
    end 
            end 
            
            DenomInv = 1./Denom; 
            
            for i = 1:Q
    for j = 1:W
        Table(i,j) = Num(j,i).*DenomInv(1,j); 
    end 
            end 
            
            [x,Fs] = audioread('cath_cut.wav');
            
            if size(x,2) == 2
    x = (x(:,1) + x(:,2))/2; 
            end 
            
            N = length(x);
            
            x = x';
            
            g1 = 0.5; 
            g2 = 0.5;
            M01 = app.M01EditField.Value;
            M02 = app.M02EditField.Value;
            
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
            
            plot(app.UIAxes, y); xlabel(app.UIAxes, 'time'); ylabel(app.UIAxes, 'Amplitude'); ylim(app.UIAxes, [-0.7,0.7]); title(app.UIAxes, 'Chorus Effect');
        end

        % Button pushed function: FlangePlotButton
        function FlangePlotButtonPushed(app, event)
            W = 8; Q = 50;
            
            q = 1:Q; 
            alpha = (-Q/2 +q -1)/Q; 
            beta = -(W-1)/2:1:(W-1)/2; 
            
            L = zeros(W,W,Q); 
            L1 = zeros(W,Q); 
            
            for i = 1:W
    for j = 1:Q
        L1(i,j) = alpha(j)-beta(i); 
    end 
            end 
            
            for i = 1:W
    for j = 1:W
        for k = 1:Q
    L(:,j,k) = L1(:,k);
        end
    end 
            end 
            
            for k = 1:Q
            L(:,:,k) = L(:,:,k) - diag(diag(L(:,:,k))-1); 
            end 
            
            H = zeros(W,W);
            
            for i = 1:W
    for h = 1:W
        H(i,h) = beta(h) - beta(i); 
    end
            end
            
            H = H + eye(W);  
            
            Num = zeros(W,Q); 
            Denom = zeros(1,W); 
            Table = zeros(Q,W); 
            
            for i = 1:Q
    for j = 1:W
    Num(1:W,i) = prod(L(:,:,i)); 
    Denom(1,j) = prod(H(:,j));   
    end 
            end 
            
            DenomInv = 1./Denom; 
            
            for i = 1:Q
    for j = 1:W
        Table(i,j) = Num(j,i).*DenomInv(1,j); 
    end 
            end 
            
            [x,Fs] = audioread('cath_cut.wav');
            
            if size(x,2) == 2
    x = (x(:,1) + x(:,2))/2; % use 'if' loop to make sure stereo signals also work
            end 
            
            N = length(x);
            
            x = x';
            
            g1 = 0.5;
            
            F01 = app.F01EditField.Value; 
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
            
            y(k) = x(k) + g1*X1(k); % stick the formula for chorus into a for loop and read in values for output signal. 
            
            end;
            
            plot(app.UIAxes,y); xlabel(app.UIAxes, 'time'); ylabel(app.UIAxes, 'Amplitude'); ylim(app.UIAxes, [-0.7,0.7]); title(app.UIAxes, 'Flange Effect');
            
            
        end

        % Button pushed function: OriginalButton
        function OriginalButtonPushed(app, event)
            [x,Fs] = audioread('cath_cut.wav'); % read in a wav file of your choice, note waveform signal x and sample rate Fs
            
            if size(x,2) == 2
    x = (x(:,1) + x(:,2))/2; % use 'if' loop to make sure stereo signals also work
            end 
            
            plot(app.UIAxes, x); xlabel(app.UIAxes, 'time'); ylabel(app.UIAxes, 'Amplitude'); ylim(app.UIAxes, [-0.7,0.7]); title(app.UIAxes, 'No Effect');
        end

        % Button pushed function: FeedForwardSoundButton
        function FeedForwardSoundButtonPushed(app, event)
                       M = 1000; g = 0.5; 
            
            [x,Fs] = audioread('cath_cut.wav'); % read in a wav file of your choice, note waveform signal x and sample rate Fs
            
            if size(x,2) == 2
    x = (x(:,1) + x(:,2))/2; % use 'if' loop to make sure stereo signals also work
            end 
            x1 = [zeros(M,1); x]; % zero pad signal x with M zeroes at the start for later calculations
            
            L = length(x); % pre-assign the length of the output signal, yFF and yFB
            yFF = zeros(1,L);
            
            for k = M+1:L % create a for loop that reads in values for yFF. Start at M+1 so the (k-M) will never be negative
            
            yFF(k) = x(k) + g*x(k-M); % formula for comb filter Feed Forward.
            
            end;
            
            soundsc(yFF,Fs);
        end

        % Button pushed function: FeedBackSoundButton
        function FeedBackSoundButtonPushed(app, event)
                       M = 1000; g = 0.5; 
            
            [x,Fs] = audioread('cath_cut.wav'); % read in a wav file of your choice, note waveform signal x and sample rate Fs
            
            if size(x,2) == 2
    x = (x(:,1) + x(:,2))/2; % use 'if' loop to make sure stereo signals also work
            end 
            x1 = [zeros(M,1); x]; % zero pad signal x with M zeroes at the start for later calculations
            
            
            L = length(x); % pre-assign the length of the output signal, yFF and yFB
            yFB = zeros(1,L);
            
            for k = M+1:L % create a for loop that reads in values for yFB. Start at M+1 so the (k-M) will never be negative. 
            
            yFB(k) = x(k) - g*yFB(k-M); % formila for comb filter Feed Backwards
            
            end;
            
            soundsc(yFB,Fs);
        end

        % Button pushed function: ChorusSoundButton
        function ChorusSoundButtonPushed(app, event)
            W = 8; Q = 50;
            
            q = 1:Q; 
            alpha = (-Q/2 +q -1)/Q; 
            beta = -(W-1)/2:1:(W-1)/2; 
            
            L = zeros(W,W,Q); 
            L1 = zeros(W,Q); 
            
            for i = 1:W 
    for j = 1:Q 
        L1(i,j) = alpha(j)-beta(i); 
    end  
            end  
            
            for i = 1:W 
    for j = 1:W 
        for k = 1:Q 
    L(:,j,k) = L1(:,k);
        end 
    end  
            end  
            
            for k = 1:Q 
            L(:,:,k) = L(:,:,k) - diag(diag(L(:,:,k))-1); 
            end  
            
            H = zeros(W,W);
            
            for i = 1:W 
    for h = 1:W
        H(i,h) = beta(h) - beta(i); 
    end 
            end 
            
            H = H + eye(W);  
            
            Num = zeros(W,Q); 
            Denom = zeros(1,W); 
            Table = zeros(Q,W); 
            
            for i = 1:Q 
    for j = 1:W 
    Num(1:W,i) = prod(L(:,:,i)); 
    Denom(1,j) = prod(H(:,j));   
    end  
            end  
            
            DenomInv = 1./Denom; 
            
            for i = 1:Q 
    for j = 1:W 
        Table(i,j) = Num(j,i).*DenomInv(1,j); 
    end  
            end  
            
            [x,Fs] = audioread('cath_cut.wav');
            
            if size(x,2) == 2 
    x = (x(:,1) + x(:,2))/2; 
            end  
            
            N = length(x);
            
            x = x';
            
            g1 = 0.5; 
            g2 = 0.5;
            
            M01 = app.M01EditField.Value;
            M02 = app.M02EditField.Value;
            
            
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
            
            soundsc(y,Fs);
            
        end

        % Button pushed function: FlangeSoundButton
        function FlangeSoundButtonPushed(app, event)
            W = 8; Q = 50;
            
            q = 1:Q; 
            alpha = (-Q/2 +q -1)/Q; 
            beta = -(W-1)/2:1:(W-1)/2; 
            
            L = zeros(W,W,Q); 
            L1 = zeros(W,Q); 
            
            for i = 1:W 
    for j = 1:Q 
        L1(i,j) = alpha(j)-beta(i); 
    end  
            end  
             
            for i = 1:W 
    for j = 1:W 
        for k = 1:Q 
    L(:,j,k) = L1(:,k);
        end 
    end  
            end  
            
            for k = 1:Q 
            L(:,:,k) = L(:,:,k) - diag(diag(L(:,:,k))-1); 
            end  
            
            H = zeros(W,W);
            
            for i = 1:W 
    for h = 1:W 
        H(i,h) = beta(h) - beta(i); 
    end 
            end 
            
            H = H + eye(W);  
            
            Num = zeros(W,Q); 
            Denom = zeros(1,W); 
            Table = zeros(Q,W); 
            
            for i = 1:Q 
    for j = 1:W 
    Num(1:W,i) = prod(L(:,:,i)); 
    Denom(1,j) = prod(H(:,j));   
    end  
            end  
            
            DenomInv = 1./Denom; 
            
            for i = 1:Q 
    for j = 1:W 
        Table(i,j) = Num(j,i).*DenomInv(1,j); 
    end  
            end  
            
            [x,Fs] = audioread('cath_cut.wav');
            
            if size(x,2) == 2 
    x = (x(:,1) + x(:,2))/2; % use 'if' loop to make sure stereo signals also work
            end  
            
            N = length(x);
            
            x = x';
            
            g1 = 0.5;
            
            F01 = app.F01EditField.Value; 
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
            
            y(k) = x(k) + g1*X1(k); % stick the formula for chorus into a for loop and read in values for output signal. 
            
            end; 
            
            soundsc(y,Fs);
            
        end

        % Button pushed function: OriginalSoundButton
        function OriginalSoundButtonPushed(app, event)
            [x,Fs] = audioread('cath_cut.wav'); % read in a wav file of your choice, note waveform signal x and sample rate Fs
            
            if size(x,2) == 2 
    x = (x(:,1) + x(:,2))/2; % use 'if' loop to make sure stereo signals also work
            end  
            
            soundsc(x,Fs);
        end

        % Button pushed function: M1PlotButton
        function M1PlotButtonPushed(app, event)
            [x,Fs] = audioread('cath_cut.wav');
            
            if size(x,2) == 2
    x = (x(:,1) + x(:,2))/2; % use 'if' loop to make sure stereo signals also work
            end 
            
            N = length(x);
            
            x = x';
            
            g1 = 0.5; % set gain values between -1 and 1
            g2 = 0.5;
            
            M01 = app.M01EditField.Value;
            M02 = app.M02EditField.Value;
            
            Max = max(M01,M02); % here I take the max of the two values for later calculationd to make sure i never get negative indices for a matrix. 
            x = [zeros(1,Max),x]; % preassign x and zero pad so that the for loop I use later will work. 
            D1 = 200/M01; D2 = 100/M02; % choose D1 so that D1 gives the effect oscillation and M1 chooses the starting point.
            f1 = 1.75; f2 = 2; % choose some frequencies
            
            n = 1:N;
            Ts = 1/Fs;
            
            %% Caluculating M1 and M2
            
            M1 = M01*(1+D1*sin(2*pi*n*f1*Ts)); % equation to compute M1 and M2 from lecture notes.
            M2 = M02*(1+D2*sin(2*pi*n*f2*Ts)); % the D1 and D2 are important so that the graphs look very similar to those shown in the lecture notes.
            
            plot(app.UIAxes, M1); xlabel(app.UIAxes, 'time'); ylabel(app.UIAxes, 'M1[n]'); ylim(app.UIAxes, [0, 1200]);
        end

        % Button pushed function: M2PlotButton
        function M2PlotButtonPushed(app, event)
            [x,Fs] = audioread('cath_cut.wav');
            
            if size(x,2) == 2
    x = (x(:,1) + x(:,2))/2; % use 'if' loop to make sure stereo signals also work
            end 
            
            N = length(x);
            
            x = x';
            
            g1 = 0.5; % set gain values between -1 and 1
            g2 = 0.5;
            
            M01 = app.M01EditField.Value;
            M02 = app.M02EditField.Value;
            Max = max(M01,M02); % here I take the max of the two values for later calculationd to make sure i never get negative indices for a matrix. 
            x = [zeros(1,Max),x]; % preassign x and zero pad so that the for loop I use later will work. 
            D1 = 200/M01; D2 = 100/M02; % choose D1 so that D1 gives the effect oscillation and M1 chooses the starting point.
            f1 = 1.75; f2 = 2; % choose some frequencies
            
            n = 1:N;
            Ts = 1/Fs;
            
            %% Caluculating M1 and M2
            
            M1 = M01*(1+D1*sin(2*pi*n*f1*Ts)); % equation to compute M1 and M2 from lecture notes.
            M2 = M02*(1+D2*sin(2*pi*n*f2*Ts)); % the D1 and D2 are important so that the graphs look very similar to those shown in the lecture notes.
            
            plot(app.UIAxes,M2); ylim(app.UIAxes, [0, 1200]); xlabel(app.UIAxes, 'time'); ylabel(app.UIAxes, 'M2[n]');
        end
    end

    % App initialization and construction
    methods (Access = private)

        % Create UIFigure and components
        function createComponents(app)

            % Create AudioEffectsGUIUIFigure
            app.AudioEffectsGUIUIFigure = uifigure;
            app.AudioEffectsGUIUIFigure.Position = [100 100 932 537];
            app.AudioEffectsGUIUIFigure.Name = 'Audio Effects GUI';
            setAutoResize(app, app.AudioEffectsGUIUIFigure, true)

            % Create UIAxes
            app.UIAxes = uiaxes(app.AudioEffectsGUIUIFigure);
            title(app.UIAxes, 'Title');
            xlabel(app.UIAxes, 'X');
            ylabel(app.UIAxes, 'Y');
            app.UIAxes.Position = [60 158 402 271];

            % Create PlotthesignalafterapplyingtheeffectPanel
            app.PlotthesignalafterapplyingtheeffectPanel = uipanel(app.AudioEffectsGUIUIFigure);
            app.PlotthesignalafterapplyingtheeffectPanel.Title = 'Plot the signal after applying the effect';
            app.PlotthesignalafterapplyingtheeffectPanel.Position = [587 203 267 181];

            % Create FeedForwardPlotButton
            app.FeedForwardPlotButton = uibutton(app.PlotthesignalafterapplyingtheeffectPanel, 'push');
            app.FeedForwardPlotButton.ButtonPushedFcn = createCallbackFcn(app, @FeedForwardPlotButtonPushed, true);
            app.FeedForwardPlotButton.Position = [16.5 72 115 22];
            app.FeedForwardPlotButton.Text = 'Feed Forward Plot';

            % Create FeedBackPlotButton
            app.FeedBackPlotButton = uibutton(app.PlotthesignalafterapplyingtheeffectPanel, 'push');
            app.FeedBackPlotButton.ButtonPushedFcn = createCallbackFcn(app, @FeedBackPlotButtonPushed, true);
            app.FeedBackPlotButton.Position = [24 26 100 22];
            app.FeedBackPlotButton.Text = 'Feed Back Plot';

            % Create ChorusPlotButton
            app.ChorusPlotButton = uibutton(app.PlotthesignalafterapplyingtheeffectPanel, 'push');
            app.ChorusPlotButton.ButtonPushedFcn = createCallbackFcn(app, @ChorusPlotButtonPushed, true);
            app.ChorusPlotButton.Position = [153 26 100 22];
            app.ChorusPlotButton.Text = 'Chorus Plot';

            % Create FlangePlotButton
            app.FlangePlotButton = uibutton(app.PlotthesignalafterapplyingtheeffectPanel, 'push');
            app.FlangePlotButton.ButtonPushedFcn = createCallbackFcn(app, @FlangePlotButtonPushed, true);
            app.FlangePlotButton.Position = [153 72 100 22];
            app.FlangePlotButton.Text = 'Flange Plot';

            % Create OriginalButton
            app.OriginalButton = uibutton(app.PlotthesignalafterapplyingtheeffectPanel, 'push');
            app.OriginalButton.ButtonPushedFcn = createCallbackFcn(app, @OriginalButtonPushed, true);
            app.OriginalButton.Position = [86 123 100 22];
            app.OriginalButton.Text = 'Original';

            % Create M02EditFieldLabel
            app.M02EditFieldLabel = uilabel(app.AudioEffectsGUIUIFigure);
            app.M02EditFieldLabel.HorizontalAlignment = 'right';
            app.M02EditFieldLabel.Position = [202.03125 461 29 15];
            app.M02EditFieldLabel.Text = 'M02';

            % Create M02EditField
            app.M02EditField = uieditfield(app.AudioEffectsGUIUIFigure, 'numeric');
            app.M02EditField.Position = [246.03125 457 100 22];
            app.M02EditField.Value = 400;

            % Create M01EditFieldLabel
            app.M01EditFieldLabel = uilabel(app.AudioEffectsGUIUIFigure);
            app.M01EditFieldLabel.HorizontalAlignment = 'right';
            app.M01EditFieldLabel.Position = [28.03125 461 29 15];
            app.M01EditFieldLabel.Text = 'M01';

            % Create M01EditField
            app.M01EditField = uieditfield(app.AudioEffectsGUIUIFigure, 'numeric');
            app.M01EditField.Position = [72.03125 457 100 22];
            app.M01EditField.Value = 600;

            % Create PlaytheSoundPanel
            app.PlaytheSoundPanel = uipanel(app.AudioEffectsGUIUIFigure);
            app.PlaytheSoundPanel.Title = 'Play the Sound';
            app.PlaytheSoundPanel.Position = [102 30 557 108];

            % Create FeedForwardSoundButton
            app.FeedForwardSoundButton = uibutton(app.PlaytheSoundPanel, 'push');
            app.FeedForwardSoundButton.ButtonPushedFcn = createCallbackFcn(app, @FeedForwardSoundButtonPushed, true);
            app.FeedForwardSoundButton.Position = [10.5 52 129 22];
            app.FeedForwardSoundButton.Text = 'Feed Forward Sound';

            % Create FeedBackSoundButton
            app.FeedBackSoundButton = uibutton(app.PlaytheSoundPanel, 'push');
            app.FeedBackSoundButton.ButtonPushedFcn = createCallbackFcn(app, @FeedBackSoundButtonPushed, true);
            app.FeedBackSoundButton.Position = [156 52 112 22];
            app.FeedBackSoundButton.Text = 'Feed Back Sound';

            % Create ChorusSoundButton
            app.ChorusSoundButton = uibutton(app.PlaytheSoundPanel, 'push');
            app.ChorusSoundButton.ButtonPushedFcn = createCallbackFcn(app, @ChorusSoundButtonPushed, true);
            app.ChorusSoundButton.Position = [292 52 100 22];
            app.ChorusSoundButton.Text = 'Chorus Sound';

            % Create FlangeSoundButton
            app.FlangeSoundButton = uibutton(app.PlaytheSoundPanel, 'push');
            app.FlangeSoundButton.ButtonPushedFcn = createCallbackFcn(app, @FlangeSoundButtonPushed, true);
            app.FlangeSoundButton.Position = [422 52 100 22];
            app.FlangeSoundButton.Text = 'Flange Sound';

            % Create OriginalSoundButton
            app.OriginalSoundButton = uibutton(app.PlaytheSoundPanel, 'push');
            app.OriginalSoundButton.ButtonPushedFcn = createCallbackFcn(app, @OriginalSoundButtonPushed, true);
            app.OriginalSoundButton.Position = [221 19 100 22];
            app.OriginalSoundButton.Text = 'Original Sound';

            % Create Label
            app.Label = uilabel(app.AudioEffectsGUIUIFigure);
            app.Label.Position = [17 501 719 15];
            app.Label.Text = 'Choose Values for M02 and M01 between 100 and 1000  for the Chorus effect, and F01 between 20 and 100 for the Flange effect.';

            % Create PlotM1andM2Panel
            app.PlotM1andM2Panel = uipanel(app.AudioEffectsGUIUIFigure);
            app.PlotM1andM2Panel.Title = 'Plot M1 and M2';
            app.PlotM1andM2Panel.Position = [592 428 262 59];

            % Create M1PlotButton
            app.M1PlotButton = uibutton(app.PlotM1andM2Panel, 'push');
            app.M1PlotButton.ButtonPushedFcn = createCallbackFcn(app, @M1PlotButtonPushed, true);
            app.M1PlotButton.Position = [20 11 100 22];
            app.M1PlotButton.Text = 'M1 Plot';

            % Create M2PlotButton
            app.M2PlotButton = uibutton(app.PlotM1andM2Panel, 'push');
            app.M2PlotButton.ButtonPushedFcn = createCallbackFcn(app, @M2PlotButtonPushed, true);
            app.M2PlotButton.Position = [148 11 100 22];
            app.M2PlotButton.Text = 'M2 Plot';

            % Create F01EditFieldLabel
            app.F01EditFieldLabel = uilabel(app.AudioEffectsGUIUIFigure);
            app.F01EditFieldLabel.HorizontalAlignment = 'right';
            app.F01EditFieldLabel.Position = [394.03125 461 26 15];
            app.F01EditFieldLabel.Text = 'F01';

            % Create F01EditField
            app.F01EditField = uieditfield(app.AudioEffectsGUIUIFigure, 'numeric');
            app.F01EditField.Position = [435.03125 457 100 22];
            app.F01EditField.Value = 75;
        end
    end

    methods (Access = public)

        % Construct app
        function app = Tingey_s1505528_GUIEffects()

            % Create and configure components
            createComponents(app)

            % Register the app with App Designer
            registerApp(app, app.AudioEffectsGUIUIFigure)

            if nargout == 0
                clear app
            end
        end

        % Code that executes before app deletion
        function delete(app)

            % Delete UIFigure when app is deleted
            delete(app.AudioEffectsGUIUIFigure)
        end
    end
end