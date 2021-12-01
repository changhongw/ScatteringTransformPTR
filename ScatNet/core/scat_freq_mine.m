% SCAT_FREQ Computes scattering transform along first frequency
%
% Usage
%    [S, U] = scat_freq(X, Wop)
%
% Input
%    X (cell): A cell array of scattering layers with, such as the output S
%       of the SCAT function.
%
% Output
%    S, U (cell): The scattering and wavelet modulus coefficients, respective-
%       ly, of the input representation X, transformed along first frequency
%       lambda1.
%
% Description
%    For each order of the input representation X, the coefficients are group-
%    ed according to higher-order frequencies lambda2, lambda3, with each
%    group ordered along lambda1, obtained by calling CONCATENATE_FREQ. Then 
%    the scattering transform defined by Wop by calling SCAT is applied along
%    this lambda1 axis. The results are then retransformed, separating the
%    different first frequencies lambda1 into different coefficients, as in 
%    the original representation.
%
%    The meta fields of the frequential scattering transform are stored in the
%    output with the prefix 'fr_', so 'order' becomes 'fr_order', 'j' becomes
%    'fr_j', and so on.
%
% See also 
%    SCAT, WAVELET_FACTORY_1D, CONCATENATE_FREQ

function [S, U] = scat_freq(X, Wop)
	% Group all the coefficients into tables along lambda1 and t. For order 1,
	% this gives a single table containing all first-order coefficients, while
	% for order 2, each lambda2 corresponds to one table containing the 
	% second-order coefficients for that lambda2 and the different lambda1s,
	% and so on.
    
% 	Y = concatenate_freq(X);
% 	
% 	S = {};
% 	U = {};
% 	
% 	for m = 0:length(X)-1
% 		r = 1;
% 		
% 		S{m+1} = {};
% 		U{m+1} = {};
% 		
% 		for k = 1:length(Y{m+1}.signal)
% 			% Here each signal is a table of dimension PxNxK, where P is the
% 			% number of frequencies lambda1, N is the number of time samples,
% 			% and K is the number of signals.
% 			signal = Y{m+1}.signal{k};
% 			
% 			% Get the table dimension, if K = 1, MATLAB will not include it in
% 			% the size.
% 			sz_orig = size(signal);
% 			sz_orig = [sz_orig ones(1,3-length(sz_orig))];
% 			
% 			% Compute the corresponding columns in the meta fields.
% 			ind = r:r+size(signal,1)-1;
% 			
% 			% Reshape so that each time sample and each signal index are
% 			% processed separately by putting them in the third dimension,
% 			% giving a table of size Px1xNK.
% 			signal = reshape(signal,[sz_orig(1) 1 prod(sz_orig(2:3))]);
% 			
% 			if m > 0
% 				% If we're not in the zeroth order, we can (and want to)
% 				% compute the scattering transform along lambda1, which is now
% 				% the first dimension of signal.

%% -------------- add ---------------
signal = reshape(X,[size(X,1) 1 size(X,2)]);

				[S_fr,U_fr] = scat(signal, Wop);
%                 S_fr = log_scat(renorm_scat(scat(signal, Wop)));
                
%% -------------- add ---------------
Conca = [];
for kk=1:length(S_fr{1, 2}.signal)
    Y{kk} = reshape(S_fr{1, 2}.signal{kk},[size(S_fr{1, 2}.signal{1},1) ...
    size(S_fr{1, 2}.signal{1},3) 1]);
    Conca = [Conca;Y{kk}];
end
subplot(413)
% imagesc(Conca(1:size(S_fr{1, 2}.signal{1},1),:));
imagesc(Conca);
colorbar
title('Frequential scat along dominant 2nd-order modulation','FontWeight','normal')

