%% pre-amble and assigning variables 

M = 1000; g = 0.5; 

[x,Fs] = audioread('cath_cut.wav'); % read in a wav file of your choice, note waveform signal x and sample rate Fs

if size(x,2) == 2
    x = (x(:,1) + x(:,2))/2; % use 'if' loop to make sure stereo signals also work
end 
x1 = [zeros(M,1); x]; % zero pad signal x with M zeroes at the start for later calculations


L = length(x1); % pre-assign the length of the output signal, yFF and yFB
yFF = zeros(1,L);
yFB = zeros(1,L);

for k = M+1:L % create a for loop that reads in values for yFF. Start at M+1 so the (k-M) will never be negative

yFF(k) = x1(k) + g*x1(k-M); % formula for comb filter Feed Forward.

end;

for k = M+1:L % create a for loop that reads in values for yFB. Start at M+1 so the (k-M) will never be negative. 

yFB(k) = x1(k) - g*yFB(k-M); % formila for comb filter Feed Backwards

end;


%% Plotting the graphs 

% Here I work out the frequencies for respective graphs so I can use them
% for the x-axis. 
freqx = (0:1:length(abs(fft(x)))-1)*Fs/L;
freqyFF = (0:1:length(abs(fft(yFF)))-1)*Fs/L;
freqyFB = (0:1:length(abs(fft(yFB)))-1)*Fs/L;

% Here I work out the Nyquist frequency so I can limit the x-axis. 
Nfx = max(freqx/2);
NyFF = max(freqyFF/2);
NyFB = max(freqyFB/2);

% plot the graphs
subplot(3,3,1)
plot(x); xlabel('Time (samples)'); ylabel('Amplitude'); axis tight;
subplot(3,3,4)
plot(yFF); xlabel('Time (samples)'); ylabel('Amplitude'); axis tight;
subplot(3,3,7);
plot(yFB); xlabel('Time (samples)'); ylabel('Amplitude'); axis tight;
subplot(3,3,2);
plot(freqx, abs(fft(x))); xlabel('Frequency (Hz)'); ylabel('Spectrum Magnitude'); axis tight; xlim([0 Nfx]);
subplot(3,3,5);
plot(freqyFF, abs(fft(yFF))); xlabel('Frequency (Hz)'); ylabel('Spectrum Magnitude'); axis tight; xlim([0 NyFF]);
subplot(3,3,8);
plot(freqyFB, abs(fft(yFB))); xlabel('Frequency (Hz)'); ylabel('Spectrum Magnitude'); axis tight; xlim([0 NyFB]);
subplot(3,3,3);
plot(freqx, mag2db(abs(fft(x))) - mag2db(max(abs(fft(x))))); xlim([0 2000]); xlabel('Frequency (Hz)'); ylabel('Magnitude (db)');
subplot(3,3,6);
plot(freqyFF, mag2db(abs(fft(yFF))) - mag2db(max(abs(fft(yFF))))); xlim([0 2000]); xlabel('Frequency (Hz)'); ylabel('Magnitude (db)');
subplot(3,3,9);
plot(freqyFB, mag2db(abs(fft(yFB))) - mag2db(max(abs(fft(yFB))))); xlim([0 2000]); xlabel('Frequency (Hz)'); ylabel('Magnitude (db)');






