% INPUT
freq = 28*1e9; %We used 28GHz at REMCOM
% antenna locations are in the unit of lambda--> no need for freq
rxstring = '013';
load('pathData.mat')

%%Converting single ray tracing to MISO
rx_array_size = [1,1,1]; %we can even make this per user
tx_array_size = [32,1,1];% per bs is still posssible

        
%%Also takes rotations as input, BSs can be rotated according to scenario.
rotMatrix = [0,0,0];
tx_array_loc_matrix = generate_antenna_element_location(tx_array_size,rotMatrix);
rx_array_loc_matrix = generate_antenna_element_location(rx_array_size,rotMatrix);


num_tx = size(TX,2);
num_rx = size(TX{1}.channel_params,2);
all_channels = cell(num_tx,num_rx);
rx_coordinates = nan(num_rx,3);
channel_matrices=cell(1,3);


num_rx_array_element = prod(rx_array_size);
num_tx_array_element = prod(tx_array_size);

for tx_idx=1:num_tx
    if num_rx_array_element == 1
        this_tx_channels = zeros(num_rx,num_tx_array_element);
    end
    for rx_idx = 1:num_rx
        if isnan(rx_coordinates(rx_idx,1)) % do only once
            rx_coordinates(rx_idx,:) = TX{tx_idx}.channel_params(rx_idx).loc;
        end
        this_pairs_paths = TX{tx_idx}.channel_params(rx_idx);
        num_paths = this_pairs_paths.num_paths;
        user_channel = zeros(num_rx_array_element,num_tx_array_element);
        for path_idx = 1:num_paths
            power_dBm = this_pairs_paths.power(path_idx); % path power in dBm
            path.power = 10^(power_dBm/10)/1000; % input power in Watts
            path.phase = this_pairs_paths.phase(path_idx);
            path.toa = this_pairs_paths.ToA(path_idx);
            path.doa_theta = this_pairs_paths.DoA_theta(path_idx);
            path.doa_phi = this_pairs_paths.DoA_phi(path_idx);
            path.dod_theta = this_pairs_paths.DoD_theta(path_idx);
            path.dod_phi = this_pairs_paths.DoD_phi(path_idx);
            path_channel = path2channel(rx_array_loc_matrix,tx_array_loc_matrix,path);
            user_channel = user_channel + path_channel;
        end
        all_channels{tx_idx,rx_idx} = user_channel;
            if num_rx_array_element == 1
                this_tx_channels(rx_idx,:)=user_channel;
            end
    end
    if num_rx_array_element == 1
        channel_matrices{tx_idx} = this_tx_channels;    
    end
end