%%
% hold on
% 
% addpath(genpath('./CBFperiodicDB/'))
% fid = fopen('shortFT_withContext.csv');
% onoffReadPiece = textscan(fid,'%f,%s');
% fclose(fid);
% 
% numFT = length(onoffReadPiece{1,1})/2;
% for j=1:numFT
%     truthSegs(j,1)=round(onoffReadPiece{1,1}(2*j-1)*44100/4096);   % onoff [start-time,duration,end-time,up-or-down]
%     truthSegs(j,2)=round(onoffReadPiece{1,1}(2*j)*44100/4096);
%     area(truthSegs(j,1):truthSegs(j,2),...
%         5*ones(length(truthSegs(j,1):truthSegs(j,2)),1),'FaceColor','g','EdgeColor',[1 1 1]); hold on
% end
% xlim([0 truthSegs(j,2)])
% hold off

% subplot(414)
% eventDetect = sum(Conca,1);
eventDetect = sum(Conca(2:size(S_fr{1, 2}.signal{1}-1,1),:),1);
eventDetect = smooth(eventDetect,2);
% plot(eventDetect)
% xlim([0 length(eventDetect)])
% title('FT events','FontWeight','normal')
% colorbar


subplot(414)
dataset_new = dataset(eventDetect > 5.3);
area(dataset_new,'EdgeColor',[1 1 1]); hold on
title('FT enents','FontWeight','normal')
colorbar

% addpath(genpath('./CBFperiodicDB/'))
fid = fopen('1_MengXiaojie_PieceG_JM.csv');
onoffReadPiece = textscan(fid,'%f,%s');
fclose(fid);

numFT = length(onoffReadPiece{1,1})/2;
for j=1:numFT
    truthSegs(j,1)=round(onoffReadPiece{1,1}(2*j-1)*44100/8192*4);   % onoff [start-time,duration,end-time,up-or-down]
    truthSegs(j,2)=round(onoffReadPiece{1,1}(2*j)*44100/8192*4);
%     truthSegs(j,1)=onoffReadPiece{1,1}(2*j-1);   % onoff [start-time,duration,end-time,up-or-down]
%     truthSegs(j,2)=onoffReadPiece{1,1}(2*j);
    area(truthSegs(j,1):truthSegs(j,2),...
        0.5*ones(length(truthSegs(j,1):truthSegs(j,2)),1),'FaceColor','g','EdgeColor',[1 1 1]); hold on
end
xlim([0 length(dataset_new)])
legend('Detected','Truth');
print(gcf,'-depsc2','vibratoEvents.eps');

%% accuracy
% P R F

Z = reshape(S_fr{1, 1}.signal{1},[size(S_fr{1, 1}.signal{1},1) ...
    size(S_fr{1, 1}.signal{1},3) 1]);
imagesc(Z);
% -----------------------------------


