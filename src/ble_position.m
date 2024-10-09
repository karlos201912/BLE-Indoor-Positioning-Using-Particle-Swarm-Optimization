% Set random seed for reproducibility
clear;
% rng(42);

% 1. Simulate the environment
map_size = 30;  % 100m x 100m map

% Generate random positions for a fixed number of beacons
num_beacons = 9;
beacon_positions = rand(num_beacons, 2) * map_size;
beacon_positions = [0,0;0,map_size;map_size,map_size;map_size,0;map_size/2,map_size/2;...
    0,15;15,30;30,15;15,0];
beacon_positions = beacon_positions(1:num_beacons, :);
% % place beacon as a circle
% map_R = 30;
% d_alpha = 2 * pi 
% / num_beacons;
% beacon_positions = zeros(num_beacons, 2);
% for j_beacon = 1:num_beacons
%     beacon_positions(j_beacon, 1) = map_R * cos(j_beacon * d_alpha);
%     beacon_positions(j_beacon, 2) = map_R * sin(j_beacon * d_alpha);
% end
% plot(beacon_positions(:, 1), beacon_positions(:, 2), '.');grid on

% Generate a random position for the smartphone
true_smartphone_position = rand(1, 2) * map_size;
% true_smartphone_position = [24.9278   29.3319];

% 2. Define the known RSSI transmission function
true_rssi0 = -40;  % True RSSI at 1 meter
true_n = 2.1;        % True path loss exponent

% RSSI function based on the log-distance path loss model
true_rssi_function = @(d, rssi0, n) rssi0 - 10 * n * log10(d + 1e-9); % Adding a small epsilon to avoid log(0)

% 3. Generate RSSI measurements
calculate_distances = @(positions1, positions2) sqrt(sum((positions1 - positions2).^2, 2));

% Calculate true distances from each beacon to the smartphone
true_distances = calculate_distances(beacon_positions, true_smartphone_position);

% Simulate RSSI measurements
rssi_measurements = true_rssi_function(true_distances, true_rssi0, true_n);
% rssi_measurements = rssi_measurements + rand(length(rssi_measurements), 1).*rssi_measurements*0.1;

% 4. Particle Swarm Optimization (PSO)

% Objective function to minimize
objective = @(params) sum((rssi_measurements - true_rssi_function(calculate_distances(beacon_positions, params(1:2)), params(3), params(4))).^2);

% PSO settings
lb = [0, 0, -100, 2];   % Lower bounds for [x, y, RSSI0, n]
ub = [map_size, map_size, -30, 4];  % Upper bounds for [x, y, RSSI0, n]
%
% lb = [-15, -15, -100, 2];   % Lower bounds for [x, y, RSSI0, n]
% ub = [15, 15, -30, 4];  % Upper bounds for [x, y, RSSI0, n]


% Run PSO
options = optimoptions('particleswarm', 'SwarmSize', 30, 'MaxIterations', 1000, 'Display', 'iter', ...
    'FunctionTolerance', 1e-7);
[estimated_params, estimated_error] = particleswarm(objective, 4, lb, ub, options);

% Extract the estimated smartphone position and RSSI parameters
estimated_position = estimated_params(1:2);
estimated_rssi0 = estimated_params(3);
estimated_n = estimated_params(4);

% Display the results
disp('True Smartphone Position:');
disp(true_smartphone_position);
disp('Estimated Smartphone Position:');
disp(estimated_position);
disp('True RSSI_0 and n:');
disp([true_rssi0, true_n]);
disp('Estimated RSSI_0 and n:');
disp([estimated_rssi0, estimated_n]);
disp('prediction error:');
disp(norm(true_smartphone_position - estimated_position));

% Visualization
% figure;
clf
hold on;
scatter(beacon_positions(:,1), beacon_positions(:,2), 100, 'b', 'filled');
scatter(true_smartphone_position(1), true_smartphone_position(2), 100, 'k','filled');
scatter(estimated_position(1), estimated_position(2), 50, 'r', 'filled');
xlim([0, map_size]);
ylim([0, map_size]);
title('BLE Indoor Positioning - True vs Estimated Position using PSO');
legend('Beacons', 'True Smartphone Position', 'Estimated Smartphone Position','Location','bestoutside');
grid on;
hold off;
%% Check the performance with 1000 samples MCM
disp(['Begin 1000 simulation to visualize the overall accuracy']);
disp(['Press enter to continue']);
pause()
mcm_sample = 1000;
error_record = cell(mcm_sample, 1);
for j_sample = 1:mcm_sample
    % Generate a random position for the smartphone
    true_smartphone_position = rand(1, 2) * map_size;

    % 2. Define the known RSSI transmission function
    true_rssi0 = -40 +rand(1) * 20 - 10;  % True RSSI at 1 meter
    true_n = 2.0 + rand(1) * 2 - 1;        % True path loss exponent

    % RSSI function based on the log-distance path loss model
    true_rssi_function = @(d, rssi0, n) rssi0 - 10 * n * log10(d + 1e-9); % Adding a small epsilon to avoid log(0)

    % 3. Generate RSSI measurements
    calculate_distances = @(positions1, positions2) sqrt(sum((positions1 - positions2).^2, 2));

    % Calculate true distances from each beacon to the smartphone
    true_distances = calculate_distances(beacon_positions, true_smartphone_position);

    % Simulate RSSI measurements
    rssi_measurements = true_rssi_function(true_distances, true_rssi0, true_n);
    % rssi_measurements = rssi_measurements + rand(length(rssi_measurements), 1).*rssi_measurements*0.1;

    % 4. Particle Swarm Optimization (PSO)

    % Objective function to minimize
    objective = @(params) sum((rssi_measurements - true_rssi_function(calculate_distances(beacon_positions, params(1:2)), params(3), params(4))).^2);

    % PSO settings
    lb = [0, 0, -100, 1];   % Lower bounds for [x, y, RSSI0, n]
    ub = [map_size, map_size, -30, 4];  % Upper bounds for [x, y, RSSI0, n]
    %
    % lb = [-15, -15, -100, 2];   % Lower bounds for [x, y, RSSI0, n]
    % ub = [15, 15, -30, 4];  % Upper bounds for [x, y, RSSI0, n]


    % Run PSO
    options = optimoptions('particleswarm', 'SwarmSize', 100, 'MaxIterations', 1000, 'Display', 'iter', ...
        'FunctionTolerance', 1e-10);
    [estimated_params, estimated_error] = particleswarm(objective, 4, lb, ub, options);
    % Extract the estimated smartphone position and RSSI parameters
    estimated_position = estimated_params(1:2);
    estimated_rssi0 = estimated_params(3);
    estimated_n = estimated_params(4);
    error_record{j_sample} = [norm(true_smartphone_position - estimated_position), ...
        abs(estimated_n - true_n),abs(estimated_rssi0 - true_rssi0)];
    if norm(true_smartphone_position - estimated_position) > 1;pause();else;end
end
error_record = cell2mat(error_record);
histogram(error_record(:, 1));set(gca,'yscale','log');
boxplot(error_record)