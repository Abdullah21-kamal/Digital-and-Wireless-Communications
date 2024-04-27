function out = Decode(signal, levels)
out = [];
n = 8;
for i = 1 : n : length(signal)
    out = [out ,levels(1+bin2dec(signal(i:i+n-1)))];
end
end