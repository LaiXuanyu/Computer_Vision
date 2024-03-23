% Load images
image1 = imread('FD12.JPG'); % Adjust filename as necessary
image2 = imread('FD13.JPG'); % Adjust filename as necessary

% Convert images to grayscale (required for feature detection)
grayImage1 = rgb2gray(image1);
grayImage2 = rgb2gray(image2);

% Detect features in both images. Here we use the 'BRISK' features for demonstration.
points1 = detectORBFeatures(grayImage1);
points2 = detectORBFeatures(grayImage2);

% Extract the feature descriptors.
[features1, validPoints1] = extractFeatures(grayImage1, points1);
[features2, validPoints2] = extractFeatures(grayImage2, points2);

% Match the features using their descriptors.
indexPairs = matchFeatures(features1, features2);

% Retrieve the locations of the matched points.
matchedPoints1 = validPoints1(indexPairs(:, 1), :);
matchedPoints2 = validPoints2(indexPairs(:, 2), :);

% Display the matching points. The display is optional but useful for verification.
figure; showMatchedFeatures(image1, image2, matchedPoints1, matchedPoints2, 'montage');
title('Matched Points (Including Outliers)');

% Estimate the homography matrix using RANSAC.
[tform, inlierIdx, status] = estimateGeometricTransform2D(matchedPoints1.Location, matchedPoints2.Location, 'projective', 'Confidence', 99.9, 'MaxNumTrials', 2000, 'MaxDistance', 1);

% Check if the estimation was successful
if status ~= 0
    error('estimateGeometricTransform2D was not successful');
end

% Extract the inlier matched points based on the RANSAC results.
inlierMatchedPoints1 = matchedPoints1(inlierIdx, :);
inlierMatchedPoints2 = matchedPoints2(inlierIdx, :);

% Display the inlier matches.
figure; showMatchedFeatures(image1, image2, inlierMatchedPoints1, inlierMatchedPoints2, 'montage');
title('Matched Points (Inliers Only)');

% The transformation object 'tform' contains the estimated homography matrix.
disp('Estimated homography matrix:');
disp(tform.T);

%% outliers
% Assuming matchedPoints1 and matchedPoints2 are the matched points between two images
[F, inliers] = estimateFundamentalMatrix(matchedPoints1, matchedPoints2, 'Method', 'RANSAC');

% Number of inliers
numInliers = sum(inliers);

% Total number of matches
totalMatches = size(matchedPoints1, 1);

% Number of outliers
numOutliers = totalMatches - numInliers;

fprintf('Number of inliers: %d\n', numInliers);
fprintf('Number of outliers: %d\n', numOutliers);


