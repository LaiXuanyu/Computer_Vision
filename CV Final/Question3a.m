% 定义要处理的图像
image_filenames = {'Final data\FD1.JPG',...
    'Final data\FD2.JPG',...
    'Final data\FD3.JPG',...
    'Final data\FD4.JPG',...
    'Final data\FD5.JPG',...
    'Final data\FD6.JPG',...
    };
% 在图像中检测棋盘格
[image_points, board_size, images_used] = detectCheckerboardPoints(image_filenames);
image_filenames = image_filenames(images_used);

% 读取第一幅图像以获取图像尺寸
original_image = imread(image_filenames{1});
[mrows, ncols, ~] = size(original_image);

% 生成棋盘格方格的世界坐标
square_size = 20;  % 单位为 '毫米'
world_points = generateCheckerboardPoints(board_size, square_size);

% 标定相机
[canon_r10, images_used, canon_r10_errors] = estimateCameraParameters(image_points, world_points, ...
    'EstimateSkew', true, 'EstimateTangentialDistortion', true, ...
    'NumRadialDistortionCoefficients', 2, 'WorldUnits', 'millimeters', ...
    'InitialIntrinsicMatrix', [], 'InitialRadialDistortion', [], ...
    'ImageSize', [mrows, ncols]);

% 显示重投影误差
h1 = figure; 
showReprojectionErrors(canon_r10);

% 可视化相机外部参数
h2 = figure; 
showExtrinsics(canon_r10, 'CameraCentric');

% 显示参数估计误差
displayErrors(canon_r10_errors, canon_r10);


original_object = imread('HG2.jpg');
% 例如，您可以使用标定数据去除镜头畸变的影响。
undistorted_image = undistortImage(original_object, canon_r10);
imshow(undistorted_image);