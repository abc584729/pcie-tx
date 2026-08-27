%% Spectrum Analysis
Rs = 450e3;
fs = 8*Rs*5*10*8;
x = double(out.simout);
[pxx,f] = pwelch(x, 1000, 500, 1024, fs);
w = 2*pi*f/fs;
plot(w/pi, pow2db(pxx));xlabel('\pi');

%% Time domain Analysis
x = double(out.simout);
t = out.tout(1:length(x));
plot(t, real(x));