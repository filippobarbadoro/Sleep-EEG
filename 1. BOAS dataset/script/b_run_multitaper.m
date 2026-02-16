%% Call the function of multitaper_spectogram.m
clear all
close all
clc

cd '/Users/filippobarbadoro/Desktop/Matlab/BOAS dataset/script'

%% ----- Import and visualization of raw data in edf format -----
% Import and read edf file
cfg             = [];
cfg.dataset     = '/Users/filippobarbadoro/Desktop/Matlab/BOAS dataset/data/sub-2_task-Sleep_acq-psg_eeg.edf';
cfg.continuous  = 'yes';
cfg.readbids    = 'no'; % to do not read the file.tsv
cfg.channel     = 'all';
data_raw   = ft_preprocessing(cfg);

% Visualization of continuous data in 30s epochs
cfg = [];
cfg.continuous ='yes';
cfg.viewmode = 'vertical';
cfg.blocksize = 30; % seconds
ft_databrowser(cfg,data_raw);

%% ----- Preprocessing -----

% 1. Notch filter
cfg               = [];
cfg.channel       = 'all';
cfg.bsfilter      = 'yes';
cfg.bsfreq        = [49 51];
data_notch        = ft_preprocessing(cfg, data_raw);

% 1.1
cfg               = [];
cfg.channel       = 'all';
cfg.bsfilter      = 'yes';
cfg.bsfreq        = [26 28];
data_notch        = ft_preprocessing(cfg, data_notch);

% 2. Filtering EEG channels
cfg               = [];
cfg.channel       = {'PSG_F3' 'PSG_F4' 'PSG_C3' 'PSG_C4' 'PSG_O1' 'PSG_O2'};
cfg.bpfilter      = 'yes';
cfg.bpfreq        = [0.3 35]; % according to AASM guideliens
data_eeg_filt     = ft_preprocessing(cfg, data_notch);

% 3. Filtering EOG channels
cfg               = [];
cfg.channel       = 'PSG_EOG';
cfg.bpfilter      = 'yes';
cfg.bpfreq        = [0.3 35]; % according to AASM guideliens
data_eog_filt     = ft_preprocessing(cfg, data_notch);

% 4. Filtering EMG channels
cfg               = [];
cfg.channel       = 'PSG_EMG';
cfg.bpfilter      = 'yes';
cfg.bpfreq        = [10 100]; % according to AASM guideliens
data_emg_filt     = ft_preprocessing(cfg, data_notch);

% 5. Other physiological channels not filtered
cfg               = [];
cfg.channel       = {'PSG_THER' 'PSG_THOR' 'PSG_ABD'};
data_notfil       = ft_preprocessing(cfg, data_notch);

% 6. Recomponing the dataset
data_filtered = ft_appenddata([], data_eeg_filt, data_eog_filt, data_emg_filt, data_notfil);

% 7. Visualization of filtered data in 30s epochs
cfg = [];
cfg.continuous ='yes';
cfg.viewmode = 'vertical';
cfg.blocksize = 30;
ft_databrowser(cfg,data_filtered);

%% 8. Epoching in 30s segment

cfg             = [];
cfg.length      = 30; %seconds
cfg.overlap     = 0;
data_epoched    = ft_redefinetrial(cfg,data_eeg_filt);

%NOTE: remember that if I decide to segment the data to remove artifacts etc, 
% it must then be recomposed because the multitaper needs continuous data!!

%% 9. Atypical artifact rejection (databrowser)
% https://www.fieldtriptoolbox.org/tutorial/preproc/ica_artifact_cleaning/#rejecting-atypical-artifacts

cfg                 = [];
cfg.continuous      = 'yes'; % this can also be used on trial-based data to paste them together
cfg.blocksize       = 60;
cfg.plotevents      = 'no';
cfg.preproc.demean  = 'yes';
cfg.layout          = 'CTF151.lay';
cfg = ft_databrowser(cfg, data_filtered);

% remember the time of the artifacts
cfg_artfctdef = cfg.artfctdef;

%% 9. Atypical artifact rejection (rejectvisual)

cfg             = [];
cfg.method      = 'summary';
cfg.keepchannel = 'yes';
cfg.keeptrial   = 'nan';
cfg.channel     = {'PSG_F3' 'PSG_F4' 'PSG_C3' 'PSG_C4' 'PSG_O1' 'PSG_O2'};
cfg.layout      = 'CTF151.lay';
data_epoched_clean = ft_rejectvisual(cfg, data_epoched);

%% Visualization of continuous data in 30s epochs
cfg = [];
cfg.continuous ='yes';
cfg.viewmode = 'vertical';
cfg.blocksize = 30; % seconds
ft_databrowser(cfg,data_epoched_clean);

%% 10. Interpolation of bad channels
badchannel = {'PSG_C4'};

cfg = [];
cfg.method  = 'distance';
cfg.channel = {'PSG_F3','PSG_F4','PSG_C3','PSG_C4','PSG_O1','PSG_O2'};
cfg.neighbourdist = 0.4;
neighbours = ft_prepare_neighbours(cfg, data_filtered);

cfg = [];
cfg.badchannel     = badchannel;
cfg.method         = 'nearest';
cfg.neighbours     = neighbours;
data_interpolation = ft_channelrepair(cfg,data_filtered);

%% 10. ICA

%% 11. Reject component

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

