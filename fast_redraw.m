function varargout = fast_redraw(file_name, puzzle_size, origin_size, repeat, overlap, puzzle_image)
% Use large quantities of images (puzzle) to build up one original image
% Inside this code, all image will be stored as uint8 for saving RAM
% storages, and all calculation will be done as double for convenience of
% matrix operation
%
% filename   : the original image to be transformed
% puzzle_size: the side length of puzzle image (square)
% origin_size: the maximum pixel number of the side length of origin
% repeat     : the largest repeat time of each puzzle (0 = unlimited)
% overlap    : shift the rgb of puzzle to match every pixel
% puzzle_image: use a single puzzle image instead of a group of images
%
% (c) Mengkai Ma, 28 Sep. 2016
narginchk(0, 6);
% Default parameters
puzzle_dir = 'images\\';
if nargin < 1
    file_name = 'lena.bmp';
end
if nargin < 2
    puzzle_size = 30;
end
if nargin < 3
    origin_size = 120;
end
if nargin < 4
    repeat = 5;
end
if nargin < 5
    overlap = 0;
end
% Load the original image and change the longer side to be origin_size
origin = imread(file_name);
[height, width, ~] = size(origin);
if width > height
    zoomratio = origin_size / width;
else
    zoomratio = origin_size / height;
end
small_origin = imresize(origin, zoomratio);
[height, width, ~] = size(small_origin);

if nargin < 6
    if ~(exist('image_data.mat', 'file'))
        % info.image: cropped and resized image in uint8
        % info.color: the average color in uint8 [r, g, b]
        % info.time:  how many times the image has been used (default = 0)
        puzzle_list = loadlist(puzzle_dir, puzzle_size);
        save('image_data.mat', 'puzzle_list');
    else
        load('image_data.mat', 'puzzle_list');
    end
elseif nargin == 6
    temp_image = get_square(imread(puzzle_image), puzzle_size);
    puzzle_list(1).image = temp_image;
    puzzle_list(1).rgb = get_color(temp_image);
    puzzle_list(1).time = 0;
    puzzle_list(1).last = -1;
end

% Check whether the puzzle count is enough
if repeat > 0 && repeat * length(puzzle_list) < height * width
    error(['Not enough puzzles, ', num2str(repeat * length(puzzle_list)), num2str(height * width)]);
end

result = redraw(small_origin, puzzle_list, repeat, overlap);
imshow(result);
[dic, name, extension] = fileparts(file_name);
if ~isempty(dic)
    dic = [dic, '\\'];
end
% extension = '.jpg';
imwrite(result, [dic, name, ' - output', extension]);
if nargout > 0
    varargout{1} = result;
end

function result = redraw(origin, puzzle_list, repeat, overlap)
% Redraw the original image with puzzle_list
narginchk(2, 4);
if nargin < 3
    repeat = 0;% No limitation of repeat time
end
if nargin < 4
    overlap = 0;% don't multiply
end

[w, ~, ~] = size(puzzle_list(1).image);
[hp, wp, ~] = size(origin);
result = gpuArray(zeros(w * hp, w * wp, 3));
max = hp * wp;
h = waitbar(0, 'Generating image......');
for ii = 1:hp
    for jj = 1:wp
        rgb = reshape(origin(ii,jj,:), 1, 3);
        [puzzle, index] = find_best(rgb, puzzle_list);
        % repeat time
        puzzle_list(index).time = puzzle_list(index).time + 1;
        if repeat ~= 0 && puzzle_list(index).time > repeat
            puzzle_list(index) = [];
        end
        % color shift
        if overlap
            puzzle = rgb_shift(puzzle, rgb);
        end
        result(1+(ii-1)*w:ii*w,1+(jj-1)*w:jj*w,:) = puzzle;
        p = (ii - 1) * hp + jj;
        str = ['Generating ', num2str(p), '/', num2str(max)];
        waitbar(p / max, h, str);
    end
end
close(h);
result = uint8(gather(result));

function puzzlelist = loadlist(puzzle_dir, puzzle_size, count)
% Load the puzzle list
narginchk(2, 3);
files = dir([puzzle_dir, '*.jpg']);
if nargin < 3
    count = length(files);
end
% An empty struct to initialize the puzzle list
info.image = zeros(puzzle_size, puzzle_size, 3);
info.color = zeros(1, 3);
info.time = 0;
puzzlelist = repmat(info, count, 1);
h = waitbar(0, 'Loading puzzle list......');
p = 0;
for i = 1:count
    im = imread([puzzle_dir, files(i).name]);
    im = get_square(im, puzzle_size);
    info.image = im;
    info.color = get_color(im);
    info.time = 0;
    info.last = 0;
    puzzlelist(i) = info;
    p = p + 1;
    str = ['Loading ', num2str(p), '/', num2str(count)];
    waitbar(p / count, h, str);
end
close(h);

function [result, index] = find_best(rgb, puzzle_list)
% find the image with most similiar average color in puzzle list
if length(puzzle_list) == 1
    result = puzzle_list(1).image;
    index = 1;
    return;
end
index = 0;
big = 195075; % 3*255^2
for i = 1:length(puzzle_list)
    value = sum((double(rgb) - double(puzzle_list(i).color)).^2);
    if value < big
        index = i;
        big = value;
    end
end
% when puzzle is not enough, ignore the best match
if index == 0
    index = ceil(rand() * length(puzzle_list));
end
result = puzzle_list(index).image;

function result = create_pure(rgb, len)
% Create a pure color image with the color RGB and size of IM
result = uint8(zeros(len, len, 3));
for i = 1:3
    result(:,:,i) = rgb(i);
end

function result = rgb_shift(im, rgb)
% Shift the average rgb of IM to the target RGB
d_rgb = double(get_color(im)) - double(rgb);
im = double(im);
for i = 1:3
    im(:,:,i) = im(:,:,i) - d_rgb(i);
end
im(im > 255) = 255;
im(im < 0) = 0;
result = uint8(im);

function result = multiply(im1, im2)
% The same as the Multiply in Photoshop
im1 = double(im1);
im2 = double(im2);
result = uint8(im1 .* im2 / 255);

function result = get_square(im, len)
% Get the center square of the IM and resize the side length to LEN
% Assume the im is not gray scale
[height, width, ~] = size(im);
if height == width
    result = imresize(im, [len, len]);
    return;
end
result = imresize(im, len / min(width, height));

[height, width, ~] = size(result);
if width > height
    x = round((width - height) / 2);
    y = 1;
elseif width < height
    x = 1;
    y = round((height - width) / 2);
end
result = imcrop(result, [x, y, len - 1, len - 1]);

function rgb = get_color(im)
% Get the average RGB of the IM
rgb = reshape(uint8(mean(mean(im))), 1, 3);