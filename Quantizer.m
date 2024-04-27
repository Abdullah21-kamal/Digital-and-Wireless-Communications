function [quantized,levels] = Quantizer(signal, NumberOflevels)
maxlvl = max([max(signal) abs(min(signal))]);
levels = [-inf,-maxlvl:2*maxlvl/NumberOflevels:maxlvl-2*maxlvl/NumberOflevels, inf];
quantized = signal';
for l = 2:length(levels)-1
    quantized(levels(l-1)< quantized & levels(l) >= quantized) = levels(l); 
end
levels = levels(2:length(levels)-1);
end