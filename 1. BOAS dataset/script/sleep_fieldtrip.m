%import and read edf file
cfg             = [];
cfg.dataset     = 'sub-1_task-Sleep_acq-psg_eeg.edf';
cfg.continuous  = 'yes';
cfg.channel     = 'all';
data_raw            = ft_preprocessing(cfg);

%visualization continuous data in 30s epochs
cfg = [];
cfg.continuous ='yes';
cfg.viewmode = 'vertical';
cfg.blocksize = 30;
ft_databrowser(cfg,data_raw);

%epoching in 30s segment
cfg             = [];
cfg.length      = 30; %seconds
cfg.overlap     = 0;
data_epoched    = ft_redefinetrial(cfg,data_raw);

%% DETECTION OF WAKE PERIODS:
% 1. filtering EMG channels to detect movement artifact
% 2. applying Hilbert envelope and smoothing
% 3. detecting Eye movements in EOG activity
% 4. excluding epochs with artifacts
%
% 1. EMG artifact rejection
cfg                              = [];
cfg.continuous                   = 'yes';
cfg.artfctdef.muscle.interactive = 'yes';

% channel selection, cutoff and padding
cfg.artfctdef.muscle.channel     = 'PSG_EMG';
cfg.artfctdef.muscle.cutoff      = 4; % z-value at which to threshold (default = 4)
cfg.artfctdef.muscle.trlpadding  = 0;

% 2. Hilbert envelope and smoothing
% algorithmic parameters
cfg.artfctdef.muscle.bpfilter    = 'yes';
cfg.artfctdef.muscle.bpfreq      = [20 45];
cfg.artfctdef.muscle.bpfiltord   = 4;
cfg.artfctdef.muscle.bpfilttype  = 'but';
cfg.artfctdef.muscle.hilbert     = 'yes';
cfg.artfctdef.muscle.boxcar      = 0.2;

% conservative rejection intervals around EMG events
cfg.artfctdef.muscle.pretim  = 10; % pre-artifact rejection-interval in seconds
cfg.artfctdef.muscle.psttim  = 10; % post-artifact rejection-interval in seconds

% feedback, explore the right threshold for all data (one trial, th=4 z-values)
cfg = ft_artifact_muscle(cfg, data_raw);

% make a copy of the samples where the EMG artifacts start and end, this is needed further down
EMG_detected = cfg.artfctdef.muscle.artifact;

%showing detected artifact
cfg_art_browse             = cfg;
cfg_art_browse.continuous  = 'yes';
cfg_art_browse.viewmode    = 'vertical';
cfg_art_browse.blocksize   = 30*60; % view the data in 10-minute blocks
ft_databrowser(cfg_art_browse, data_raw);

% 3. EOG artifact rejection
%detecting eye movement
cfg = [];
cfg.continuous                = 'yes';
cfg.artfctdef.eog.interactive = 'yes';

% channel selection, cutoff and padding
cfg.artfctdef.eog.channel     = 'PSG_EOG';
cfg.artfctdef.eog.cutoff      = 2.5; % z-value at which to threshold (default = 4)
cfg.artfctdef.eog.trlpadding  = 0;
cfg.artfctdef.eog.boxcar      = 10;

% conservative rejection intervals around EOG events
cfg.artfctdef.eog.pretim      = 10; % pre-artifact rejection-interval in seconds
cfg.artfctdef.eog.psttim      = 10; % post-artifact rejection-interval in seconds

cfg = ft_artifact_eog(cfg, data_raw);

% make a copy of the samples where the EOG artifacts start and end, this is needed further down
EOG_detected = cfg.artfctdef.eog.artifact;

% 4. Excluding epochs with artifacts
% replace the artifactual segments with zero
  cfg = [];
  cfg.artfctdef.muscle.artifact = EMG_detected;
  cfg.artfctdef.eog.artifact    = EOG_detected;
  cfg.artfctdef.reject          = 'value';
  cfg.artfctdef.value           = 0;
  data_continuous_clean = ft_rejectartifact(cfg, data_raw);
  data_epoched_clean    = ft_rejectartifact(cfg, data_epoched);

