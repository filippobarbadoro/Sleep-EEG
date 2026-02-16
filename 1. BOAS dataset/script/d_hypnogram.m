%% Hypnogram

cd '/Users/filippobarbadoro/Desktop/Matlab/BOAS dataset/script'

%% Creation of random data

data_rand = {'w','r','1','2','3'};
n_epochs = round(size(stimes,2)/30); % 5486 secondi è il totale della registrazione (stimes), diviso 30s (epoca) = 183 circa (arrotondato con round)
stage_file = data_rand(randi(numel(data_rand), 1, n_epochs));

% assigning a number to each value of the staging file
stage_num = zeros(size(stage_file));
for i = 1:length(stage_file)
    switch stage_file{i}
        case 'w', stage_num(i) = 4;
        case 'r', stage_num(i) = 3;
        case '1', stage_num(i) = 2;
        case '2', stage_num(i) = 1;
        case '3', stage_num(i) = 0;
    end
end

% Time
t_epochs = (0:(n_epochs-1))*30;

% Plot
figure;
stairs(t_epochs/3600, stage_num, 'LineWidth', 1); %/3600 per plottare in h
yticks(0:4);
yticklabels({'N3','N2','N1','REM','WAKE'});
ylim([-0.5 4.5]);
xlim([0 t_epoche(end)/3600]);
ylabel('Sleep stage');
xlabel('Time')
grid on;
