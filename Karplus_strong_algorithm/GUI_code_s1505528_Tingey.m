classdef GUI_code_s1505528_Tingey < matlab.apps.AppBase

    % Properties that correspond to app components
    properties (Access = public)
        UIFigure                 matlab.ui.Figure
        UIAxes                   matlab.ui.control.UIAxes
        GuitarstringusingwhitenoiseasinputPanel  matlab.ui.container.Panel
        PlayguitarsoundandplotfrequencyspectrumButton  matlab.ui.control.Button
        FrequencyEditFieldLabel  matlab.ui.control.Label
        FrequencyEditField       matlab.ui.control.NumericEditField
        DecayrhoEditFieldLabel   matlab.ui.control.Label
        DecayrhoEditField        matlab.ui.control.NumericEditField
        DampingREditFieldLabel   matlab.ui.control.Label
        DampingREditField        matlab.ui.control.NumericEditField
        GuitarstringusingpluckwavasinputPanel  matlab.ui.container.Panel
        PlayguitarsoundandplotfrequencyspectrumButton_2  matlab.ui.control.Button
        InstructionsLabel        matlab.ui.control.Label
        GuitarSoundandFrequencySpectrumGUILabel  matlab.ui.control.Label
    end



    methods (Access = private)

        % Button pushed function: 
        % PlayguitarsoundandplotfrequencyspectrumButton
        function PlayguitarsoundandplotfrequencyspectrumButtonPushed(app, event)
            Fs = 44100; f0 = app.FrequencyEditField.Value; 
Nexact = Fs/f0 - 0.5;
N = floor(Nexact);
P = Nexact - N;
rho = app.DecayrhoEditField.Value; 
R = app.DampingREditField.Value;

% set the length of the desired note in seconds and in samples. 

tEnd = 2; M = Fs*tEnd;  

%%  Create white noise input vector  

v = 2*(rand(N,1)-0.5);
u = zeros(N,1);
u(1) = (1-R)*v(1);

for n = 2:N
    u(n) = (1-R) * v(n) + R * u(n-1);
end 

%%  Use the Karplus-Strong algorithm

%  Initialise the ynew vector to a length of N+M. Set the first N values of
%  x to be the same as u. 

ynew = zeros(N+M,1);

x = zeros(N+M,1);
x(1:N) = u;

ynew(1:N) = x(1:N);

%  Set the value of the N+1 term in the vector ynew. 

ynew(N+1) = (rho/2)*ynew(1);

%  Use a for loop to implement the Karplus-Strong algorithm. Store the 
%  output in the vector ynew to use later in a different loop. 

for n = N+2:M+N
    ynew(n) = x(n) + (rho/2)*(ynew(n-N) + ynew(n-(N+1)));
end 

%  Normalise the ynew vector.

ynew = ynew/max(abs(ynew));

%%  Use the fractional allpass algorithm

%  Assign a value to the constant C using the formula in the assignment.
%  Also, initialise the term ylast and set it equal to 0. 

C = (1-P)/(1+P);
ylast = 0;

%  Initialise the y vector.

y = zeros(N+M,1);

%  Use a for loop to implement the fractional delay all pass filter
%  algorithm. Set ylast to equal ynew at the end of the loop through each
%  iteration.

for n = 2:N+M
    y(n) = C*ynew(n) + ylast - C*y(n-1); 
    ylast = ynew(n);
end 

%  Normalise the vector y.
y = y/max(abs(y));

%%  Plotting the frequency spectrum

% Set L equal to the length of the output vector. Play the sound using
%  soundsc.

L = N+M;
soundsc(y,Fs);

%  Take the fast fourier transform of y so we can graph the frequency
%  spectrum of y.

Y = abs(fft(y));

%  Initialise variables so we can set the x-axis in terms of Frequency in
%  Hz. Also, set the length of the x axis such that we can only see the
%  frequency response up to around 1000Hz. 

bins = 0:(L)-1;
f_Hz = bins*Fs/(L);
S = ceil((L)/2);

 %Plot the graph of the magnitude against frequency

