function [Wop, filters] = ...
    freqAverage_wavelet_factory_1d(N,time_filt_opt,freq_filt_opt,scat_opt)

	time_filters = filter_bank(N, time_filt_opt);
	N_freq = 2^nextpow2(numel(time_filters{1}.psi.filter));
	freq_filters = filter_bank(N_freq, freq_filt_opt);
	scat_opt1 = scat_opt;
	scat_opt1.phi_renormalize = 0;
    filters = [time_filters, freq_filters];
    
    Wop = cell(1,scat_opt.M+1);
	Wop{1} = @(X)(wavelet_layer_1d(X, time_filters{1}, scat_opt1));
	Wop{2} = @(X)(wavelet_layer_1d(X, time_filters{2}, scat_opt1));
	
	for m = scat_opt.M
		freq_filt_ind = min(numel(freq_filters), m+1);
		Wop{1+m} = @(X)( ...
            separable_wavelet_layer_1d(X, ...
            {freq_filters{freq_filt_ind}}, ...
            scat_opt));
    end
end
