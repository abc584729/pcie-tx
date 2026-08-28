clc, clear, close all; 

%% read csv
fid = fopen('result.csv', 'r');
lines = textscan(fid, '%s');
fclose(fid);

data = [];

for i = 1:length(lines)
    bin128 = lines{i};

    for j = 1:8
        idx1 = (j-1)*16 + 1;
        idx2 = j*16;

        bin16 = bin128(idx1:idx2);
        value = bin2dec(bin16)/ 2^16;

        data(end+1) = value;
    end
end

%% Time domain Analysis
fs = 180e6*8;
figure;
subplot(211);
t = (1:length(data))./fs;
plot(t, real(data));

%% Spectrum Analysis
subplot(212);
[pxx,f] = pwelch(data, 1000, 500, 1024, fs);
w = 2*pi*f/fs;
plot(w/pi, pow2db(pxx));xlabel('\pi');

%% Eye Diagram
Rs = 450e3;
sps = fs/Rs;

figure;
eyediagram(data, 2*sps);
grid on;