oImg = imread('Q2.Restoring the Past.jpg');

% Convert to grayscale, but not needed in this instance
% image is already grayscale
if size(oImg,3)==3
    oImg = rgb2gray(oImg);
end

% converting to double for processing
% This helps when doing calculations
oImg = im2double(oImg);

% 3 ways to enhance the image
% 1. Histogram Equalization
%enhImg1 = histeq(uint8(oImg));
engImg1 = adapthisteq(oImg, 'ClipLimit',0.02);
% 2. Contrast Stretching
% changes the range of contrast 0-255
min_val=min(oImg(:));
max_val=max(oImg(:));
enhImg2 = (oImg - min_val) / (max_val - min_val)*5;
% 3. Gamma Correction
gamma=0.5; % 0.5 brighten, 2 darkens
enhImg3=255*((oImg/255).^gamma);

% selecting the best enhancement
enhImg = engImg1; % Histogram Equalization is the best

% optionally adding colour
enhColour = zeros(size(enhImg,1), size(enhImg,2),3);
% sepia tones
%enhColour(:,:,1) = min(enhImg * 1.0, 255); % Red channel
%enhColour(:,:,2) = min(enhImg * 1.0, 255); % Green channel
%enhColour(:,:,3) = min(enhImg * 1.0, 255); % Blue channel

% warm vintage tones
enhColour(:,:,1)=min(255, enhImg*1.05+0.5); % Red channel
enhColour(:,:,2)=min(255, enhImg*0.98+0.02); % Green channel
enhColour(:,:,3)=min(255, enhImg*0.85);    % Blue channel

enhColour=min(enhColour,255); % ensure no values above 255
enhColour=uint8(enhColour);

% displyaing images
figure('Name','Image Enhancement','Position',[100 100 1200 400]);

% original image
subplot(1,3,1);
imshow(oImg);
title('Original Image', 'FontSize', 14, 'FontWeight', 'bold');

% enhanced image
subplot(1,3,2);
imshow(enhImg);
title('Enhanced Image', 'FontSize', 14, 'FontWeight', 'bold');

% enhanced colour image
subplot(1,3,3);
imshow(enhColour);
title('Enhanced Colour Image', 'FontSize', 14, 'FontWeight', 'bold');