plot(app.UIAxes, f_Hz(1:S/25), Y(1:S/25));

%  Label the graph

xlabel(app.UIAxes, 'Frequency (Hz)')
ylabel(app.UIAxes, 'Magnitude');
title(app.UIAxes, 'Frequency spectrum (Hertz)');
        end

        % Callback function
        function PlotfrequencyspectrumButtonPushed(app, event)
              Fs = 44100; f0 = app.FrequencyEditField.Value; 
Nexact = Fs/f0 - 0.5;
N = floor(Nexact);
P = Nexact - N;
rho = app.DecayrhoEditField.Value; 
R = app.DampingREditField.Value;

%  set the length of the desired note in seconds and in samples. 

tEnd = 2; M = Fs*tEnd;  

%%   Create white noise input vector  

v = 2*(rand(N,1)-0.5);
u = zeros(N,1);
u(1) = (1-R)*v(1);

for n = 2:N
    u(n) = (1-R) * v(n) + R * u(n-1);
end 

%%   Use the Karplus-Strong algorithm

%   Initialise the ynew vector to a length of N+M. Set the first N values of
%   x to be the same as u. 

ynew = zeros(N+M,1);

x = zeros(N+M,1);
x(1:N) = u;

ynew(1:N) = x(1:N);

%   Set the value of the N+1 term in the vector ynew. 

ynew(N+1) = (rho/2)*ynew(1);

%   Use a for loop to implement the Karplus-Strong algorithm. Store the 
%   output in the vector ynew to use later in a different loop. 

for n = N+2:M+N
    ynew(n) = x(n) + (rho/2)*(ynew(n-N) + ynew(n-(N+1)));
end 

%   Normalise the ynew vector.

ynew = ynew/max(abs(ynew));

%%   Use the fractional allpass algorithm

%   Assign a value to the constant C using the formula in the assignment.
%   Also, initialise the term ylast and set it equal to 0. 

C = (1-P)/(1+P);
ylast = 0;

%   Initialise the y vector.

y = zeros(N+M,1);

%   Use a for loop to implement the fractional delay all pass filter
%   algorithm. Set ylast to equal ynew at the end of the loop through each
%   iteration.

for n = 2:N+M
    y(n) = C*ynew(n) + ylast - C*y(n-1); 
    ylast = ynew(n);
end 

%   Normalise the vector y.
y = y/max(abs(y));

%%   Plotting the frequency spectrum

%  Set L equal to the length of the output vector. Play the sound using
%   soundsc.

L = N+M;

%   Take the fast fourier transform of y so we can graph the frequency
%   spectrum of y.

Y = abs(fft(y));

%  Initialise variables so we can set the x-axis in terms of Frequency in
%  Hz. Also, set the length of the x axis such that we can only see the
%  frequency response up to around 1000Hz. 

bins = 0:(L)-1;
f_Hz = bins*Fs/(L);
S = ceil((L)/2);

 %Plot the graph of the magnitude against frequency

plot(app.UIAxes, f_Hz(1:round(S/25)), Y(1:round(S/25)));

%  Label the graph

xlabel(app.UIAxes, 'Frequency (Hz)')
ylabel(app.UIAxes, 'Magnitude');
title(app.UIAxes, 'Frequency spectrum (Hertz)');
        end

        % Button pushed function: 
        % PlayguitarsoundandplotfrequencyspectrumButton_2
        function PlayguitarsoundandplotfrequencyspectrumButton_2Pushed(app, event)
            Fs = 44100; f0 = app.FrequencyEditField.Value; 
Nexact = Fs/f0 - 0.5;
N = floor(Nexact);
P = Nexact - N;
rho = app.DecayrhoEditField.Value; 
R = app.DampingREditField.Value;

[w,Fs] = audioread('pluck.wav');

% set the length of the desired note in seconds and in samples. 

tEnd = 5; M = Fs*tEnd;  

%% Create white noise input vector  
l = length(w);
u = zeros(l,1);
u(1) = (1-R)*w(1);

for n = 2:l
    u(n) = (1-R) * w(n) + R * u(n-1);
end 

%% Use the Karplus-Strong algorithm

