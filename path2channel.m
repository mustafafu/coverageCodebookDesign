function h_path = path2channel(rx_array_loc_matrix,tx_array_loc_matrix,path)
%PATH2CHANNEL given beam parameters, constructs N_r by N_t channel of path
% Antenna location (RX and TX) are in units of lambda (already divided by
% lambda when it comes to this function.)

power = path.power;
phase = path.phase;
toa = path.toa;
doa_theta = path.doa_theta;
doa_phi = path.doa_phi;
dod_theta = path.dod_theta;
dod_phi = path.dod_phi;

%%OFDM is not implemented now, but dummy input,k, is here for subcarrier 
k=0;
f = 0;
freq_response = exp(-1j*2*pi*k*toa*f); 

%%Energy of the path
alpha_l = sqrt(power)*exp(1j*phase);

%%Antenna responses for that path AoA and AoD
% rx & tx location input to generate_antenna_pattern is in the unit of lambda
% doa and phi should be in radians
rx_antenna_array_response = generate_antenna_pattern(rx_array_loc_matrix,doa_theta*pi/180,doa_phi*pi/180); %Nr by 1
tx_antenna_array_response = generate_antenna_pattern(tx_array_loc_matrix,dod_theta*pi/180,dod_phi*pi/180); %Nt by 1

%%Constructing the channel
% y=Hx -> h_beam should be N_R by N_T,  x-> N_T by 1
h_path  = alpha_l*freq_response*rx_antenna_array_response * tx_antenna_array_response'; %Nr by 1 matmul 1 by Nt -> Nr by Nt 

end

