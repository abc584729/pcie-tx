clc, clear, close all; 

%% read csv
fid = fopen('result_board.csv', 'r');
raw = textscan(fid, '%s');
fclose(fid);
lines = raw{1};

nG = floor(length(lines)/2);       
iLines = lines(1:2:2*nG);             
qLines = lines(2:2:2*nG);           

nz = find(cellfun(@(a,b) any(a=='1') || any(b=='1'), iLines, qLines), 1, 'first');
iLines = iLines(nz:end);
qLines = qLines(nz:end);

data = [];
for k = 1:length(iLines)
    bi = iLines{k};
    bq = qLines{k};
    for j = 1:8
        idx1 = (8-j)*16 + 1;
        idx2 = (8-j+1)*16;

        ui = bin2dec(bi(idx1:idx2));
        if ui >= 2^15, ui = ui - 2^16; end  
        uq = bin2dec(bq(idx1:idx2));
        if uq >= 2^15, uq = uq - 2^16; end

        data(end+1) = complex(ui, uq) / 2^15;  
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

%% BPSK branch: fc = 100 MHz, Rs = 450 kHz
fc = 100e6;
x = data.*exp(-1i*2*pi*fc*(0:length(data)-1)/fs);

Rs = 450e3;
alpha = 0.25;
D = round(fs/(10*Rs));                   
h = ones(1, D)/D;                    
x = conv(x, h);
x = x(1:D:end);
fs2 = fs/D;

wd = ((1+alpha)*Rs/2)/(fs2)*2*pi;
N = 128;
b = fir1(N, wd/pi);
x = filter(b, 1, x);
x = x(N+1:end);

% de-rotation with drift tracking (pinc quantization causes slow
% carrier phase rotation over long records)
seg = floor(length(x)/20);
phi_t = zeros(1,20);
for k = 1:20
    w = x((k-1)*seg+1 : k*seg);
    phi_t(k) = angle(mean(w.^2));
end
pp = polyfit((1:20)*seg - seg/2, unwrap(phi_t), 1);
x = x.*exp(-1i*(pp(1)*(0:length(x)-1) + pp(2))/2);

sps = fs2/Rs;

eyediagram(x, 2*sps);
grid on;

%% QPSK branch: fc = 200 MHz, Rs = 4.5 MHz
fc = 200e6;
x = data.*exp(-1i*2*pi*fc*(0:length(data)-1)/fs);

Rs = 4.5e6;
D = round(fs/(10*Rs));
h = ones(1, D)/D;
x = conv(x, h);
x = x(1:D:end);
fs2 = fs/D;

wd = ((1+alpha)*Rs/2)/(fs2)*2*pi;
b = fir1(N, wd/pi);
x = filter(b, 1, x);
x = x(N+1:end);

seg = floor(length(x)/20);
phi_t = zeros(1,20);
for k = 1:20
    w = x((k-1)*seg+1 : k*seg);
    phi_t(k) = angle(mean(w.^4));
end
pp = polyfit((1:20)*seg - seg/2, unwrap(phi_t), 1);
x = x.*exp(-1i*((pp(1)*(0:length(x)-1) + pp(2))/4 - pi/4));

sps = fs2/Rs;

eyediagram(x, 2*sps);
grid on;