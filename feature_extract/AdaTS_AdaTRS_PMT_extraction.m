% Extract the adaptive scattering features
clear all; clc; tic
addpath(genpath('../../ScatteringTransformPTR/')) % dataset directory
run 'addpath_scatnet.m' % Scat code

fid=fopen('file_names.txt'); 
tline = fgetl(fid);
file_names = []; k=1;
while ischar(tline)
    file_names{k} = tline; 
    k = k+1;
    tline = fgetl(fid);
end
fclose(fid);

%% parametres
T = 2^15;   
Q = [16, 4];
minModuRate = 0; maxModuRate = 100; % modulation range, in Hz
Nbands = 7; % total number of frequency bands decomposed

tm_filt_opt.filter_type = 'morlet_1d';
tm_filt_opt.Q = Q(1); J_temp = T_to_J(T,tm_filt_opt);
tm_filt_opt.Q = Q(2); J_adapt = T_to_J(T,tm_filt_opt);
J = [J_temp, J_adapt];

tm_scat_opt.M = 1;
tm_scat_opt.oversampling = 2;
freq_filt_opt.filter_type = 'morlet_1d';
freq_filt_opt.Q = 1;
freq_scat_opt.M = 1;

adapt_options.T = T;
adapt_options.oversampling = tm_scat_opt.oversampling;
adapt_options.Nbands = Nbands;

%% extract features for each file
fileFeatures_time = []; fileFeatures_timerate = [];
for k=1:length(file_names)
    [x,fs] = audioread(file_names{k});
    x = mean(x,2);
    
    % extracted F0 for full file
    f0_traject = load('F0_trajectory_C2C8_hop128.mat', ['file' num2str(k-1)]);
    f0_traject = f0_traject.(['file' num2str(k-1)]); 
    f0_traject = f0_traject';
    hop = 128/44100;
    f0_traject(isnan(f0_traject))=0;
    % average f0 per T
    averT = round(T/2^(tm_scat_opt.oversampling)/(hop*fs));
    f0_aver = median(reshape(f0_traject(1:end-mod(size(f0_traject,1),averT)), averT, []));
    f0_aver = f0_aver';  % frequency of f0
    
    % find corresponding scales for the f0 trajectory   
    tm_filt_opt.Q = Q(1); tm_filt_opt.J = J(1);
    [Wop_tm, filters] = wavelet_factory_1d(length(x), tm_filt_opt, tm_scat_opt);
    acoustic_freqcenter = round(filters{1, 1}.psi.meta.center/3.14/2*44100);
    [S, U] = scat(x, Wop_tm);  
    clear Wop_tm filters
    
    % adapt scat
    tm_filt_opt.Q = Q(2); tm_filt_opt.J = J(2);
    [Wop_tm, filters] = wavelet_factory_1d_adapt(T, tm_filt_opt, tm_scat_opt);
    [val, pos] = find(U{1, 2}.meta.bandwidth < min(filters{1, 1}.psi.meta.center));
    maxDecmpIdx = length(U{1, 2}.meta.bandwidth) - length(pos); % note that here is len
    adapt_options.maxDecmpIdx = maxDecmpIdx;

    % specific modulation rate range
    modulation_freqcenter = round(filters{1, 1}.psi.meta.center/3.14/2*44100);
    modulation_freqcenter(modulation_freqcenter>maxModuRate) = [];
    moduIdx_high = length(round(filters{1, 1}.psi.meta.center)) - ... 
                    length(modulation_freqcenter)+1;  % start from high freq but low idx
    modulation_freqcenter(modulation_freqcenter<minModuRate) = []; 
    moduIdx_low = moduIdx_high + length(modulation_freqcenter) -1; 
    adapt_options.moduIdx = [moduIdx_high, moduIdx_low]; % e.g. [high, low]=[63, 87]
    clear filters
    
    % decomposition trajectory = cloest to 
    firstOrderCoeff = [S{2}.signal{:}].';
    % pad into same no. frames as firstOrderCoeff
    f0_aver(size(firstOrderCoeff,2)) = 0;
    for ii=1:size(firstOrderCoeff,2)  % get the dominant band trajectory
       [minValue, domIdx(ii)] = min(abs(acoustic_freqcenter - f0_aver(ii)));
       domIdx(ii) = max(domIdx(ii));
    end
    % interpolate first, then smooth
    domIdx(domIdx>=maxDecmpIdx) = NaN;
    InterTemp = 1:length(domIdx);
    domIdx(isnan(domIdx)) = interp1(InterTemp(~isnan(domIdx)),...
        domIdx(~isnan(domIdx)),InterTemp(isnan(domIdx))) ;
    domIdx(isnan(domIdx)) = maxDecmpIdx; domIdx = round(domIdx);
    
    % expanded bands with freq scat
    moduScaleNumKept = moduIdx_low-moduIdx_high+1;  
    Nfreq = 2^nextpow2(moduScaleNumKept);   % here is different
    freq_filt_opt.J = T_to_J(Nfreq,freq_filt_opt);
    Wop_fr = wavelet_factory_1d_adapt(Nfreq, freq_filt_opt, freq_scat_opt);
    adapt_options.freqScaleNum = freq_filt_opt.J;
    adapt_options.fr_oversampling = 1;
    
    S_adapt_time = NaN*ones(moduScaleNumKept*Nbands, length(domIdx)); 
    S_adapt_timerate = [];
    for jj=1:Nbands
        adapt_options.domIdx = domIdx+(Nbands-1)/2+1-jj;
        S_adapt_time((jj-1)*moduScaleNumKept+1:jj*moduScaleNumKept,:) = ... 
            adapt_time_scat(U{2},S,Wop_tm, adapt_options);
        S_adapt_timerate = [S_adapt_timerate; ...
            freq_scat_SQ(S_adapt_time((jj-1)*moduScaleNumKept+1:jj*... 
            moduScaleNumKept,:), Wop_fr)]; 
    end
    
    fileFeatures_time{k} = S_adapt_time;
    fileFeatures_timerate{k} =  S_adapt_timerate;
    clear S_adapt_time S_adapt_timerate Wop_tm Wop_fr S U domIdx ii jj ...
        firstOrderCoeff filters modulation_freqcenter acoustic_freqcenter ...
        f0_traject f0_aver InterTemp

end
cal_time = toc
save('AdaTS_AdaTRS_PMT_feature.mat','fileFeatures_time', 'fileFeatures_timerate','cal_time');