% Initialise the ynew vector to a length of N+M. Set the first N values of
% x to be the same as u. 

ynew = zeros(N+M,1);

x = zeros(l+M,1);
x(1:l) = u;

ynew(1:N) = x(1:N);

% Set the value of the N+1 term in the vector ynew. 

ynew(N+1) = (rho/2)*ynew(1);

% Use a for loop to implement the Karplus-Strong algorithm. Store the 
% output in the vector ynew. 

for n = N+2:M+N
    ynew(n) = x(n+(l-(N+2))) + (rho/2)*(ynew(n-N) + ynew(n-(N+1)));
end 

% Normalise the ynew vector.

ynew = ynew/max(abs(ynew));

%% Use the fractional allpass algorithm

% Assign a value to the constant C using the formula in the assignment.
% Also, initialise the term ylast and set it equal to 0. 

C = (1-P)/(1+P);
ylast = 0;

% Initialise the y vector.

y = zeros(l+M,1);

% Use a for loop to implement the fractional delay all pass filter
% algorithm. Set ylast to equal ynew at the end of the loop through each
% iteration.

for n = 2:N+M
    y(n) = C*ynew(n) + ylast - C*y(n-1); 
    ylast = ynew(n);
end 

% Normalise the vector y.
y = y/max(abs(y));

%% Plotting the frequency spectrum

%Set L equal to the length of the output vector. Play the sound using
% soundsc.

L = l+M;
soundsc(y,Fs);

% Take the fast fourier transform of y so we can graph the frequency
% spectrum of y.

Y = abs(fft(y));

% Initialise variables so we can set the x-axis in terms of Frequency in
% Hz. Also, set the length of the x axis such that we can only see the
% frequency response up to around 1000Hz. 

bins = 0:(L)-1;
f_Hz = bins*Fs/(L);
S = ceil((L)/2);

 %Plot the graph of the magnitude against frequency

plot(app.UIAxes, f_Hz(1:round(S/30)), Y(1:round(S/30)));

%  Label the graph