%%
% 				% Needed for the case of U. These are not initialized by scat.
% 				if ~isfield(U_fr{1}.meta,'bandwidth')
% 					U_fr{1}.meta.bandwidth = 2*pi;
% 				end
% 				if ~isfield(U_fr{1}.meta,'resolution')
% 					U_fr{1}.meta.resolution = 0;
% 				end
% 			else
% 				% If we're in the zeroth order, just copy the signal.
% 				S_fr = {};
% 				
% 				S_fr{1}.signal = {signal};
% 				S_fr{1}.meta.bandwidth = 2*pi;
% 				S_fr{1}.meta.resolution = 0;
% 				S_fr{1}.meta.j = -1;
% 				
% 				U_fr = {};
% 
% 				U_fr{1}.signal = {signal};
% 				U_fr{1}.meta.bandwidth = 2*pi;
% 				U_fr{1}.meta.resolution = 0;
% 				U_fr{1}.meta.j = -1;
% 			end
% 			
% 			if isempty(S{m+1})
% 				% If we have no signals so far, initialize S, the output.
% 				for mp = 0:length(S_fr)-1
% 					S{m+1}{mp+1}.signal = {};	% Scattering coefficients
% 					U{m+1}{mp+1}.signal = {};	% Wavelet modulus coefficients
% 					rp(mp+1) = 1;				% Index for S{m+1}{mp+1}
% 					rb(mp+1) = 1;				% Index for U{m+1}{mp+1}
% 				end
% 			end
% 			
% 			for mp = 0:length(S_fr)-1
% 				% For each order of the frequential scattering.
% 				for kp = 1:length(S_fr{mp+1}.signal)
% 					% For each of the frequential scattering coefficients.
% 					for t = 0:1
% 						% Do this for both S and U, same thing.
% 						if t == 0
% 							X_fr = S_fr;
% 							X = S;
% 							rc = rp;
% 						else
% 							X_fr = U_fr;
% 							X = U;
% 							rc = rb;
% 						end
% 					
% 						% Extract all the signals of this path. Again, note
% 						% that nsignal is a table of the size P'x1xNK, where
% 						% P' is the number of freqencies after downsamping.
% 						nsignal = X_fr{mp+1}.signal{kp};
% 					
% 						% Retrieve P' = j1_count and downsampling factor.
% 						j1_count = size(nsignal,1);
% 						ds = X_fr{mp+1}.meta.resolution(kp);
% 					
% 						% Which of the indices from the original range ind
% 						% have been kept after subsampling.
% 						inds = ind(1:2^ds:end);
% 					
% 						% Restore the P'xNxK dimension of the table.
% 						nsignal = reshape(nsignal,[j1_count sz_orig(2:3)]);
% 					
% 						for j1 = 1:j1_count
% 							% For each of the remaining frequencies lambda1,
% 							% copy the signal and its associated meta fields.
% 							X{m+1}{mp+1}.signal{rc(mp+1)} = ...
% 								reshape(nsignal(j1,:,:), ...
% 									[sz_orig(2) 1 sz_orig(3)]);
% 							X{m+1}{mp+1}.meta.bandwidth(1,rc(mp+1)) = ...
% 								Y{m+1}.meta.bandwidth(inds(j1));
% 							X{m+1}{mp+1}.meta.resolution(1,rc(mp+1)) = ...
% 								Y{m+1}.meta.resolution(inds(j1));
% 							X{m+1}{mp+1}.meta.j(:,rc(mp+1)) = ...
% 								Y{m+1}.meta.j(:,inds(j1));
% 							X{m+1}{mp+1}.meta.fr_bandwidth(1,rc(mp+1)) = ...
% 								X_fr{mp+1}.meta.bandwidth(kp);
% 							X{m+1}{mp+1}.meta.fr_resolution(1,rc(mp+1)) = ...
% 								X_fr{mp+1}.meta.resolution(kp);
% 							X{m+1}{mp+1}.meta.fr_j(:,rc(mp+1)) = ...
% 								X_fr{mp+1}.meta.j(:,kp);
% 							rc(mp+1) = rc(mp+1)+1;
% 						end
% 						
% 						% Write the results into S or U, depending.
% 						if t == 0
% 							S_fr = X_fr;
% 							S = X;
% 							rp = rc;
% 						else
% 							U_fr = X_fr;
% 							U = X;
% 							rb = rc;
% 						end
% 					end
% 				end
% 			end
% 			
% 			r = r+size(signal,1);
% 		end
% 	end
% 	
% 	% For each order of temporal scattering, we have a cell array containing 
% 	% the different orders of frequential scattering, so we need to flatten
% 	% the latter to obtain the regular scattering transform format.
% 	for m = 0:length(S)-1
% 		temp = flatten_scat(S{m+1});
% 		temp = temp{1};
% 		temp.meta.fr_order = temp.meta.order;
% 		temp.meta = rmfield(temp.meta,'order');
% 		S{m+1} = temp;
% 		
% 		temp = flatten_scat(U{m+1});
% 		temp = temp{1};
% 		temp.meta.fr_order = temp.meta.order;
% 		temp.meta = rmfield(temp.meta,'order');
% 		U{m+1} = temp;
% 	end
end
