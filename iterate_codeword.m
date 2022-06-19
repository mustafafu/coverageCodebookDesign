% Takes a single codeword and served UEs, and iterates the codeword using
% Lloyd's algorithm
% codeword and new_codeword are Nx1 complex vectors, ue_channels is N x
% numUE matrix
function new_codeword = iterate_codeword(ue_channels)
numUEs = size(ue_channels,2);
sum_ch_cors = zeros(size(ue_channels,1));
for ue_idx = 1:numUEs
    Hmat =  ue_channels(:,ue_idx);
    sum_ch_cors = sum_ch_cors + conj(Hmat)*Hmat.';
end
[VV,DD] = eig(sum_ch_cors);
[~, sorting_indices] = sort(diag(abs(DD)),'descend');
best_codeword = VV(:,sorting_indices(1));
new_codeword = best_codeword;
end
