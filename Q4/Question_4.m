% question 4.a
img = imread('Q4_Ink to Pixels Business Challenge in Handwriting Digitization.jpg');

% Convert to grayscale
grayImg = rgb2gray(img);
imshow(grayImg);
title('Grayscale Image');

% denoising the image
denoisedImg = medfilt2(grayImg, [2 2]);
figure, imshow(denoisedImg);
title('Denoised Image');

% sharpening image
sharpenedImg = imsharpen(denoisedImg);
figure, imshow(sharpenedImg);
title('Sharpened Image');

% contrast enhancement
enhancedImg = imadjust(sharpenedImg);
figure, imshow(enhancedImg);

% Binarization
bw = imbinarize(enhancedImg, 'adaptive', 'ForegroundPolarity', 'dark', 'Sensitivity', 0.19);
figure, imshow(bw);
title('Binarized Image');

% saving all the images
% imwrite(bwImg, 'Q4a.Enhanced Image.jpg');

% question 4.b
% added as an optional extra to increase image quality
%bw = imfill(bwImg, 'holes'); % filling in the small holes in the text
%bw = imdilate(bw, strel('disk', 1)); % dilating the image to make text more clear
%figure, imshow(bw); title('Post=processed Binary image');

% OCR
ocrInput = uint8(bw) * 255;
ocrResults = ocr(ocrInput, 'Layout', 'block'); % use 'Word' or 'Block'

% Display recognized text
ocrImage = insertObjectAnnotation(ocrInput, 'rectangle', ...
    ocrResults.WordBoundingBoxes, ...
    ocrResults.Words);
figure, imshow(ocrImage), title('Recognised Text in the image');

% displaying the text recognised
recogText = ocrResults.Text;
disp('================= Recognised Text ================');
disp(recogText);
disp('==================================================');

% saving the recognised text to a .txt file
fid = fopen('ExtractedTextOutput.txt', 'w');
fprintf(fid, '%s', recogText);
fclose(fid);
