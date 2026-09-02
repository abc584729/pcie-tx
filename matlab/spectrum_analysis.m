clc, clear, close all; 

%% read csv
fid = fopen('result.csv', 'r');
raw = textscan(fid, '%s');
fclose(fid);
lines = raw{1};

% each line is one 256-bit iq frame, RFDC format {q7,i7,...,q0,i0}
nz = find(cellfun(@(a) any(a=='1'), lines), 1, 'first');
lines = lines(nz:end);

data = [];
for k = 1:length(lines)
    b = lines{k};
    for j = 1:8
        base = (8-j)*32;          % lane j=1..8 -> q0..q7 (q0 = earliest sample), 32 bit per lane
        bq = b(base+1:base+16);
        bi = b(base+17:base+32);

        uq = bin2dec(bq);
        if uq >= 2^15, uq = uq - 2^16; end
        ui = bin2dec(bi);
        if ui >= 2^15, ui = ui - 2^16; end

        data(end+1) = complex(ui, uq) / 2^15;
    end
end

data = data(1:8192);



%% Spectrum Analysis
fs = 180e6*8;
figure;
N = 8192;
X = fft(data, N);
X = X(1:N/2+1);                  
f = (0:N/2)*fs/N;         
plot(f/1e6, 20*log10(abs(X)./max(abs(X)) + eps)); grid on;
xlabel('Frequency (MHz)');
ylabel('Magnitude (dB)');
