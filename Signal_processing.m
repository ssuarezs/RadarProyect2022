clc;

filename = 'Dataset_03/CPRmeasure030013';

freq_pulm_ref = str2double(strcat(filename(22), '.', filename(23:25)));
freq_hear_ref = str2double(strcat(filename(26), '.', filename(27:end)));
 
file = fopen(filename, 'rb');
signal_in = fread(file, Inf, 'float').';

w_state = 'minimized'; % 'maximized'

fs = 1e6 / 40e3; % Baseband
t_tot = length(signal_in)/fs;
t = linspace(0, t_tot, length(signal_in));

SIG = fftshift(fft(signal_in));
f = linspace(-fs/2, fs/2, length(signal_in));

% filters definition
fc_lp = (3/fs)*2;
fc_bp_p = ([0.0001, 0.6]/fs)*2;
fc_bp_c = ([0.6, 3]/fs)*2;

B_lp = fir1(50, fc_lp, 'low');
B_bp_p = fir1(200, fc_bp_p, 'bandpass');
B_bp_c = fir1(200, fc_bp_c, 'bandpass');


% Measured data plotting
f_m_sig = figure;
f_m_sig.Name = "Measured Data";
f_m_sig.NumberTitle = 'off';
f_m_sig.WindowState = w_state;

figure(f_m_sig);
subplot(2, 1, 1);
plot(t, signal_in);
grid on, grid minor;

subplot(2, 1, 2);
plot(f, abs(SIG)/max(abs(SIG)));
grid on, grid minor;
xlim([-fs/2, fs/2]);

sgtitle('Measured data') 


% Signal filtering 
sig_lp = fftfilt(B_lp, signal_in, length(signal_in));
sig_bp_p = fftfilt(B_bp_p, sig_lp, length(signal_in));
sig_bp_c = fftfilt(B_bp_c, sig_lp, length(signal_in));

sig_pulm = sig_bp_p./envelope(sig_bp_p);
sig_heart = sig_bp_c./envelope(sig_bp_c);


% Heart signal acquisition

S_HEART = fftshift(fft(sig_heart));

f_Heart_sig = figure;
f_Heart_sig.Name = "Heart Signals";
f_Heart_sig.NumberTitle = 'off';
f_Heart_sig.WindowState = 'minimized';

figure(f_Heart_sig);
subplot(3, 1, 1);
plot(t, sig_bp_c);
hold on;
plot(t, envelope(sig_bp_c));
grid on, grid minor;
legend("Filtered signal for heart", "Signal envelope", 'Location','southwest');
title("Raw heart signal and signal envelope")

subplot(3, 1, 2);
plot(t, sig_heart);
grid on, grid minor;
title("Heart signal isolated")

subplot(3, 1, 3);
plot(f, abs(S_HEART)/max(abs(S_HEART)));
grid on, grid minor;
title("Heart signal FFT")

sgtitle('Heart Signals') 

% Heart rate estimation

[~, I_S_H] = max(abs(S_HEART(ceil(length(S_HEART)/2):end)));
Heart_freq = f(I_S_H+ceil(length(S_HEART)/2));



% Pulmonar signal acquisition

S_PULM = fftshift(fft(sig_pulm));

f_Pulm_sig = figure;
f_Pulm_sig.Name = "Pulmonar Signals";
f_Pulm_sig.NumberTitle = 'off';
f_Pulm_sig.WindowState = 'minimized';

figure(f_Pulm_sig);
subplot(3, 1, 1);
plot(t, sig_bp_p);
hold on;
plot(t, envelope(sig_bp_p));
grid on, grid minor;
legend("Filtered signal for heart", "Signal envelope", 'Location','southwest');
title("Raw pulmonar signal and signal envelope")

subplot(3, 1, 2);
plot(t, sig_pulm);
grid on, grid minor;
title("Pulmonar signal isolated")

subplot(3, 1, 3);
plot(f, abs(S_PULM)/max(abs(S_PULM)));
grid on, grid minor;
title("Normalized Pulmonar signal FFT")

sgtitle('Pulmonar Signals') 

[~, I_S_P] = max(abs(S_PULM(ceil(length(S_PULM)/2):end)));
pulmonar_freq = f(I_S_P+ceil(length(S_PULM)/2));

% Signal comparison
f_all_sig = figure;
f_all_sig.Name = "All Signals";
f_all_sig.NumberTitle = 'off';
f_all_sig.WindowState = 'minimized';

figure(f_all_sig);
subplot(3, 1, 1);
plot(t, sig_lp/max(sig_lp));
grid on, grid minor;
title("Full measured signal");

subplot(3, 2, 3);
plot(t, sig_bp_p/max(sig_bp_p));
grid on, grid minor;
title("Pulmonar filter output Signal");

subplot(3, 2, 4);
plot(t, sig_pulm/max(sig_pulm));
grid on, grid minor;
legend("Measured Pulmonar Freq: " + num2str(pulmonar_freq) + " Hz", 'Location','southwest')
title("Isolated pulmonar Signal");

subplot(3, 2, 5);
plot(t, sig_bp_c/max(sig_bp_c));
grid on, grid minor;
title("Heart filter output Signal");

subplot(3, 2, 6);
plot(t, sig_heart/max(sig_heart));
grid on, grid minor;
legend("Measured Heart Freq: " + num2str(Heart_freq) + " Hz", 'Location','southwest')
title("Isolated pulmonar Signal");

sgtitle("All signals - "+filename)

pulm_freq_err = (pulmonar_freq - freq_pulm_ref)/freq_pulm_ref;
hear_freq_err = (Heart_freq - freq_hear_ref)/freq_hear_ref;

Results = table(freq_pulm_ref, freq_hear_ref, pulmonar_freq, Heart_freq, pulm_freq_err, hear_freq_err)

% Script end