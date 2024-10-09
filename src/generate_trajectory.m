function trajectory = generate_trajectory(tra_number, mapSize, num_points, stepSize)
    % generate_trajectory: Generates different types of trajectories
    % Inputs:
    % tra_number: type of trajectory (1 = circular, 2 = straightline, 3 = rectangular, 4 = pentagon)
    % mapSize: size of the map (assumed to be square, e.g., mapSize x mapSize)
    % num_points: number of points in the trajectory
    % Outputs:
    % trajectory: Nx2 matrix where each row represents [x, y] coordinates of the trajectory
    
    % Initialize trajectory matrix
    trajectory = zeros(num_points, 2);

    switch tra_number
        case 1  % Circular trajectory
            radius = mapSize / 4;  % Set radius of the circle
            center_position = [mapSize / 2, mapSize / 2];  % Center of the circle
            theta = linspace(0, 2 * pi, num_points);  % Angle for each point
            for i = 1:num_points
                trajectory(i, 1) = center_position(1) + radius * cos(theta(i));  % X coordinates
                trajectory(i, 2) = center_position(2) + radius * sin(theta(i));  % Y coordinates
            end

        case 2  % Straightline trajectory
            start_position = [rand() * mapSize, rand() * mapSize];  % Random start position
            end_position = [rand() * mapSize, rand() * mapSize];  % Random end position
            for i = 1:num_points
                trajectory(i, :) = start_position + (i - 1) / (num_points - 1) * (end_position - start_position);
            end

        case 3  % Rectangular trajectory (path around a rectangle)
            % Define rectangle vertices (based on mapSize)
            edge_distance = 5;
            vertices = [
                edge_distance, edge_distance;
                mapSize-edge_distance, edge_distance;
                mapSize-edge_distance, mapSize-edge_distance;
                edge_distance, mapSize-edge_distance;
                edge_distance, edge_distance];  % Close the loop
            % Interpolate points along the edges of the rectangle
            total_length = 4 * mapSize;  % Perimeter of the rectangle
            edge_lengths = [mapSize, mapSize, mapSize, mapSize];
            edge_cumulative = cumsum([0, edge_lengths]);
            point_index = 1;
            for edge = 1:4
                num_points_edge = round(num_points * (edge_lengths(edge) / total_length));
                edge_start = vertices(edge, :);
                edge_end = vertices(edge + 1, :);
                for i = 1:num_points_edge
                    t = (i - 1) / (num_points_edge - 1);
                    trajectory(point_index, :) = (1 - t) * edge_start + t * edge_end;
                    point_index = point_index + 1;
                    if point_index > num_points, break; end
                end
                if point_index > num_points, break; end
            end

        case 4  % Pentagon trajectory
            radius = mapSize / 4;  % Set radius for the pentagon
            center_position = [mapSize / 2, mapSize / 2];  % Center of the pentagon
            angles = linspace(0, 2 * pi, 6);  % Divide the circle into 5 parts
            pentagon_vertices = [center_position(1) + radius * cos(angles'), center_position(2) + radius * sin(angles')];
            % Generate points along pentagon edges
            total_length = sum(sqrt(sum(diff(pentagon_vertices).^2, 2)));
            point_index = 1;
            for edge = 1:5
                num_points_edge = round(num_points * (sqrt(sum((pentagon_vertices(edge + 1, :) - pentagon_vertices(edge, :)).^2)) / total_length));
                for i = 1:num_points_edge
                    t = (i - 1) / (num_points_edge - 1);
                    trajectory(point_index, :) = (1 - t) * pentagon_vertices(edge, :) + t * pentagon_vertices(edge + 1, :);
                    point_index = point_index + 1;
                    if point_index > num_points, break; end
                end
                if point_index > num_points, break; end
            end

        otherwise
            error('Invalid trajectory number. Choose from 1 (circular), 2 (straightline), 3 (rectangular), 4 (pentagon).');
    end
end
