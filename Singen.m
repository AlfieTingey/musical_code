clear all
A = 0.5;
Fs = 44100;
Tf = 1.0;
f0 = 200;
tau = 0.002;
N=44100;
tic
x = zeros(1,44100);

for n=0:N-1
    x(n+1)= exp(-n/Fs*tau)*A*sin(2*pi*f0*n/Fs);
end
toc

s1 = x;
plot(s1)
soundsc(s1,44100)
audiowrite('sine.wav',s1,44100)

