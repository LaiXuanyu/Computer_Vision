% Load the stereo images
image1 = imread('FD7.jpg'); % Replace with actual filename
image2 = imread('FD8.jpg'); % Replace with actual filename
% Step 2: Detect feature points
image1Gray = rgb2gray(image1);
image2Gray = rgb2gray(image2);
points1 = detectSURFFeatures(image1Gray);
points2 = detectSURFFeatures(image2Gray);
% Step 3: Match the feature points
features1 = extractFeatures(image1Gray, points1);
features2 = extractFeatures(image2Gray, points2);
indexPairs = matchFeatures(features1, features2);
matchedPoints1 = points1(indexPairs(:, 1), :);
matchedPoints2 = points2(indexPairs(:, 2), :);
% Step 4: Estimate the fundamental matrix
[fMatrix, epipolarInliers, status] = estimateFundamentalMatrix(matchedPoints1, matchedPoints2, 'Method', 'RANSAC', 'NumTrials', 10000, 'DistanceThreshold', 0.01, 'Confidence', 99.99);
% 使用内点(inliers)筛选匹配点
inlierPoints1 = matchedPoints1(epipolarInliers,:);
inlierPoints2 = matchedPoints2(epipolarInliers,:);
% 立体校正
[stereoRectificationMap1,stereoRectificationMap2]= estimateUncalibratedRectification(fMatrix,inlierPoints1.Location, inlierPoints2.Location, size(image2Gray));
image1Rect = imwarp(image1, projective2d(stereoRectificationMap1), 'OutputView', imref2d(size(image1Gray)));
image2Rect = imwarp(image2, projective2d(stereoRectificationMap2), 'OutputView', imref2d(size(image2Gray)));
% Step 6: Apply the stereo rectification transformation (already done in step 5)
% Step 7: Display the rectified images
figure; 
subplot(1, 2, 1);
imshow(image1Rect);
title('Rectified Image 1');
subplot(1, 2, 2);
imshow(image2Rect);
title('Rectified Image 2');
% Step 8: Draw epipolar lines on the rectified images
% Inliers after the rectification process
inlierPoints1 = matchedPoints1(epipolarInliers, :);
inlierPoints2 = matchedPoints2(epipolarInliers, :);
% Epipolar lines in the first image
epiLines1 = epipolarLine(fMatrix', inlierPoints2.Location);
points = lineToBorderPoints(epiLines1, size(image1Gray));
subplot(1, 2, 1); hold on;
line(points(:, [1,3])', points(:, [2,4])');
% Epipolar lines in the se
% Convert rectified images to grayscale
grayImage1Rect = rgb2gray(image1Rect);
grayImage2Rect = rgb2gray(image2Rect);
disparityRange =[0,128]; % 这是视差搜索范围，可能需要根据你的摄像机和场景进行调整。
disparityMap = disparitySGM(grayImage1Rect,grayImage2Rect,'DisparityRange', disparityRange);
% 显示视差图
figure;
imshow(disparityMap,disparityRange);
title('Disparity Map');
colormap(gca,jet);
colorbar;