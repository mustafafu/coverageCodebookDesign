%% Reading channels for every UE-BS pair
% Reads and creates channels for BS, UE pair. output is all_channels where
% its a cell array size numBS by numUE and each element is a vector(or
% matrix) corresponding to channel matrix of MISO or MIMO system. The array
% size can be changed inside the create_all_channel_matrices script for now
% it is set to 64 transmit antennas in ULA configuration.
run rayTracingToChannels.m;
PLOT_SCENARIO = true;
PLOT_INDIVUDUAL = false;
isCDFPlot = true;
isWrite = false;
CODEBOOKSIZE = 64;


%% Maximum Ratio Combining
% Here we run the maximum ratio combining beamforming which is a case where
% a beamforming codebook is generated for every UE, or in other words
% infite codebook size.
% Now let's plot the geometry, for every UE:
%
% # For every BS, get the channel matrix, use a matched filter with norm 1 to
% get the absolute maximum achievable gain.
[nBs, nRx] = size(all_channels);
epsilon = 1e-10;
[best_bs_per_ue,best_pow_ue_got] = matched_filter(all_channels,rx_coordinates,BS_loc_mat,epsilon);
for ii=1:nBs
    this_ues = (best_bs_per_ue==ii);
    bs_powers = best_pow_ue_got(this_ues);
    ue_x = rx_coordinates(this_ues,1);
    ue_y = rx_coordinates(this_ues,2);
    if PLOT_SCENARIO
        bs_powersTMP = bs_powers/max(bs_powers);
        scatter(ue_x,ue_y,[],bs_powersTMP,"filled")
        hold on;
    end
end

