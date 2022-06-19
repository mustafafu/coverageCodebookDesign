function [best_bs_per_ue,best_pow_ue_got] = matched_filter(all_channels,rx_coordinates,BS_loc_mat,epsilon)
%MATCHED_FILTER  exact channel matched combining
[nBs, nRx] = size(all_channels);
best_bs_per_ue = zeros(1,nRx);
best_pow_ue_got = zeros(1,nRx);
for rxIdx = 1:nRx
    best_bs_idx = -1;
    best_bs_pow = epsilon;
    for bsIdx = 1:nBs
        this_channel_pow = norm(all_channels{bsIdx,rxIdx});
        if this_channel_pow > best_bs_pow
            best_bs_pow = this_channel_pow;
            best_bs_idx = bsIdx;
        end
    end
    best_bs_per_ue(rxIdx) = best_bs_idx;
    best_pow_ue_got(rxIdx) = best_bs_pow;
end
% figure()
% scatter(rx_coordinates(:,1),rx_coordinates(:,2),[],best_bs_per_ue,'filled')
% hold on
% scatter(BS_loc_mat(:,1),BS_loc_mat(:,2),[50,50,50],'^','filled')
% title('Best BS index')
end