% 2 hours blocks after excluding EMG and EOG artifacts
cfg             = [];
cfg.continuous  = 'yes';
cfg.viewmode    = 'vertical';
cfg.blocksize   = 60*60*2; % view the data in blocks
ft_databrowser(cfg, data_continuous_clean);

%% Estimating frequency-representation over sleep
% define the EEG frequency bands of interest
freq_bands = [
  0.5  4    % slow-wave band actity
  4    8    % theta band actity
  8   11    % alpha band actity
  11  16    % spindle band actity
  ];

% periodogram 30-s
cfg = [];
cfg.output        = 'pow';
cfg.channel       = {'PSG_F3' 'PSG_F4' 'PSG_C3' 'PSG_C4' 'PSG_O1' 'PSG_O2'};
cfg.method        = 'mtmfft';
cfg.taper         = 'hanning';
cfg.foi           = 0.5:0.5:16; % in 0.5 Hz steps
cfg.keeptrials    = 'yes';
freq_epoched = ft_freqanalysis(cfg, data_epoched_clean);

begsample = data_epoched_clean.sampleinfo(:,1);
endsample = data_epoched_clean.sampleinfo(:,2);
time      = ((begsample+endsample)/2) / data_epoched_clean.fsample;

freq_continuous           = freq_epoched;
freq_continuous.powspctrm = permute(freq_epoched.powspctrm, [2, 3, 1]);
freq_continuous.dimord    = 'chan_freq_time'; % it used to be 'rpt_chan_freq'
freq_continuous.time      = time;             % add the description of the time dimension

% time-frequency for whole night
figure
cfg                = [];
cfg.baseline       = [min(freq_continuous.time) max(freq_continuous.time)];
cfg.baselinetype   = 'normchange';
cfg.zlim           = [-0.5 0.5];
ft_singleplotTFR(cfg, freq_continuous);


% time-frequency spectra for each frequency bands
cfg                     = [];
cfg.frequency           = freq_bands(1,:);
cfg.avgoverfreq         = 'yes';
freq_continuous_swa     = ft_selectdata(cfg, freq_continuous);

cfg                     = [];
cfg.frequency           = freq_bands(2,:);
cfg.avgoverfreq         = 'yes';
freq_continuous_theta   = ft_selectdata(cfg, freq_continuous);

cfg                     = [];
cfg.frequency           = freq_bands(3,:);
cfg.avgoverfreq         = 'yes';
freq_continuous_alpha   = ft_selectdata(cfg, freq_continuous);

cfg                     = [];
cfg.frequency           = freq_bands(4,:);
cfg.avgoverfreq         = 'yes';
freq_continuous_spindle = ft_selectdata(cfg, freq_continuous);

% Concatenating the average frequency band signals to one data trial and
% combine channels with each one frequency band to a signle data structure
data_continuous_swa                  = [];
data_continuous_swa.label            = {'swa'};
data_continuous_swa.time{1}          = freq_continuous_swa.time;
data_continuous_swa.trial{1}         = squeeze(freq_continuous_swa.powspctrm)';

data_continuous_swa_spindle          = [];
data_continuous_swa_spindle.label    = {'theta'};
data_continuous_swa_spindle.time{1}  = freq_continuous_theta.time;
data_continuous_swa_spindle.trial{1} = squeeze(freq_continuous_theta.powspctrm)';

data_continuous_alpha                = [];
data_continuous_alpha.label          = {'alpha'};
data_continuous_alpha.time{1}        = freq_continuous_alpha.time;
data_continuous_alpha.trial{1}       = squeeze(freq_continuous_alpha.powspctrm)';

data_continuous_spindle              = [];
data_continuous_spindle.label        = {'spindle'};
data_continuous_spindle.time{1}      = freq_continuous_spindle.time;
data_continuous_spindle.trial{1}     = squeeze(freq_continuous_spindle.powspctrm)';

cfg = [];
data_continuous_perband = ft_appenddata(cfg, ...
data_continuous_swa, ...
data_continuous_swa_spindle, ...
data_continuous_alpha, ...
data_continuous_spindle);

% Dividing the signal by SD and applying scale factor of 100
cfg        = [];
cfg.scale  = 100; % in percent
cfg.demean = 'no';
data_continuous_perband = ft_channelnormalise(cfg, data_continuous_perband);