%% Run Batch Scenario
numAntennas = num_tx_array_element;
% ch_threshold_vec = [1e-5,1e-4];
% ch_threshold_vec = logspace(-5,-4,10);
% codebook_size_vec = 2.^(0:1:log2(numAntennas));
ch_threshold_vec = 1e-4;
codebook_size_vec = [32];
% Which BS to play with in this tutorial script.
whichBS = 3;
tic
for tIdx = 1:length(ch_threshold_vec)
    ch_threshold = ch_threshold_vec(tIdx);
    for cIdx = 1:length(codebook_size_vec)
        CODEBOOKSIZE = codebook_size_vec(cIdx);
        filtered_users = find(whichBS==best_bs_per_ue);
        selectedChannels = channel_matrices{whichBS}(filtered_users,:).';
        N = length(selectedChannels);
        
        % Taking norms instead of powers (norm squared)
        channel_norms = vecnorm(selectedChannels,2,1);
        good_users = find(channel_norms >= ch_threshold);
        channel_norms = channel_norms(good_users);
        selectedChannels = selectedChannels(:,good_users);
        N = length(selectedChannels);
        
        colVects = reshape(selectedChannels,size(selectedChannels,1),1,[]);
        rowVects = shiftdim(selectedChannels,-1);
        channel_corelations = pagemtimes(conj(colVects),rowVects);
        
        
        %% Eigen Iterative Codebook
        eig_codebook = zeros(size(selectedChannels,1));
        cw_idx = 1;
        served_users = zeros(1,size(selectedChannels,2));
        while cw_idx <= CODEBOOKSIZE
            remaining_users = find(served_users == 0);
            sum_ch_cors = zeros(size(selectedChannels,1));
            for ue_idx = 1:length(remaining_users)
                ue = remaining_users(ue_idx);
                Hmat =  selectedChannels(:,ue);
                sum_ch_cors = sum_ch_cors + conj(Hmat)*Hmat.';
            end
            [VV,DD] = eig(sum_ch_cors);
            [~, sorting_indices] = sort(diag(abs(DD)),'descend');
            best_codeword = VV(:,sorting_indices(1));
            eig_codebook(:,cw_idx) = best_codeword;
            cw_idx = cw_idx+1;
            served_indices = find(abs(selectedChannels.' * best_codeword)>=ch_threshold);
            served_users(served_indices)=1;
            %     disp(cw_idx)
            %     disp(sum(served_users))
        end
        val_matrix = abs(selectedChannels.' * eig_codebook);
        [eig_powers_iterative,~]=max(val_matrix,[],2);
        
        
        %% Baseline Eigenvector based codebook, using all the eigenvectors
        % corresponding to the largest C eigenvalues. C<- CODEBOOKSIZE.
        sum_ch_cors = sum(channel_corelations,3);
        [VV,DD] = eig(sum_ch_cors);
        [eigenvalues_sorted, sorting_indices] = sort(diag(abs(DD)),'descend');
        eig_codebook=VV(:,sorting_indices(1:min(size(VV,2),CODEBOOKSIZE)));
        val_matrix = abs(selectedChannels.' * eig_codebook);
        [eig_powers,~]=max(val_matrix,[],2);
        
        
        %% Receiver Channel-based Codebook Selection
        user_ch_codebook = zeros(size(selectedChannels,1));
        cw_idx = 1;
        served_users = zeros(1,size(selectedChannels,2));
        user_channels_as_beams = conj(selectedChannels)./vecnorm(selectedChannels);
        user_channel_gain_pairwise = abs(selectedChannels.'* user_channels_as_beams);
        while cw_idx <= CODEBOOKSIZE
            remaining_users = find(served_users == 0);
            [max_val,max_serving_idx] = max(sum(user_channel_gain_pairwise(remaining_users,:)>=ch_threshold,1));
            served_indices = find(user_channel_gain_pairwise(:,max_serving_idx)>=ch_threshold);
            served_users(served_indices) = 1;
            user_ch_codebook(:,cw_idx) = user_channels_as_beams(:,max_serving_idx);
            cw_idx = cw_idx+1;
%                 disp(cw_idx)
%                 disp(sum(served_users))
        end
        val_matrix = abs(selectedChannels.' * user_ch_codebook);
        [user_ch_powers,~]=max(val_matrix,[],2);
        
        
        
        %% Uniform (DFT) based Codebook%tic
        theta = pi/2; %we don't have elevation angle in ULA configuration.
        phi = linspace(0,pi,floor(CODEBOOKSIZE));
        [tt,pp] = meshgrid(theta,phi);
        corresponding_beam_angles = [tt(:).';pp(:).'];
        %Non-normalized beamforming
        beam_direction_vector =  [sin(tt(:).').*cos(pp(:).'); sin(tt(:).').* sin(pp(:).') ; cos(tt(:).')];
        antenna_beamforming_response = exp(-1j* 2 * pi * tx_array_loc_matrix * beam_direction_vector);
        %Normalizing the beams
        unif_codebook = antenna_beamforming_response./vecnorm(antenna_beamforming_response);
        unif_val_matrix = abs(selectedChannels.' * unif_codebook);
        [unif_powers,~]=max(unif_val_matrix,[],2);
        
        
        %% Lloyd's Algorithm
        num_epoch = 10;
        lloyd_codebook = unif_codebook;
        for epoch = 1:num_epoch
            lloyd_val_matrix = abs(selectedChannels.' * lloyd_codebook);
            [~, max_indices]=max(lloyd_val_matrix,[],2);
            unique_max = unique(max_indices);
            codebook_iter = 1;
            for mIdx = 1:length(unique_max)
                ueCluster = find(max_indices==unique_max(mIdx)); % cluster of UEs that have max power at this direction
                newCodeword = iterate_codeword(selectedChannels(:,ueCluster)); % iterating the codeword using Lloyd's algorithm
                lloyd_codebook(:,unique_max(mIdx)) = newCodeword;
                codebook_iter = codebook_iter + 1;
            end
            %     disp(epoch)
        end
        lloyd_val_matrix = abs(selectedChannels.' * lloyd_codebook);
        [lloyd_powers,~]=max(lloyd_val_matrix,[],2);
        
        
        %% Clustering and proportional Codebook
        %tic
        num_epoch = 20;
        proportional_codebook = unif_codebook;
        for epoch = 1:num_epoch
            proportional_val_matrix = abs(selectedChannels.' * proportional_codebook);
            [~, max_indices]=max(proportional_val_matrix,[],2);
            unique_max = unique(max_indices);
            codebook_iter = 1;
            %     ecdf(max_indices)
            %     hold on
            for mIdx = 1:length(unique_max)
                ueCluster = find(max_indices==unique_max(mIdx)); % cluster of UEs that have max power at this direction
                %         [maxVal,maxIndex] = max(proportional_powers(ueCluster)); % find the index and value of max power in this cluster
                %         multiplier = maxVal./proportional_powers(ueCluster); % multiplier for the beam of each UE in this clusteruser_channel_norm = vecnorm(selectedChannels(:,ueCluster));
                user_channel_norm = vecnorm(selectedChannels(:,ueCluster));
                multiplier = ch_threshold./user_channel_norm; % ratio of the threshold to each channel norm
                user_channels_as_beams = conj(selectedChannels(:,ueCluster))./vecnorm(selectedChannels(:,ueCluster));
                beam_combined = sum(user_channels_as_beams.*multiplier,2);
                beam_combined = beam_combined./vecnorm(beam_combined);
                proportional_codebook(:,unique_max(mIdx)) = beam_combined;
                codebook_iter = codebook_iter + 1;
            end
            %     disp(codebook_iter)
        end
        
        proportional_val_matrix = abs(selectedChannels.' * proportional_codebook);
        [proportional_powers,~]=max(proportional_val_matrix,[],2);
        
        
        
        % Plotting results
        if isCDFPlot
            figure;
            plot(sort(channel_norms,'ascend'),[1:N]./N)
            legend_string{1} = 'Matched';
            hold on;
            
            plot(sort(eig_powers_iterative,'ascend'),[1:N]./N)
            legend_string{2} = 'Eigen Iterative Codebook';
            
            plot(sort(eig_powers,'ascend'),[1:N]./N)
            legend_string{3} = 'Eigen Codebook';
            
            plot(sort(user_ch_powers,'ascend'),[1:N]./N)
            legend_string{4} = 'Receiver Channel-based Codebook Selection';
            
            plot(sort(unif_powers,'ascend'),[1:N]./N)
            legend_string{5} = 'Uniform Codebook';
            
            plot(sort(lloyd_powers,'ascend'),[1:N]./N)
            legend_string{6} = 'Lloyd Codebook';
            
            plot(sort(proportional_powers,'ascend'),[1:N]./N)
            legend_string{7} = 'Proportional Codebook';
            
            
            legend(legend_string)
        end
        
        
        
        % Displaying coverage results
        
        rat_matched = length(find(channel_norms>=ch_threshold))/N;
        rat_eig_iter = length(find(eig_powers_iterative>=ch_threshold))/N;
        rat_eig_cb = length(find(eig_powers>=ch_threshold))/N;
        rat_user_iter = length(find(user_ch_powers>=ch_threshold))/N;
        rat_uniform = length(find(unif_powers>=ch_threshold))/N;
        rat_proportional = length(find(proportional_powers>=ch_threshold))/N;
        rat_lloyd = length(find(lloyd_powers>=ch_threshold))/N;
        disp(['Ratio of UEs served with threshold ',num2str(ch_threshold),', codebook size C = ',num2str(CODEBOOKSIZE),' , ',num2str(numAntennas),' TX antennas'])
        T = table(rat_matched,rat_eig_iter,rat_eig_cb,rat_user_iter,rat_uniform,rat_proportional,rat_lloyd,'VariableNames',{'Matched','Eigen-iter','Eigen codebook','User-iter','Uniform','Proportional','Lloyd'});
        disp(T)
        
        
        if isWrite
            % Read and save to existing .mat file
            filename = 'coverage_data.mat';
            new_data = [ch_threshold, CODEBOOKSIZE, numAntennas, rat_matched, rat_eig_iter, rat_eig_cb, rat_user_iter, rat_uniform, rat_proportional, rat_lloyd];
            if exist(filename, 'file')
                data = load(filename);
                coverage_data = data.coverage_data;
                [isin, index] = ismember(coverage_data(:,1:3), new_data(1:3), 'rows');
                if(isin) % if already containing this configuration, change it
                    coverage_data(index,:) = new_data;
                else
                    coverage_data = [coverage_data; new_data];
                end
            else
                coverage_data = new_data;
            end
            save('coverage_data.mat','coverage_data')
        end

    end
end