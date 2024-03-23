% Read and preprocess the image
I = imread('FD9.jpg');
J = imfilter(I, fspecial('gaussian', [17 17], 5), 'symmetric');
J = rgb2gray(J);

% Edge detection and Hough Transform for line detection
BW = edge(J, 'sobel');
se3 = strel('disk', 4);
BW = imdilate(BW, se3);
[H, T, R] = hough(BW);
P = houghpeaks(H, 9); % Find up to 9 peaks
lines = houghlines(J, T, R, P);

% Pad the original image
padSize = 3200; % Adjusted for visualization
I_padded = padarray(I, [padSize padSize], 255, 'both');

% Display the padded image
figure, imshow(I_padded), hold on;

% Exclude specific lines by their index
excludeLines = [3];

% Plotting and extending lines, excluding specified ones
for k = 1:length(lines)
    if ismember(k, excludeLines)
        continue; % Skip the current iteration for excluded lines
    end
    
    % Extract start and end points of each line, adjust with padding
    x1 = lines(k).point1(1) + padSize;
    y1 = lines(k).point1(2) + padSize;
    x2 = lines(k).point2(1) + padSize;
    y2 = lines(k).point2(2) + padSize;

    % Extend lines to the edges of the padded image and plot
    if x2 == x1 % Vertical lines
        plot([x1, x1], [1, size(I_padded, 1)], 'LineWidth', 1, 'Color', 'blue');
    else
        % Calculate slope and intercept for non-vertical lines
        m = (y2 - y1) / (x2 - x1);
        c = y1 - m * x1;
        % Extend to the image boundaries
        yLeft = m * 1 + c;
        yRight = m * size(I_padded, 2) + c;
        plot([1, size(I_padded, 2)], [yLeft, yRight], 'LineWidth', 2, 'Color', 'blue');
    end
end

% Select line pairs for intersection calculation
linePairs = [1, 2; 8, 4];
intersections = [];

% Calculate and plot intersections for specific line pairs
for i = 1:size(linePairs, 1)
    idx1 = linePairs(i, 1);
    idx2 = linePairs(i, 2);
    l1 = lines(idx1);
    l2 = lines(idx2);

    % Calculate intersections considering padding
    [xi, yi] = calculateIntersection(l1.point1(1) + padSize, l1.point1(2) + padSize, l1.point2(1) + padSize, l1.point2(2) + padSize, l2.point1(1) + padSize, l2.point1(2) + padSize, l2.point2(1) + padSize, l2.point2(2) + padSize);

    if ~isinf(xi) && ~isinf(yi) % Ensure the intersection is valid
        intersections = [intersections; [xi, yi]]; % Store for later use
        viscircles([xi, yi], 50, 'Color', 'r', 'LineWidth', 2); % Draw circle around intersection
    end
end

% Connect intersection points if we have at least two
if size(intersections, 1) >= 2
    plot(intersections(:,1), intersections(:,2), 'g-', 'LineWidth', 3); % Connect with a green line
end

hold off; % Finalize plotting

% Your main script commands go here
% Read and preprocess the image
% Edge detection and line detection
% Exclude specific lines, plot extended lines, calculate intersections, etc.

% After all the main script commands, define the calculateIntersection function at the end
function [xi, yi] = calculateIntersection(x1, y1, x2, y2, x3, y3, x4, y4)
    % Line equation from points
    A1 = y2 - y1; B1 = x1 - x2; C1 = A1*x1 + B1*y1;
    A2 = y4 - y3; B2 = x3 - x4; C2 = A2*x3 + B2*y3;
    % Determinant
    detAB = A1*B2 - A2*B1;
    if abs(detAB) < 1e-10
        xi = Inf; yi = Inf; % Parallel lines or overlap, no single intersection
    else
        % Intersection calculation
        xi = (C1*B2 - C2*B1) / detAB;
        yi = (A1*C2 - A2*C1) / detAB;
    end
end
