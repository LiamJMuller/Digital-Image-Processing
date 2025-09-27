oImg = imread('Q2.Restoring the Past.jpg');

% Convert to grayscale, but not needed in this instance
% image is already grayscale
if size(oImg,3)==3
    oImg = rgb2gray(oImg);
end

% converting to double for processing
% This helps when doing calculations
oImg = im2double(oImg);

% enhancing the image
enhImg = histeq(uint8(oImg));
