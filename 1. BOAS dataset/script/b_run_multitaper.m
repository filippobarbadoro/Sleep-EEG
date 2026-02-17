%% _____ Pairing channels _____
%            (median)      

labels = data_eeg_filt.label;   
signal = data_eeg_filt.trial{1};

% Index for each EEG channel
idxF3 = find(strcmp(labels,'PSG_F3'));
idxF4 = find(strcmp(labels,'PSG_F4'));
idxC3 = find(strcmp(labels,'PSG_C3'));
idxC4 = find(strcmp(labels,'PSG_C4'));
idxO1 = find(strcmp(labels,'PSG_O1'));
idxO2 = find(strcmp(labels,'PSG_O2'));

% Median
dataFrontal  = median(signal([idxF3 idxF4], :), 1)';
dataCentral  = median(signal([idxC3 idxC4], :), 1)';
dataOccipital= median(signal([idxO1 idxO2], :), 1)';

%% ----- Input required -----
data = dataFrontal; % dataFrontal; dataCentral; dataOccipital
Fs = data_eeg_filt.fsample; % da inserire corretto riferimento al dataset
frequency_range = [0 30];
taper_params = [15 29]; % [TW L] = full night spectogram [15 29], ultradian cycle spectogram [3 5], spindles/k-complex [5 9] 
window_params = [30 5]; % [window step] = full night spectogram [30 5], ultradian cycle spectogram [6 0.25], spindles/k-complex [2.5 0.05]
min_nfft = 0;
detrend_opt = 'constant'; % 'costant' or 'linear' or 'off'
weighting = 'unity'; % 'unity' or 'eigen' or 'adapt'
plot_on = true;
verbose = true;

% call the function
[spect, stimes, sfreqs] = multitaper_spectrogram(data, Fs, frequency_range, taper_params, window_params, min_nfft, detrend_opt, weighting, plot_on, verbose);

