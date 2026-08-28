clc, clear, close all; 

%% read csv
fid = fopen('result_qpsk.csv', 'r');
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

%% Eye Diagram
Rs = 450e3;
sps = fs/Rs;

eyediagram(data, 2*sps);
grid on;