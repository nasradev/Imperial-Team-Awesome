% Load the image
image = imread('IMG_5573.JPG');

% Separate in three RGB channels
im_r = image(:,:,1);
im_g = image(:,:,2);
im_b = image(:,:,3);

%% take off the white background (if any)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% % histograms of the three channels
% [countsR,binLocationsR] = imhist(im_r);
% [countsG,binLocationsG] = imhist(im_g);
% [countsB,binLocationsB] = imhist(im_b);
% 
% % get the maximum number of pixels with one same value in each channel
% Rmax = max(countsR);
% Gmax = max(countsG);
% Bmax = max(countsB);
% 

% Initialise 
noBack_r = im_r;
noBack_g = im_g;
noBack_b = im_b;
for i = 1:length(image(:,1,1))
    for j = 1:length(image(1,:,1))
        if (im_r(i,j) > 150 && im_g(i,j) > 150 && im_b(i,j) > 150)
            noBack_r(i,j) = 0;
            noBack_g(i,j) = 0;
            noBack_b(i,j) = 0;
        end
    end
end

%% Thresholding 

%Threshold red
% redThresholdLow = 120;%graythresh(im_r);
% redThresholdHigh = 255;
% redMask = (noBack_r >= redThresholdLow) & (noBack_r <= redThresholdHigh);

% level = multithresh(noBack_r,2);
% seg_I = imquantize(noBack_r,level);
% redMask = label2rgb(seg_I);

level = graythresh(noBack_r);
redMask = im2bw(noBack_r,level);


%Threshold green
% greenThresholdLow = 120;
% greenThresholdHigh = 255;
% greenMask = (noBack_g >= greenThresholdLow) & (noBack_g <= greenThresholdHigh);
level = graythresh(noBack_g);
greenMask = im2bw(noBack_g,level);

%Threshold blue
% blueThresholdLow = 120;
% blueThresholdHigh = 255;
% blueMask = (noBack_b >= blueThresholdLow) & (noBack_b <= blueThresholdHigh);
level = graythresh(noBack_b);
blueMask = im2bw(noBack_b,level);

% Get rid of small objects.  Note: bwareaopen returns a logical.
smallestAcceptableArea = 1000;
redObjectsMask = uint8(bwareaopen(redMask, smallestAcceptableArea));

%% Reconstruction

%reconstruct red image
% imageR(:,:,1) = uint8(redMask(:,:,1)) .* noBack_r;
% imageR(:,:,2) = uint8(redMask(:,:,2)) .* noBack_g;
% imageR(:,:,3) = uint8(redMask(:,:,3)) .* noBack_b;
imageR(:,:,1) = uint8(redMask) .* noBack_r;
imageR(:,:,2) = uint8(redMask) .* noBack_g;
imageR(:,:,3) = uint8(redMask) .* noBack_b;

%reconstruct green image
imageG(:,:,1) = uint8(greenMask) .* noBack_r;
imageG(:,:,2) = uint8(greenMask) .* noBack_g;
imageG(:,:,3) = uint8(greenMask) .* noBack_b;

%reconstruct blue image
imageB(:,:,1) = uint8(blueMask) .* noBack_r;
imageB(:,:,2) = uint8(blueMask) .* noBack_g;
imageB(:,:,3) = uint8(blueMask) .* noBack_b;

figure,
subplot (3,1,1), imshow(imageR),
subplot (3,1,2), imshow(imageG),
subplot (3,1,3), imshow(imageB);

imrefR=imageB;
imrefG=imageR;
imrefB=imageR;
imageR=imsubtract(imageR,imrefR);
imageG=imsubtract(imageG,imref);
imageB=imsubtract(imageB,imref);

figure,
subplot (3,1,1), imshow(imageR,[]),
subplot (3,1,2), imshow(imageG,[]),
subplot (3,1,3), imshow(imageB,[]);
