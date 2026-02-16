%% Periodogram

cd '/Users/filippobarbadoro/Desktop/Matlab/BOAS dataset/script'

%% Channel selection
toi = 1:data_eeg_filt.sampleinfo(1,2);
F3 = data_eeg_filt.trial{1}(1, toi);
F4 = data_eeg_filt.trial{1}(2, toi);
C3 = data_eeg_filt.trial{1}(3, toi);
C4 = data_eeg_filt.trial{1}(4, toi);
O1 = data_eeg_filt.trial{1}(5, toi);
O2 = data_eeg_filt.trial{1}(6, toi);

%% Periodogram for single channel
[pxx, f] = periodogram(C3,[],[],data_eeg_filt.fsample); % Select the channel of interest

figure;
plot(f, 10*log10(pxx), 'LineWidth', 1.5);
grid on;
xlabel('Frequency (Hz)');
ylabel('Power (dB/Hz)');
title('Periodogram');
xlim([0.35 49]);

%saveas(gcf, '/Users/filippobarbadoro/Desktop/Matlab/BOAS dataset/figure/Periodogram_F3.png');

%% Subplot of the periodograms of all channel of interest
[pxxC3, fC3] = periodogram(C3,[],[],data_eeg_filt.fsample);
[pxxC4, fC4] = periodogram(C4,[],[],data_eeg_filt.fsample);
[pxxF4, fF4] = periodogram(F4,[],[],data_eeg_filt.fsample);
[pxxO2, fO2] = periodogram(O2,[],[],data_eeg_filt.fsample);

figure;
subplot(2,2,1);
plot(fC3, 10*log10(pxxC3), 'LineWidth', 1.5);
grid on;
xlabel('Frequency (Hz)');
ylabel('Power (dB/Hz)');
title('Periodogram C3');
xlim([0.35 49]);

subplot(2,2,2);
plot(fC4, 10*log10(pxxC4), 'LineWidth', 1.5);
grid on;
xlabel('Frequency (Hz)');
ylabel('Power (dB/Hz)');
title('Periodogram C4');
xlim([0.35 49]);

subplot(2,2,3);
plot(fF4, 10*log10(pxxF4), 'LineWidth', 1.5);
grid on;
xlabel('Frequency (Hz)');
ylabel('Power (dB/Hz)');
title('Periodogram F4');
xlim([0.35 49]);

subplot(2,2,4);
plot(fO2, 10*log10(pxxO2), 'LineWidth', 1.5);
grid on;
xlabel('Frequency (Hz)');
ylabel('Power (dB/Hz)');
title('Periodogram O2');
xlim([0.35 49]);

saveas(gcf, '/Users/filippobarbadoro/Desktop/Matlab/BOAS dataset/figure/Periodogram_allChan.png');

%% Periodogram of the average signal
avgSig = mean(data_eeg_filt.trial{1}(:, 9800:11970),1); % average signal of the time window of interest

[pxx_Sig, f_Sig] = periodogram(avgSig,[],[],data_eeg_filt.fsample);

figure;
plot(f_Sig, 10*log10(pxx_Sig), 'LineWidth', 1.5);
grid on;
xlabel('Frequency (Hz)');
ylabel('Power (dB/Hz)');
title('Periodogram Average Signal');
xlim([0.35 49]);

saveas(gcf, '/Users/filippobarbadoro/Desktop/Matlab/BOAS dataset/figure/Periodogram_AvgSig.png');

%% Average periodogram of the whole night
avgSignal = mean(data_eeg_filt.trial{1},1);
window_len = 4 * data_eeg_filt.fsample; % time window of 4 second
noverlap = window_len / 2; % overlap of 50%

[pxx_Avg, f_Avg] = pwelch(avgSignal, window_len, noverlap, [], data_eeg_filt.fsample); % [] = Hamming window standard
figure;
plot(f_Avg, 10*log10(pxx_Avg), 'LineWidth', 1.5, 'Color', [0 0.4470 0.7410]);
grid on;
xlabel('Frequency (Hz)');
ylabel('Power (dB/Hz)');
title('Average Periodogram (whole night)');
xlim([0.35 49]);

%saveas(gcf, '/Users/filippobarbadoro/Desktop/Matlab/BOAS dataset/figure/Avg_Periodogram.png')

%% all night periodograms
%% C3

% Periodogram
[pxx_C3_allnight, f_C3_allnight]=periodogram(C3, [],[],data_eeg_filt.fsample);

figure;
plot(f_C3_allnight, pxx_C3_allnight);

% Periodogram Welch
[pxx_C3_alln_welch, f_C3_alln_welch] = pwelch(C3, [], [], data_eeg_filt.fsample);
plot(f_C3_alln_welch,pxx_C3_alln_welch);

% Pspectrum
[pxx_C3_alln_pspect, f_C3_alln_pspect] = pspectrum(C3,data_eeg_filt.fsample);
plot(f_C3_alln_pspect,pxx_C3_alln_pspect)
%%
figure
subplot(3,1,1);
plot(f_C3_allnight, pxx_C3_allnight)

subplot(3,1,2);
plot(f_C3_alln_welch,pxx_C3_alln_welch)

