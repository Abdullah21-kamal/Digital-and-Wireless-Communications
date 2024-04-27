% clear;
% clc;
% 
% %
% [audio,fs]= audioread("Menshawy.wav");
% %audio=audio(:,1);
% %audio=audio(40000:90000);
% [audio_quantized,audio_levels] = Quantizer(audio(:,1), 2^8);
% audio_bit_stream= Encode(audio_quantized, audio_levels);
% 
% %
% modulatedSignal  = pskmod(audio_bit_stream, 4);
% % Filter:
% roll_off = 0.22;
% Samples_per_symbol = 2;  % beacuase we are working with QPSK
% Number_of_symbols = 4;
% filter_Coeff = rcosdesign(roll_off, Number_of_symbols, Samples_per_symbol);
% 
% %
% % using filter:
% x = upfirdn(modulatedSignal, filter_Coeff, Samples_per_symbol);
% %
% y = upfirdn(x, filter_Coeff, 1, Samples_per_symbol);
% %
% 
% out = pskdemod(modulatedSignal, 4);
% out = sprintf('%d',out);
% decoded = Decode(out, audio_levels);
% 
% 
% audiowrite('mensh2.wav', decoded, fs);
% disp(y(100:105))
% disp('bbbbbbbbbbbbbbbbbbbbbbbbb')
% disp(modulatedSignal(100:105))




clear;
clc;
% Reading the audio signal 
[audio,fs]= audioread("Menshawy.wav");
% Quantizing and decoding the signal 
[audio_quantized,audio_levels] = Quantizer(audio(:,1), 2^8);
audio_bit_stream= Encode(audio_quantized, audio_levels);
% QPSK Modulation
modulatedSignal  = pskmod(audio_bit_stream, 4);
% FILTER DESIGN
roll_off = 0.22;
Samples_per_symbol = 2;  % beacuase we are working with QPSK
Number_of_symbols = 4;
filter_Coeff = rcosdesign(roll_off, Number_of_symbols, Samples_per_symbol);
% sending the filtered signal 
transmitted_sig = upfirdn(modulatedSignal,filter_Coeff,Samples_per_symbol);
% Adding AWGN 
awgnchannel = comm.AWGNChannel('EbNo',20,'BitsPerSymbol',2);
noisy_sig = awgnchannel(transmitted_sig);

% here
%transmitted_sig = awgn(transmitted_sig,2);
% rayleighchan = comm.RayleighChannel(...
% 'SampleRate',100e3, ...
% 'PathDelays',[0 1e-20], ...
% 'AveragePathGains',[2 3], ...
% 'NormalizePathGains',true, ...
% 'MaximumDopplerShift',0.01, ...
% 'RandomStream','mt19937ar with seed', ...
% 'Seed',22, ...
% 'PathGainsOutputPort',true);
% 
% ray_noisy_sig = rayleighchan(transmitted_sig);
% Adding Rayleigh noise
%there

% Recieving the Signal 
recieved_unfiltered = upfirdn(noisy_sig,filter_Coeff,1,Samples_per_symbol);
recieved_unfiltered = recieved_unfiltered(5:end-4); 
out = pskdemod(recieved_unfiltered, 4);
out = sprintf('%d',out);
decoded = Decode(out, audio_levels);
