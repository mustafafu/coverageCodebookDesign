function antenna_array_response = generate_antenna_pattern(array_loc_matrix,theta,phi)
% Input array_loc_matrix is in the units of lambda.

%generate_antenna_pattern given beam angle generates antenna phase shift
%array
increase_pathloss = false;
%%Antenna loc matrix structure:
%x1,y1,z1 is location of 1st antenna element
%xi,yi,yz is the loc of ith antenna element
% num_antenna_element by 3 matrix where 3 is x,y,z location of the
% parituclar element.

%%Theta input in radians, relative to fixed global spherical coordinate
%%Phi input in radians, relative to fixed global spherical coordinate
% Remcom reference manual 307.
beam_direction_vector =  [sin(theta)*cos(phi); sin(theta)* sin(phi) ; cos(theta)];
%Dot product of antenna_locations with beam_direction_vector will give us
%wavelength shift which will be phase shift
% multiplying it with 1j and taking the exponential we will get the array
% response vector.
% https://ieeexplore.ieee.org/document/7400949 following this paper.
antenna_array_response = exp(-1j* 2 * pi * array_loc_matrix * beam_direction_vector);
%This will return a vector of shape, num_antenna_elem by 1.
if increase_pathloss
    antenna_array_response =  exp(-1* (array_loc_matrix * beam_direction_vector)).*antenna_array_response;
end

