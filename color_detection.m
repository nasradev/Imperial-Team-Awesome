clear;
close all;
FileName='olivier_1_trimmed.MOV';
% Load the video
obj = mmreader(FileName);
video = obj.read();
%Then, frame #K is 
for k =1:10
image = video(:,:,:,k);

% Load the image
%image = imread('IMG_5573.JPG');

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
% redThresholdLow = 120;%
% redThresholdHigh = 255;
% redMask = (noBack_r >= redThresholdLow) & (noBack_r <= redThresholdHigh);
levelR = graythresh(noBack_r);
redMask = im2bw(noBack_r, levelR);

%Threshold green
% greenThresholdLow = 120;
% greenThresholdHigh = 255;
% greenMask = (noBack_g >= greenThresholdLow) & (noBack_g <= greenThresholdHigh);
levelG = graythresh(noBack_g);
greenMask = im2bw(noBack_g, levelG);

%Threshold blue
% blueThresholdLow = 120;
% blueThresholdHigh = 255;
% blueMask = (noBack_b >= blueThresholdLow) & (noBack_b <= blueThresholdHigh);
levelB = graythresh(noBack_b);
blueMask = im2bw(noBack_b, levelB);

% Get rid of small objects.
% First an erosion, then only keep objects between 900 and 5000 px and
% finally a dilatation
redMask = imerode(redMask, strel('diamond', 2));
redMask = imdilate(redMask, strel('diamond', 3));
redMask = bwareafilt(redMask,[2000 200000]);
 
greenMask = imerode(greenMask , strel('diamond', 2));
greenMask = imdilate(greenMask , strel('diamond', 3));
greenMask = bwareafilt(greenMask ,[2000 200000]);
 
blueMask = imerode(blueMask , strel('diamond', 2));
blueMask = imdilate(blueMask , strel('diamond', 3));
blueMask = bwareafilt(blueMask ,[2000 200000]);

% Labeling
% [LR,numR] = bwlabel(redMask);
% [LG,numG] = bwlabel(greenMask);
% [LB,numB] = bwlabel(blueMask);

sR = regionprops(redMask,'centroid');
centroidsR = cat(1, sR.Centroid);


%% Reconstruction

%reconstruct red image
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

figure, imshow(imageR), 
hold on
plot(centroidsR(:,1),centroidsR(:,2), 'b*')
hold off
figure, imshow(imageG);
hold on
plot(centroidsG(:,1),centroidsG(:,2), 'b*')
hold off
figure, imshow(imageB);
hold on
plot(centroidsB(:,1),centroidsB(:,2), 'b*')
hold off 
framesR(k)=imageR;
framesG(k)=imageG;
framesB(k)=imageB;
end