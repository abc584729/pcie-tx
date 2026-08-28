clc, clear, close all; 

%% read csv
fid = fopen('result.csv', 'r');
raw = textscan(fid, '%s');
fclose(fid);
lines = raw{1};

data = [];

for i = 1:length(lines)
    bin128 = lines{i};

    for j = 1:8
        idx1 = (8-j)*16 + 1;
        idx2 = (8-j+1)*16;

        bin16 = bin128(idx1:idx2);
        u = bin2dec(bin16);
        if u >= 2^15, u = u - 2^16; end 
        value = u / 2^15;          

        data(end+1) = value;
    end
end

data = data(find(data ~= 0, 1):end);   

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

eyediagram(data, 2*sps);
grid on;