subplot(3,1,3);
plot(f_C3_alln_pspect,pxx_C3_alln_pspect)

%% F3

% Periodogram
[pxx_F3_allnight, f_F3_allnight]=periodogram(F3, [],[],data_eeg_filt.fsample);

figure;
plot(f_F3_allnight, pxx_F3_allnight);

% Periodogram Welch
[pxx_F3_alln_welch, f_F3_alln_welch] = pwelch(F3, [], [], data_eeg_filt.fsample);
plot(f_F3_alln_welch,pxx_F3_alln_welch);

% Pspectrum
[pxx_F3_alln_pspect, f_F3_alln_pspect] = pspectrum(F3,data_eeg_filt.fsample);
plot(f_F3_alln_pspect,pxx_F3_alln_pspect)
%%
figure
subplot(3,1,1);
plot(f_F3_allnight, pxx_F3_allnight)

subplot(3,1,2);
plot(f_F3_alln_welch,pxx_F3_alln_welch)

subplot(3,1,3);
plot(f_F3_alln_pspect,pxx_F3_alln_pspect)


%% C4

% Periodogram
[pxx_C4_allnight, f_C4_allnight]=periodogram(C4, [],[],data_eeg_filt.fsample);

figure;
plot(f_C4_allnight, pxx_C4_allnight);

% Periodogram Welch
[pxx_C4_alln_welch, f_C4_alln_welch] = pwelch(C4, [], [], data_eeg_filt.fsample);
plot(f_C4_alln_welch,pxx_C4_alln_welch);

% Pspectrum
[pxx_C4_alln_pspect, f_C4_alln_pspect] = pspectrum(C4,data_eeg_filt.fsample);
plot(f_C4_alln_pspect,pxx_C4_alln_pspect)

%%
figure()

subplot(3,1,1);
plot(f_C3_alln_welch,pxx_C3_alln_welch)
title('C3')


subplot(3,1,2);
plot(f_F3_alln_welch,pxx_F3_alln_welch)
title('F3')

subplot(3,1,3);
plot(f_C4_alln_welch,pxx_C4_alln_welch);
title('C4')

%%
figure()

subplot(3,1,1);
plot(f_C3_alln_pspect,pxx_C3_alln_pspect)
title('C3')


subplot(3,1,2);
plot(f_F3_alln_pspect,pxx_F3_alln_pspect)
title('F3')

subplot(3,1,3);
plot(f_C4_alln_pspect,pxx_C4_alln_pspect);
title('C4')

%% O1

% Periodogram
[pxx_O1_allnight, f_O1_allnight]=periodogram(O1, [],[],data_eeg_filt.fsample);

figure;
plot(f_O1_allnight, pxx_O1_allnight);

% Periodogram Welch
[pxx_O1_alln_welch, f_O1_alln_welch] = pwelch(O1, [], [], data_eeg_filt.fsample);
plot(f_O1_alln_welch,pxx_O1_alln_welch);

% Pspectrum
[pxx_O1_alln_pspect, f_O1_alln_pspect] = pspectrum(O1,data_eeg_filt.fsample);
plot(f_O1_alln_pspect,pxx_O1_alln_pspect)

%% O2

% Periodogram
[pxx_O2_allnight, f_O2_allnight]=periodogram(O2, [],[],data_eeg_filt.fsample);

figure;
plot(f_O2_allnight, pxx_O2_allnight);

% Periodogram Welch
[pxx_O2_alln_welch, f_O2_alln_welch] = pwelch(O2, [], [], data_eeg_filt.fsample);
plot(f_O2_alln_welch,pxx_O2_alln_welch);

% Pspectrum
[pxx_O2_alln_pspect, f_O2_alln_pspect] = pspectrum(O2,data_eeg_filt.fsample);
plot(f_O2_alln_pspect,pxx_O2_alln_pspect)

%% F4

% Periodogram
[pxx_F4_allnight, f_F4_allnight]=periodogram(F4, [],[],data_eeg_filt.fsample);

figure;
plot(f_F4_allnight, pxx_F4_allnight);

% Periodogram Welch
[pxx_F4_alln_welch, f_F4_alln_welch] = pwelch(F4, [], [], data_eeg_filt.fsample);
plot(f_F4_alln_welch,pxx_F4_alln_welch);

% Pspectrum
[pxx_F4_alln_pspect, f_F4_alln_pspect] = pspectrum(F4,data_eeg_filt.fsample);
plot(f_F4_alln_pspect,pxx_F4_alln_pspect)

%% Mean of periodograms
somma_pxx_periodogram = pxx_O2_allnight+pxx_O1_allnight+pxx_C3_allnight+pxx_C4_allnight+pxx_F3_allnight+pxx_F4_allnight;
media_pxx_periodogram = somma_pxx_periodogram/6;

somma_f_periodogram = f_F4_allnight+f_F3_allnight+f_C4_allnight+f_C3_allnight+f_O1_allnight+f_O2_allnight;
media_f_periodogram = somma_f_periodogram/6;

figure;
plot(media_f_periodogram, media_pxx_periodogram);
title('Periodogramma medio');
saveas(gcf,'/Users/filippobarbadoro/Desktop/Matlab/BOAS dataset/figure/Periodogramma_medio.png');

%%