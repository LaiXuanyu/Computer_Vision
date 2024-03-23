% Load the images
im_trans = imread('HG7.jpg');    % Translated image
im_org = imread('HG2.jpg');      % Original image

% Convert to grayscale for feature detection
org_gray = rgb2gray(im_trans);
tran_gray = rgb2gray(im_org);

% Detect features and extract the strongest ones
p_org = detectSURFFeatures(org_gray);
p_org = selectStrongest(p_org, 100);
p_tran = detectSURFFeatures(tran_gray);
p_tran = selectStrongest(p_tran, 100);

% Extract features and match
[features1, validPoints1] = extractFeatures(org_gray, p_org);
[features2, validPoints2] = extractFeatures(tran_gray, p_tran);
indexPairs = matchFeatures(features1, features2);

% Retrieve matched points
matchedPoints1 = validPoints1(indexPairs(:, 1), :);
matchedPoints2 = validPoints2(indexPairs(:, 2), :);

% Estimate geometric transform
tform = estimateGeometricTransform(matchedPoints1, matchedPoints2, 'projective');

% Create a view for displaying the rectified image
outputView = imref2d(size(im_org));
rectified = imwarp(im_trans, tform, 'OutputView', outputView);

% Display both images and the matched features
figure;
showMatchedFeatures(im_org, rectified, matchedPoints1, matchedPoints2, 'montage');
title('Auto Rectified Image');

% Optionally, save this figure
% saveas(gcf, 'MatchedPointsAndRectified.png');
