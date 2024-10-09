function error_distance = objective_position_v1(params, beacon_positions, rssi_measurements, optimized_beacons)
%% Readme
% This function optimize the positions, transmission loss, and reference
% rssi of several beacons
%% Function begins
current_distance = sqrt( sum( (beacon_positions - reshape(params(1:2), 1, 2)).^2, 2) );
% transmission_n = params(3);
num_beacons = size(beacon_positions, 1);
% % calculate the rssi 
% rssi0 = reshape(params(4:(optimized_beacons + 4 - 1))'.*ones(num_beacons, 1), num_beacons, []);
% rssi_search = rssi0 - 10 * transmission_n *log10(current_distance + 1e-9);
rssi_measurements = reshape(rssi_measurements, num_beacons, []);
estimatedDistance = 10.^( (rssi_measurements(1:num_beacons) - params(4)) ./ (-10 * params(3)) );
error_distance = mean( abs(current_distance - estimatedDistance) );
% error_rssi = sum((rssi_measurements - rssi_search).^2);
end % function end