% Smoothing filter 300s boxcar
cfg        = [];
cfg.boxcar = 300;
data_continuous_perband = ft_preprocessing(cfg, data_continuous_perband);

% Viewing the whole sleep data in frequency band power
cfg             = [];
cfg.continuous  = 'yes';
cfg.viewmode    = 'vertical';
cfg.blocksize   = 60*60*2; %view the whole data in blocks
ft_databrowser(cfg, data_continuous_perband);

%% Identify N-REM sleep
% Identifying epochs with high spindles or SW activity:
% creating a new channel from normalized signal of SWS and spindles
montage_sum          = [];
montage_sum.labelold = {'swa', 'theta', 'alpha', 'spindle'};
montage_sum.labelnew = {'swa', 'theta', 'alpha', 'spindle', 'swa+spindle'};
montage_sum.tra      = [
  1 0 0 0
  0 1 0 0
  0 0 1 0
  0 0 0 1
  1 0 0 1   % the sum of two channels
  ];

cfg = [];
cfg.montage = montage_sum;
data_continuous_perband_sum = ft_preprocessing(cfg, data_continuous_perband);

% Visualization of sleep data in frequency band power, including spindles
% and SW activity power
cfg = [];
cfg.continuous   = 'yes';
cfg.viewmode    = 'vertical';
cfg.blocksize   = 60*60*2; % view the whole data in blocks
ft_databrowser(cfg, data_continuous_perband_sum);

% Identifying N-REM epochs, looking for epochs with SWA+spindles above
% threshold (average of signal)
cfg = [];
cfg.artfctdef.threshold.channel   = {'swa+spindle'};
cfg.artfctdef.threshold.bpfilter  = 'no';
cfg.artfctdef.threshold.max       = nanmean(data_continuous_perband_sum.trial{1}(5,:)); % mean of the 'swa+spindle' channel
cfg = ft_artifact_threshold(cfg, data_continuous_perband_sum);

% keep the begin and end sample of each "artifact", we need it later
nonREM_detected = cfg.artfctdef.threshold.artifact;

%% Hypnogram
hypnogram = -1 * ones(1,numel(data_epoched.trial)); %initalize the vector with -1 values

%REM defined by the detected EOG activity
for i=1:size(EOG_detected,1)
    start_sample = EOG_detected(i,1);
    end_sample   = EOG_detected(i,2);
    start_epoch  = ceil((start_sample)/(30*128));
    end_epoch    = ceil((  end_sample)/(30*128));
    hypnogram(start_epoch:end_epoch) = 5; % REM
end

%Non-REM defined by EMG
for i=1:size(nonREM_detected,1)
    start_epoch = nonREM_detected(i,1);
    end_epoch   = nonREM_detected(i,2);
    hypnogram(start_epoch:end_epoch) = 2.5; % it could be any of 1, 2, 3 or 4
end

%Epochs with detected EMG artifacts are now again (re)labled as Wake
for i=1:size(EMG_detected,1)
    start_sample = EMG_detected(i,1);
    end_sample   = EMG_detected(i,2);
    start_epoch  = ceil((start_sample)/(30*128));
    end_epoch    = ceil((  end_sample)/(30*128));
    hypnogram(start_epoch:end_epoch) = 0; % wake
end

% Loading a prescored hypnogram as reference
% Wake-0, Stage-1, Stage-2, Stage-3, Stage-4, REM-5, Movement Time-0.5
prescored = load([datapath filesep subjectdata.subjectdir filesep subjectdata.hypnogramfile])';

figure
plot([prescored-0.05; hypnogram+0.05]', 'LineWidth', 1); % shift them a little bit
legend({'prescored', 'hypnogram'})
ylim([-1.1 5.1]);

lab = yticklabels; %lab = get(gca,'YTickLabel'); %prior to MATLAB 2016b use this

lab(strcmp(lab, '0'))  = {'wake'};
lab(strcmp(lab, '1'))  = {'S1'};
lab(strcmp(lab, '2'))  = {'S2'};
lab(strcmp(lab, '3'))  = {'SWS'};
lab(strcmp(lab, '4'))  = {'SWS'};
lab(strcmp(lab, '5'))  = {'REM'};
lab(strcmp(lab, '-1')) = {'?'};
yticklabels(lab);