xlabel(app.UIAxes, 'Frequency (Hz)')
ylabel(app.UIAxes, 'Magnitude');
title(app.UIAxes, 'Frequency spectrum (Hertz)');
        end
    end

    % App initialization and construction
    methods (Access = private)

        % Create UIFigure and components
        function createComponents(app)

            % Create UIFigure
            app.UIFigure = uifigure;
            app.UIFigure.Position = [100 100 858 537];
            app.UIFigure.Name = 'UI Figure';
            setAutoResize(app, app.UIFigure, true)

            % Create UIAxes
            app.UIAxes = uiaxes(app.UIFigure);
            title(app.UIAxes, 'Title');
            xlabel(app.UIAxes, 'X');
            ylabel(app.UIAxes, 'Y');
            app.UIAxes.Position = [40 54 389 283];

            % Create GuitarstringusingwhitenoiseasinputPanel
            app.GuitarstringusingwhitenoiseasinputPanel = uipanel(app.UIFigure);
            app.GuitarstringusingwhitenoiseasinputPanel.Title = 'Guitar string using white noise as input';
            app.GuitarstringusingwhitenoiseasinputPanel.Position = [486 227 289 88];

            % Create PlayguitarsoundandplotfrequencyspectrumButton
            app.PlayguitarsoundandplotfrequencyspectrumButton = uibutton(app.GuitarstringusingwhitenoiseasinputPanel, 'push');
            app.PlayguitarsoundandplotfrequencyspectrumButton.ButtonPushedFcn = createCallbackFcn(app, @PlayguitarsoundandplotfrequencyspectrumButtonPushed, true);
            app.PlayguitarsoundandplotfrequencyspectrumButton.Position = [11 26 270 22];
            app.PlayguitarsoundandplotfrequencyspectrumButton.Text = 'Play guitar sound and plot frequency spectrum';

            % Create FrequencyEditFieldLabel
            app.FrequencyEditFieldLabel = uilabel(app.UIFigure);
            app.FrequencyEditFieldLabel.HorizontalAlignment = 'right';
            app.FrequencyEditFieldLabel.Position = [79.03125 372 62 15];
            app.FrequencyEditFieldLabel.Text = 'Frequency';

            % Create FrequencyEditField
            app.FrequencyEditField = uieditfield(app.UIFigure, 'numeric');
            app.FrequencyEditField.Position = [156.03125 368 100 22];
            app.FrequencyEditField.Value = 110;

            % Create DecayrhoEditFieldLabel
            app.DecayrhoEditFieldLabel = uilabel(app.UIFigure);
            app.DecayrhoEditFieldLabel.HorizontalAlignment = 'right';
            app.DecayrhoEditFieldLabel.Position = [297.703125 372 60 15];
            app.DecayrhoEditFieldLabel.Text = 'Decay rho';

            % Create DecayrhoEditField
            app.DecayrhoEditField = uieditfield(app.UIFigure, 'numeric');
            app.DecayrhoEditField.Position = [372.703125 368 100 22];
            app.DecayrhoEditField.Value = 0.95;

            % Create DampingREditFieldLabel
            app.DampingREditFieldLabel = uilabel(app.UIFigure);
            app.DampingREditFieldLabel.HorizontalAlignment = 'right';
            app.DampingREditFieldLabel.Position = [519.703125 372 66 15];
            app.DampingREditFieldLabel.Text = 'Damping R';

            % Create DampingREditField
            app.DampingREditField = uieditfield(app.UIFigure, 'numeric');
            app.DampingREditField.Position = [600.703125 368 100 22];
            app.DampingREditField.Value = 0.95;

            % Create GuitarstringusingpluckwavasinputPanel
            app.GuitarstringusingpluckwavasinputPanel = uipanel(app.UIFigure);
            app.GuitarstringusingpluckwavasinputPanel.Title = 'Guitar string using ''pluck.wav'' as input';
            app.GuitarstringusingpluckwavasinputPanel.Position = [486 91 289 107];

            % Create PlayguitarsoundandplotfrequencyspectrumButton_2
            app.PlayguitarsoundandplotfrequencyspectrumButton_2 = uibutton(app.GuitarstringusingpluckwavasinputPanel, 'push');
            app.PlayguitarsoundandplotfrequencyspectrumButton_2.ButtonPushedFcn = createCallbackFcn(app, @PlayguitarsoundandplotfrequencyspectrumButton_2Pushed, true);
            app.PlayguitarsoundandplotfrequencyspectrumButton_2.Position = [11 33 270 22];
            app.PlayguitarsoundandplotfrequencyspectrumButton_2.Text = 'Play guitar sound and plot frequency spectrum';

            % Create InstructionsLabel
            app.InstructionsLabel = uilabel(app.UIFigure);
            app.InstructionsLabel.Position = [40 427 805 56];
            app.InstructionsLabel.Text = {'Instructions: to use this GUI the user can choose 3 numerical input values and then see how these affect the sound and corresponding frequency '; 'spectrum that is created. The frequencies chosen should be between the values 50 and 300. The decay values chosen should be between '; '0.93 and 0.98. The damping values should also be between 0.93 and 0.98.  The user can also compare the sound difference between the '; 'guitar sound using the ''pluck.wav'' as an input signal, and the guitar sound using white noise as an input signal. '};

            % Create GuitarSoundandFrequencySpectrumGUILabel
            app.GuitarSoundandFrequencySpectrumGUILabel = uilabel(app.UIFigure);
            app.GuitarSoundandFrequencySpectrumGUILabel.Position = [40 510 242 15];
            app.GuitarSoundandFrequencySpectrumGUILabel.Text = 'Guitar Sound and Frequency Spectrum GUI';
        end
    end

    methods (Access = public)

        % Construct app
        function app = GUI_code_s1505528_Tingey()

            % Create and configure components
            createComponents(app)

            % Register the app with App Designer
            registerApp(app, app.UIFigure)

            if nargout == 0
                clear app
            end
        end

        % Code that executes before app deletion
        function delete(app)

            % Delete UIFigure when app is deleted
            delete(app.UIFigure)
        end
    end
end