function [blue, blueArea] = getBluePos(image)
% input: image you want to process
% output: four arrays, one for each marker giving the 2d position and the 3
%d translation to the tip of the instrument

% distance from the camera to the tools in cm
depth = 50;

%% Image processing

% HSV image to get the saturation channel
hsv_image   = rgb2hsv(image);
imageSat    = hsv_image(:,:,2);

% RGB channels
imageRed    = image(:,:,1);
imageGreen  = image(:,:,2);
imageBlue   = image(:,:,3);

% Take off pixels with high values in the three RGB channels
backgrThres = 110; %depending on the light (image calibration)
for i = 1:length(image(:,1,1))
    for j = 1:length(image(1,:,1))
        if (imageRed(i,j) > backgrThres ...
                && imageGreen(i,j) > backgrThres ...
                && imageBlue(i,j) > backgrThres)
            imageRed(i,j) = 0;
            imageGreen(i,j) = 0;
            imageBlue(i,j) = 0;
        end
    end
end

% Generation of the mask --------------------------------------------------

% Thresholds definition
% RGB channels
levelR = graythresh(imageRed);
levelB = graythresh(imageBlue);
% Saturation channel
levelS = graythresh(imageSat);

% Thresholding RGB
origRedMask     = im2bw(imageRed, levelR);
origBlueMask    = im2bw(imageBlue, levelB);
% Thresholding HSV
satMask = im2bw(imageSat, levelS);

% Combination of RGB masks
blueMask = satMask & origBlueMask & ~origRedMask; % blue marker usualy has green too

% Elimitation of small objects --------------------------------------------

% aprox length of the long side
imageSizeCM = depth * 1.05;
markerSize = length(image(:,1))/imageSizeCM;
markerArea = markerSize * markerSize /4;

% Get rid of small objects
blueMask    = bwareafilt(blueMask, [markerArea/2 inf]);

% Reconstruction of the segmented image -----------------------------------
% reconstruct an image with all the channels
all(:,:,1) = uint8(blueMask) .* imageRed;
all(:,:,2) = uint8(blueMask) .* imageGreen;
all(:,:,3) = uint8(blueMask) .* imageBlue;
%% Labeling and identification
% Blue --------------------------------------------------------------------
% label the image
[LBlue,numBlue] = bwlabel(blueMask);

% get the centroids
sBlue = regionprops(LBlue,'centroid', 'BoundingBox', 'area');
centroidsBlue = cat(1, sBlue.Centroid);
areas = cat(1, sBlue.Area);
% create a matrix with
%   - as many rows as labels there are
%   - 4 columns (one for the label number, 2 for the centroid pos, 1 for the
%   color.
listMarkersBlue = zeros(numBlue,4);

% initialize the max values of each channel and their index in the list
maxBlue = 0;
maxIndBlue = -1;

for i = 1:numBlue
    % LABEL NAME
    listMarkersBlue(i,1) = i;
    
    % CENTROID POSITION
    listMarkersBlue (i,2) = centroidsBlue(i, 1);
    listMarkersBlue(i,3) = centroidsBlue(i, 2);
    
    color = impixel (all, centroidsBlue(i,1), centroidsBlue(i,2));
    [maxColor,Index] = max(color);
    
    listMarkersBlue(i,4) = Index;
    if (maxColor == 0)
        listMarkersBlue(i,4) = 0;
        
        % find the higher values
    else
        if maxColor > maxBlue
            maxBlue = maxColor;
            maxIndBlue = i;
        end
    end
end

%% Ploting and giving output
%figure,
% imshow (image);
% hold on
%
% if maxIndBlue ~= -1
%     plot (listMarkersBlue(maxIndBlue,2), listMarkersBlue(maxIndBlue,3),'b*')
%     hold on
% end

%% Output

%dist in mm
%red 105 yellow 25 green 130 blue 30 mm
d4 = 30;
blueArea = 0;

x4 = 0; y4 = 0;
% blue marker
if maxIndBlue~= -1
    x4 = listMarkersBlue(maxIndBlue,2);
    y4 = listMarkersBlue(maxIndBlue,3);
    blueArea = areas(maxIndBlue);
end

blue = [x4 y4 0 0 d4];
end