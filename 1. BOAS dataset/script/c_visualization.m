%% Visualization

cd '/Users/filippobarbadoro/Desktop/Matlab/BOAS dataset/script'

%% ----- Data extraction -----
trial_raw = data_raw.trial{1};
trial_eeg_filt = data_eeg_filt.trial{1};
trial_eog_filt = data_eog_filt.trial{1};
trial_emg_filt = data_emg_filt.trial{1};

% Info of raw data
num_channels = size(trial_raw, 1); %ricorda: in size(array, dimensione) quindi 1 canali, 2 campioni
time = data_raw.time{1};
chan_labels = data_raw.label;

%% ----- Plot -----
% Single plots for each channel
% 1. whole raw signal
for i = 1:num_channels
    figure;
    plot(time, trial_raw(i,:));
    title(chan_labels{i});
end

% 2. reducted raw signal
for i = 1:num_channels
    figure();
    plot(time(1,1:10000), trial_raw(i,1:10000));
    title(chan_labels{i});
end

%% Paired plot for each channel (i.e., raw vs filtered)
% 1. EEG
trial_raw_eeg = trial_raw(1:6,:);
n_chan_eeg = size(trial_raw_eeg,1);
chan_labels_eeg = data_raw.label(1:6);
n_chan_eeg_filt = size(trial_eeg_filt,1);
chan_labels_eeg_filt = data_eeg_filt.label;

for n = 1:n_chan_eeg
    figure();
    plot(time(1,:),trial_raw_eeg(n,:));
    hold on;
    plot(time(1,:), trial_eeg_filt(n,:));
    title(chan_labels_eeg{n});
    hold off;
end

% 2. EOG
figure();
plot(time(1,1:1000),trial_raw(7,1:1000));
hold on;
plot(time(1,1:1000),trial_eog_filt(1,1:1000));
hold off;

% 3. EMG
figure();
plot(time(1,1:1000),trial_raw(7,1:1000));
hold on;
plot(time(1,1:1000),trial_emg_filt(1,1:1000));
hold off;

%% Looking for artifcat at 27Hz
% power spectrum filtered eeg data
cfg         = [];
cfg.method  = 'mtmfft';
cfg.taper   = 'hanning';
cfg.foi     = 0.3:1:35;
cfg.channel = 'all';
freq_data   = ft_freqanalysis(cfg, data_eeg_filt);

% visualization
cfg = [];
cfg.parameter = 'powspctrm';
ft_singleplotER(cfg, freq_data);
