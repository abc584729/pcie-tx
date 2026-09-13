close all;
%% Spectrum Analysis
figure;
subplot(212);
Rs = 400e3;
fs = 9*Rs;
x = double(out.simout);
[pxx,f] = pwelch(x, 1000, 500, 1024, fs);
w = 2*pi*f/fs;
plot(w/pi, 10*log10(pxx/max(pxx)));xlabel('\pi');

%% Time domain Analysis
subplot(211);
t = out.tout(1:length(x));
plot(t, real(x));

%% Eye Diagram
sps = fs/Rs;

eyediagram(x, 2*sps);
grid on;