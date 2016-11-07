# PuzzleImage
This code will achieve redrawing an image with large quantities of puzzle images. The parameter list is shown below:
这个 MATLAB 程序可以实现用无数小图片拼成一张大图的效果。参数列表：

% filename   : the original image to be transformed（原图，默认为"lena.bmp"）
% puzzle_size: the side length of puzzle image (square)（每个拼图的大小，默认30）
% origin_size: the maximum pixel number of the side length of origin（原图缩放后的边长，默认120）
% repeat     : the largest repeat time of each puzzle (0 = unlimited)（单张拼图的最大使用次数，默认为5，0表示无限制）
% distance   : the distance between two same puzzles (-1 = unlimited)（相同拼图的最小使用间隔，这个功能暂时并没有实现）
% overlap    : shift the rgb of puzzle to match every pixel（是否更改拼图颜色以匹配原图，默认为否0）
% puzzle_image: use a single puzzle image instead of a group of images（是否采用单张图片作为拼图进行绘制。如果选择单张图片，则以上的重复次数等参数将不起作用。如果不选择单张图片，则默认为相同目录下的“images”文件夹中的所有图片）
