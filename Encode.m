function out = Encode(signal, levels)
codes = dec2bin(0:length(levels)-1,8);
out = [];
for i = 1:length(signal)
    out = [out , codes(signal(i) == levels,:)-'0'];
end

end
