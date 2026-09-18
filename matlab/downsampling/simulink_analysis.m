close all;
%% Spectrum Analysis
figure;
subplot(212);
fs = 1.44e9/8/4;
x = double(out.simout);
[pxx,f] = pwelch(x, 1000, 500, 1024, fs);
w = 2*pi*f/fs;
plot(f/(1e6), 10*log10(pxx/max(pxx)));xlabel('MHZ');

%% Time domain Analysis
subplot(211);
t = out.tout(1:length(x));
plot(t, real(x));
