% importing image
[Img, ~, alpha] = imread('Q3-Automated Screw Batch Inspection.png');
if size(Img, 3) == 4
    Img = Img(:,:,1:3); % removing the alpha channel
end
% imshow(Img);

% displaying image
figure; imshow(Img);
title('Original Image');

% converting to grayscale, even though image is already grayscale
gImg = im2gray(Img);

% increasing contrast to make screws stand out more
cImg = adapthisteq(gImg);

% applying filter to smooth image
fImg = medfilt2(cImg, [3 3]);

% sharpening the edges of the image
sImg = imsharpen(fImg, 'Radius', 2, 'Amount', 1.5);

% displaying all images
figure;
subplot(2,2,1); imshow(Img); title('Original image');
subplot(2,2,2); imshow(cImg); title('Grayscale image');
subplot(2,2,3); imshow(fImg); title('filtered image');
subplot(2,2,4); imshow(sImg); title('sharpened image');

imwrite(sImg, "Q3a.Enhanced Image.jpg");

% question 2
% thrshold and segmenting the screws
enhImg = imread('Q3a.Enhanced Image.jpg');

% converting to grayscale
if size(enhImg,3)==3
    enhImg = im2gray(enhImg);
else
    grayImg = enhImg;
end

% display image
figure; imshow(grayImg);
title('Grayscale Image');

background = imopen(grayImg, strel('disk', 30));
corrImg = imsubtract(grayImg, background);
corrImg = imadjust(corrImg)

% applying thresholding (chosen otsu method)
% level = graythresh(corrImg);
bmImg = imbinarize(corrImg, 'adaptive',...
    'Sensitivity', 0.45);

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
imwrite(bmImg, 'Q3b.Binary Mask Image.jpg');

% question 3

binaryMask = imread('Q3b.Binary Mask Image.jpg');

% just to ensure its binary
binaryMask = imbinarize(binaryMask);

% removing noise
cleanMask = bwareaopen(binaryMask, 200);
cleanMask = imfill(cleanMask, 'holes');

% smoothing the mask edges
seImg = strel('disk', 3); % structuring element
cleanMask = imclose(cleanMask, seImg);
cleanMask = imopen(cleanMask, seImg);

% displaying the images
figure;
subplot(1,2,1); imshow(binaryMask); title('Binary Mask Image');
subplot(1,2,2); imshow(cleanMask); title('Cleaned Mask Image');
imwrite(cleanMask, 'Q3c.Cleaned Mask Image.jpg');

% question 4
% originalImg = imread('Q3-Automated Screw Batch Inspection.png');
cleanMask = imread('Q3c.Cleaned Mask Image.jpg');

% ensuring mask is binary
cleanMask = imbinarize(cleanMask);

% boundaries of segemented objects
boundaries = bwboundaries(cleanMask);

% display original image
imshow(Img);
hold on;
title('Detected Screws');

% overlaying the segemented outlines
for k = 1:length(boundaries)
    boundary=boundaries{k};
    plot(boundary(:,2), boundary(:,1), 'r', 'LineWidth',2)
end

title('Segementation outlines overlaid on original image');

frame=getframe(gca);
imwrite(frame.cdata, 'Q3d.Segementation outlines overlaid on original image.jpg');