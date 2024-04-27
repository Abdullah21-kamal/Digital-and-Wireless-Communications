clear;
clc;

% Reading the audio signal 
[audio,fs]= audioread("Menshawy.wav");

audio=audio(:,1);
%audio=audio(40000:100000);

% Quantizing and decoding the signal 
[audio_quantized,audio_levels] = Quantizer(audio(:,1), 2^8);
audio_bit_stream= Encode(audio_quantized, audio_levels);

% QPSK Modulation
qpsk_Modulator=comm.QPSKModulator('BitInput',true);
modulatedSignal=qpsk_Modulator(audio_bit_stream');
scatterplot(modulatedSignal);
xlabel('x-axis');
ylabel('y-axis');
title('modulated Signal');


% FILTER DESIGN
roll_off = 0.22;
Samples_per_symbol = 2;  % beacuase we are working with QPSK
Number_of_symbols = 4;
filter_Coeff = rcosdesign(roll_off, Number_of_symbols, Samples_per_symbol);

% sending the filtered signal 
transmitted_sig = upfirdn(modulatedSignal,filter_Coeff,Samples_per_symbol);
scatterplot(transmitted_sig);
xlabel('x-axis');
ylabel('y-axis');
title('transmitted Signal');


% Adding AWGN 
awgnchannel = comm.AWGNChannel('EbNo',20,'BitsPerSymbol',2);
noisy_sig = awgnchannel(transmitted_sig);
scatterplot(noisy_sig);
xlabel('x-axis');
ylabel('y-axis');
title('noisy AWGN Signal');


% Adding Rayleigh noise

rayleighchan = comm.RayleighChannel(...
'SampleRate',fs,...
'PathDelays',[0 1e-20], ...
'AveragePathGains',[2 3], ...
'NormalizePathGains',true, ...
'MaximumDopplerShift',0.01, ...
'RandomStream','mt19937ar with seed', ...
'Seed',22, ...
'PathGainsOutputPort',true);

noisy_ray_rician = rayleighchan(transmitted_sig);
scatterplot(noisy_ray_rician);

xlabel('x-axis');
ylabel('y-axis');
title('noisy ray Signal');



% Add rician chan
ricianchan = comm.RicianChannel( ...
    'SampleRate',fs, ...
    'PathDelays',[0 1e-3], ...
    'AveragePathGains',[0 -2], ...
    'PathGainsOutputPort',true);

noisy_sig_rician = ricianchan(transmitted_sig);
scatterplot(noisy_sig_rician);

xlabel('x-axis');
ylabel('y-axis');
title('noisy rician Signal');





% Recieving the Signal 

recieved_unfiltered = upfirdn(noisy_sig_rician,filter_Coeff,1,Samples_per_symbol);
recieved_unfiltered = recieved_unfiltered(5:end-4); 
out = pskdemod(recieved_unfiltered, 4);
for i = 1: length(out)
    if out(i) >= 1
       out(i) = 1; 
    else
        out(i) = 0;
    end
end
out = sprintf('%d',out);
decoded = Decode(out, audio_levels);

audiowrite('mensh2.wav', decoded, fs);
