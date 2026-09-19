clc, clear, close all;

%% read bin
fid = fopen('capture.bin', 'rb');
raw = fread(fid, inf, 'int16=>double', 0, 'l');
fclose(fid);

raw = raw(1 : 2*floor(numel(raw)/2));      
iq  = raw(2:2:end) + 1i*raw(1:2:end);       

%% spectrum
figure;
fs = 45e6;
[pxx,f] = pwelch(iq, 1000, 500, 1024, fs);
plot(f/(1e6), 10*log10(pxx/max(pxx)));xlabel('MHZ');
