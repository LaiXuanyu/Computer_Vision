im_trans = imread('HG7.jpg');    % load the original image
org_gray = rgb2gray(im_trans);
im_org = imread('HG2.jpg');   % load the zoomed in and rotated image
tran_gray = rgb2gray(im_org);

p_org = detectSURFFeatures(org_gray);   % detect the feature points on the 
                                        % on the original image.
p_org = selectStrongest(p_org, 100);    % select the strongest 100 points

p_tran = detectSURFFeatures(tran_gray); % detect the feature points on the 
                                        % translated image. 
p_tran = selectStrongest(p_tran, 100);  % select the strongest 100 points

[features1, validPoints1] = extractFeatures(org_gray, p_org);
[features2, validPoints2] = extractFeatures(tran_gray, p_tran);
indexPairs = matchFeatures(features1, features2);
matchedPoints1 = validPoints1(indexPairs(:, 1), :);
matchedPoints2 = validPoints2(indexPairs(:, 2), :);

% Plotting the matching result
figure;
showMatchedFeatures(org_gray, tran_gray, matchedPoints1, matchedPoints2, 'montage');
tform = estimateGeometricTransform(matchedPoints1.Location,...
matchedPoints2.Location, 'projective');
% in 'tform' the transform matrix can be checked

% Plotting the rectified result
rectified = imwarp(im_trans, tform);
figure;
subplot(1,2,1);
imshow(im_org);
subplot(1,2,2);
imshow(rectified);

