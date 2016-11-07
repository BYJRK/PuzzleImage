# PuzzleImage
This code will achieve redrawing an image with large quantities of puzzle images. The parameter list is shown below:


| Index | Parameter    | Description                                            | Default  |
|-------|:-------------|:-------------------------------------------------------|:---------|
| 1     | filename     | the original image to be transformed                   | lena.bmp |
| 2     | puzzle_size  | the side length of puzzle image (square)               | 30       |
| 3     | origin_size  | the maximum pixel number of the side length of origin  | 120      |
| 4     | repeat       | the largest repeat time of each puzzle (0 = unlimited) | 5        |
| 5     | overlap      | shift the rgb of puzzle to match every pixel           | 0        |
| 6     | puzzle_image | use a single puzzle image instead of a group of images | -        |

The puzzle images should be put in a folder named "images" at the same directory as the source code. Once scaned the puzzle images, there will be a .mat file named "image_data.mat" created in the same directory, which will save time for the next experience if and only if the puzzle_size remains the same.
