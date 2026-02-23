%% Import and preprocessing
clear all
close all
clc

cd '/Users/filippobarbadoro/MATLAB_local/Script/3. BOAS dataset/BOAS_script'

%% ----- Import and visualization of raw data in edf format -----
% Import and read edf file
cfg             = [];
cfg.dataset     = '/Users/filippobarbadoro/MATLAB_local/Data/3. BOAS dataset/sub-2_task-Sleep_acq-psg_eeg.edf';
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

%  ------ Resampling ------
% not needed for this data

%%  ------ Filtering ------

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

%% Re-referencing
% not needed for this data

%% 8. Epoching in 30s segment

cfg             = [];
cfg.length      = 30; %seconds
cfg.overlap     = 0;
data_epoched    = ft_redefinetrial(cfg,data_eeg_filt);

%NOTE: remember that if I decide to segment the data to remove artifacts etc, 
% it must then be recomposed because the multitaper needs continuous data!!

%% Changing the channel's name
% Since we will use a fieldtrip layout which contains classical name (e.g.,
% F3 instead of PSG_F3), I change the labels here

data_epoched.label = {'F3'; 'F4'; 'C3'; 'C4'; 'O1'; 'O2'};

%% 9. Atypical artifact rejection (databrowser)
% https://www.fieldtriptoolbox.org/tutorial/preproc/ica_artifact_cleaning/#rejecting-atypical-artifacts

cfg                 = [];
cfg.continuous      = 'yes'; % this can also be used on trial-based data to paste them together
cfg.blocksize       = 60;
cfg.plotevents      = 'no';
cfg.preproc.demean  = 'yes';
cfg.layout          = 'CTF151.lay';% I dont think this layout fit the PSG data with 6 channels 'elec1020.lay' is for 10/20 system
cfg = ft_databrowser(cfg, data_filtered);

% remember the time of the artifacts
cfg_artfctdef = cfg.artfctdef;

%% 9. Atypical artifact rejection (rejectvisual)

cfg             = [];
cfg.method      = 'summary';
cfg.keepchannel = 'yes';
cfg.keeptrial   = 'nan';
cfg.channel     = {'PSG_F3' 'PSG_F4' 'PSG_C3' 'PSG_C4' 'PSG_O1' 'PSG_O2'};
cfg.layout      = 'CTF151.lay'; % as above
data_epoched_clean = ft_rejectvisual(cfg, data_epoched);

%% Visualization of continuous data in 30s epochs
cfg = [];
cfg.continuous ='yes';
cfg.viewmode = 'vertical';
cfg.blocksize = 30; % seconds
ft_databrowser(cfg,data_epoched_clean);

%% 10. Interpolation of bad channels (before or after ICA?)
badchannel = {'PSG_C4'};

cfg                 = [];
cfg.method          = 'distance';
cfg.channel         = {'PSG_F3','PSG_F4','PSG_C3','PSG_C4','PSG_O1','PSG_O2'};
cfg.neighbourdist   = 0.4;
neighbours          = ft_prepare_neighbours(cfg, data_filtered);

cfg                = [];
cfg.badchannel     = badchannel;
cfg.method         = 'nearest';
cfg.neighbours     = neighbours;
data_interpolation = ft_channelrepair(cfg,data_filtered);

%% 10. ICA
cfg     = [];
cfg.method = 'runica';
comp = ft_componentanalysis(cfg, data_epoched);

% plot component - spatial topography
figure
cfg = [];
cfg.component = 1:20;
cfg.layout = 'elec1020.lay';
cfg.comment = 'no';
ft_topoplotIC(cfg, comp)

saveas(gcf, '/Users/filippobarbadoro/MATLAB_local/Script/3. BOAS dataset/BOAS_figure/ICA_topomap.png');

% plot component - time course
cfg = [];
cfg.layout = 'elec1020.lay';
cfg.viewmode = 'component';
ft_databrowser(cfg, comp)

saveas(gcf, '/Users/filippobarbadoro/MATLAB_local/Script/3. BOAS dataset/BOAS_figure/ICA_timecourse.png');

%% 11. Reject component
cfg = [];
cfg.component = [1 2];
data = ft_rejectcomponent(cfg, comp, data_epoched);