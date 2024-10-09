% Set random seed for reproducibility
clear;
% rng(42);
% v3 optimize a trajectory
% Generate random start position within the map
map_size = 30;  % 30m x 30m map
num_points = 15;  % Number of points in the trajectory (steps)
radius = map_size;  % Radius of the circle
center_position = [map_size / 2, map_size / 2];  % Center of the circle (mid-point of the map)

tra_number = 1;
stepSize = 4;
trajectory = generate_trajectory(tra_number, radius, num_points);
clf;
plot(trajectory(:,1), trajectory(:,2));
set(gca,'xlim',[0, map_size]);
set(gca,'ylim',[0, map_size]);
%% 1. Simulate the environment

% Generate random positions for a fixed number of beacons
num_beacons = 5;
% beacon_positions = rand(num_beacons, 2) * map_size;
beacon_positions = [0,0;0,map_size;map_size,map_size;map_size,0;map_size/2,map_size/2];
beacon_positions = beacon_positions(1:num_beacons, :);
% 1. Simulate the environment

% Generate a random position for the smartphone
true_smartphone_position = trajectory;

% 2. Define the known RSSI transmission function
true_n = 2.0 + rand(1) * 2 - 1;        % True path loss exponent
true_rssi0 = -40;  % True RSSI at 1 meter

% simulate the variation of beacons
for j_step = 1: size(trajectory, 1)
    for j_beacon = 1:size(beacon_positions, 1)
        true_rssi0(j_beacon, j_step) = -40 + 0 * (rand(1) * 5 - 2.5);
        true_n(j_beacon, j_step) = 2.5 + 0 * (rand(1) * 0.5 - 0.25);
    end
end

% moving average filter
% true_rssi0 = movmean(true_rssi0, 10, 2);
% true_n = movmean(true_n, 10, 2);

% RSSI function based on the log-distance path loss model
true_rssi_function = @(d, rssi0, n) rssi0 - 10 * n.* log10(d + 1e-9); % Adding a small epsilon to avoid log(0)

% 3. Generate RSSI measurements
calculate_distances = @(positions1, positions2) sqrt(sum((positions1 - positions2).^2, 2));

% Calculate true distances from each beacon to the smartphone
true_distances = {};
rssi_measurements = {};
for j_step = 1:size(trajectory, 1)
    true_distances{j_step} = calculate_distances(beacon_positions, true_smartphone_position(j_step, :));
    rssi_measurements{j_step} = true_rssi_function(true_distances{j_step}, true_rssi0(:, j_step), true_n(:, j_step)); % 
end
% Simulate RSSI measurements

% rssi_measurements = rssi_measurements + rand(length(rssi_measurements), 1).*rssi_measurements*0.1;

% 4. Particle Swarm Optimization (PSO)

% PSO settings
optimized_beacons = 1;
lb = [0, 0, 1, repmat(-50, 1, optimized_beacons)];   % Lower bounds for [x, y, RSSI0, n]
ub = [map_size, map_size, 4, repmat(-30, 1, optimized_beacons)];  % Upper bounds for [x, y, RSSI0, n]

estimated_params = {};
estimated_error = {};
for j_step = 1:size(trajectory, 1)
    fprintf([num2str(j_step),'\n']);
    % Run PSO
    options = optimoptions('particleswarm', 'SwarmSize', 200, 'MaxIterations', 1000, 'Display', 'final', ...
        'FunctionTolerance', 1e-10);
    [estimated_params{j_step}, estimated_error{j_step}] = ...
        particleswarm(@(params)objective_position_v1(params, beacon_positions, ...
        rssi_measurements{j_step}, optimized_beacons),...
        length(lb), lb, ub, options);
    estimated_params{j_step} = estimated_params{j_step}';
end

%% Extract the estimated smartphone position and RSSI parameters
estimated_position = cell2mat(estimated_params);
estimated_position = estimated_position(1:2,:);
estimated_n = estimated_params(3);
estimated_rssi0 = estimated_params(4:end);

% Display the results
disp('True Smartphone Position:');
disp(true_smartphone_position);
disp('Estimated Smartphone Position:');
disp(estimated_position);
disp('True RSSI_0 and n:');
disp([true_rssi0', true_n']);
disp('Estimated RSSI_0 and n:');
disp([estimated_rssi0, estimated_n]);
disp('prediction error:');
disp( mean(sqrt(sum((true_smartphone_position' - estimated_position).^2, 1))) );

% Visualization
% figure;
clf
hold on;
scatter(beacon_positions(:,1), beacon_positions(:,2), 100, 'b', 'filled');
plot(true_smartphone_position(:, 1), true_smartphone_position(:, 2),'.k');
plot(estimated_position(1, :), estimated_position(2, :),  '-.r');
% xlim([0, map_size]);
% ylim([0, map_size]);
title('BLE Indoor Positioning - True vs Estimated Position using PSO');
legend('Beacons', 'True Smartphone Position', 'Estimated Smartphone Position','Location','bestoutside');
grid on;
hold off;