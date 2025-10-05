% importing image
oImg = imread('Q3-Automated Screw Batch Inspection.png');

% displaying image
figure; imshow(oImg);
title('Original Image');

% converting to grayscale, even though image is already grayscale
gImg = rgb2gray(oImg);

% increasing contrast to make screws stand out more
cImg = adapthisteq(gImg);

% applying filter to smooth image
fImg = medfilt2(cImg, [3 3]);

% sharpening the edges of the image
sImg = imsharpen(fImg, 'Radius', 2, 'Amount', 1.5);

% displaying all images
figure;
subplot(2,2,1); imshow(oImg); title('Original image');
subplot(2,2,2); imshow(cImg); title('Grayscale image');
subplot(2,2,3); imshow(fImg); title('filtered image');
subplot(2,2,4); imshow(sImg); title('sharpened image');

imwrite(enhImg, 'Q3.Enhanced Image.jpg');

% question 2
% thrshold and segmenting the screws

enhImg = imread('Q3.Enhanced Image.jpg');

% converting to grayscale
if size(enhImg,3)==3
    enhImg = rgb2gray(enhImg);
else
    grayImg = enhImg;
end

% display image
figure; imshow(grayImg);
title('Grayscale Image');

% applying thresholding (chosen otsu method)
level = graythresh(grayImg);
bmImg = imbinarize(grayImg, level);

if mean(grayImg(bmImg)) > mean(grayImg(~bmImg))
    bmImg = ~bmImg; % inverting image if screws are black
end

% morphological clean up
bmImg = imopen(bmImg, strel('disk', 3));
bmImg = imclose(bmImg, strel('disk', 3));
bmImg = imfill(bmImg, 'holes');

% plotting the result
figure; 
subplot(1,2,1); imshow(grayImg); title('Grayscale Image');
subplot(1,2,2); imshow(bmImg); title('Binary Mask Image');
imwrite(bmImg, 'Q3.Binary Mask Image.jpg');

% question 3

binaryMask = imread('Q3.Binary Mask Image.jpg');

% just to ensure its binary
binaryMask = imbinarize(binaryMask);

% removing noise
cleanMask = bwareaopen(binaryMask, 200);
cleanMask = imfil(cleanMask, 'holes');

% smoothing the mask edges
seImg = strel('disk', 3); % structuring element
cleanMask = imclose(cleanMask, seImg);
cleanMask = imopen(cleanMask, seImg);

% displaying the images
figure;
subplot(1,2,1); imshow(binaryMask); title('Binary Mask Image');
subplot(1,2,2); imshow(cleanMask); title('Cleaned Mask Image');
imwrite(cleanMask, 'Q3.Cleaned Mask Image.jpg');

% question 4
originalImg = imread('Q3-Automated Screw Batch Inspection.png');
cleanMask = imread('Q3.Cleaned Mask Image.jpg');

% ensuring mask is binary
cleanMask = imbinarize(cleanMask);

% boundaries of segemented objects
boundaries = bwboundaries(cleanMask);

% display original image
imshow(originalImg);
hold on;
title('Detected Screws');

% overlaying the segemented outlines
for k = 1:length(boundaries)
    boundary=boundaries{k};
    plot(boundary(:,2), boundary(:,1), 'r', 'LineWidth',2)
end

title('Segementation outlines overlaid on original image');

frame=getframe(gca);
imwrite(frame.cdata, 'Q3.Segementation outlines overlaid on original image.jpg');