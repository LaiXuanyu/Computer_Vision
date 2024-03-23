%% 手动操作的任务2a

original_image = imread('HG2.jpg');
zoom_rotated_image = imread('HG7.jpg');

% 通过手动选择匹配点
[moving_points, fixed_points] = cpselect(zoom_rotated_image, original_image, 'Wait', true);

% 估计几何变换矩阵
geometric_transform = fitgeotrans(moving_points, fixed_points, 'projective');

% 矫正旋转图像
output_view = imref2d(size(original_image));
rectified_image = imwarp(zoom_rotated_image, geometric_transform, 'OutputView', output_view);

% 显示结果和匹配点
figure;
subplot(1,2,1);
imshow(original_image);
title('Original image');
hold on;
plot(fixed_points(:,1), fixed_points(:,2), 'yo');

subplot(1,2,2);
imshow(rectified_image);
title('Rectified image');
hold on;
% 计算匹配点在矫正图像中的新位置
transformed_moving_points = transformPointsForward(geometric_transform, moving_points);
plot(transformed_moving_points(:,1), transformed_moving_points(:,2), 'yo');

% 在一个单独的图中展示匹配点和连接线
figure; imshowpair(original_image, rectified_image, 'montage');
hold on;
% 在两幅图像上绘制匹配点
plot(fixed_points(:,1), fixed_points(:,2), 'yo');
plot(transformed_moving_points(:,1) + size(original_image,2), transformed_moving_points(:,2), 'yo');
% 绘制连接线
for i = 1:size(fixed_points, 1)
    line([fixed_points(i,1), transformed_moving_points(i,1) + size(original_image,2)], ...
         [fixed_points(i,2), transformed_moving_points(i,2)], 'Color', 'g');
end
title('Matching Points');
