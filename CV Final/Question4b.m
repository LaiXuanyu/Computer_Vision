%% Estimating the Fundamental Matrix
% Load the FD images
image1 = imread('IMG_2701.jpg'); % Adjust filename as necessary
image2 = imread('IMG_2706.jpg'); % Adjust filename as necessary

% Convert to grayscale
grayImage1 = rgb2gray(image1);
grayImage2 = rgb2gray(image2);

% Detect features. Here, we continue with BRISK for consistency.
points1 = detectORBFeatures(grayImage1);
points2 = detectORBFeatures(grayImage2);


% Extract features
[features1, validPoints1] = extractFeatures(grayImage1, points1);
[features2, validPoints2] = extractFeatures(grayImage2, points2);

% Match features
indexPairs = matchFeatures(features1, features2);

% Retrieve the locations of matched points
matchedPoints1 = validPoints1(indexPairs(:, 1), :);
matchedPoints2 = validPoints2(indexPairs(:, 2), :);

% Estimate the fundamental matrix
[F, inliers] = estimateFundamentalMatrix(matchedPoints1, matchedPoints2, 'Method', 'RANSAC', 'NumTrials', 2000, 'DistanceThreshold', 0.1);

% Extract inlier matches
inlierPoints1 = matchedPoints1(inliers, :);
inlierPoints2 = matchedPoints2(inliers, :);

% Visualize the inlier matches
figure; showMatchedFeatures(image1, image2, inlierPoints1, inlierPoints2, 'montage');
title('Inlier Matches');

%% Visualizing Epipolar Lines
% Visualize epipolar lines in the first image
figure; 
imshow(image1); 
title('Epipolar Lines in Image 1');
hold on;
epiLines = epipolarLine(F', inlierPoints2.Location);
points = lineToBorderPoints(epiLines, size(image1));
line(points(:, [1,3])', points(:, [2,4])');

% Visualize epipolar lines in the second image
figure; 
imshow(image2); 
title('Epipolar Lines in Image 2');
hold on;
epiLines = epipolarLine(F, inlierPoints1.Location);
points = lineToBorderPoints(epiLines, size(image2));
line(points(:, [1,3])', points(:, [2,4])');

%%
% Estimate the homography matrix using RANSAC.
[tform, inlierIdx, status] = estimateGeometricTransform2D(matchedPoints1.Location, matchedPoints2.Location, 'projective', 'Confidence', 99.9, 'MaxNumTrials', 2000, 'MaxDistance', 1.5);

% Check if the estimation was successful
if status ~= 0
    error('estimateGeometricTransform2D was not successful');
end

% Calculate the number of inliers and outliers
numInliers = sum(inlierIdx);
numOutliers = size(matchedPoints1, 1) - numInliers;

% Display the number of inliers and outliers
disp(['Number of inliers: ', num2str(numInliers)]);
disp(['Number of outliers: ', num2str(numOutliers)]);
