% This function generates antenna element locations relative to the coordinate [0,0,0], assuming an antenna
% spacing of lambda/2. 'rotation_vec' is in degrees, will be converted to radians. 
function array_loc_mat = generate_antenna_element_location(array_size,rotation_vec)

% lambda = physconst('LightSpeed')/freq;
loc_shift_matrix_x = 0:1/2:1/2*(array_size(1)-1);
loc_shift_matrix_y = 0:1/2:1/2*(array_size(2)-1);
loc_shift_matrix_z = 0:1/2:1/2*(array_size(3)-1);
[MX,MY,MZ] = meshgrid(loc_shift_matrix_x,loc_shift_matrix_y,loc_shift_matrix_z);
array_loc_mat = [MX(:),MY(:),MZ(:)];


%We need to update this, rotation is not commutative,
% Maybe we can get a matrix ordered by rotation events
% first row first rotation
% second row second rotation and so on,
% where the [x,y,z] is angles around the axes, and two of the x,y,z is
% zero.
rotation_vec_rd = rotation_vec.*pi/180; % converting the rotation degrees to radians
rotation_mat_x = [1 0 0; 
                  0 cos(rotation_vec_rd(1)) -sin(rotation_vec_rd(1));
                  0 sin(rotation_vec_rd(1))  cos(rotation_vec_rd(1))];
rotation_mat_y = [ cos(rotation_vec_rd(2)) 0 sin(rotation_vec_rd(2));
                  0 1 0;
                  -sin(rotation_vec_rd(2)) 0 cos(rotation_vec_rd(2))];
rotation_mat_z = [cos(rotation_vec_rd(3)) -sin(rotation_vec_rd(3)) 0;
                  sin(rotation_vec_rd(3))  cos(rotation_vec_rd(3)) 0;
                  0 0 1];
array_loc_mat = (rotation_mat_x*(rotation_mat_y*(rotation_mat_z*array_loc_mat')))';
end