function [green, greenArea] = getGreenPos(image)
% input: image you want to process
% output: array (1x5) of the green marker giving the 2d position and the 3
% d translation to the tip of the instrument

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

%Thresholds definition
% RGB channels
levelR = graythresh(imageRed);
levelG = graythresh(imageGreen);
levelB = graythresh(imageBlue);
% Saturation channel
levelS = graythresh(imageSat);

% Thresholding RGB
origRedMask     = im2bw(imageRed, levelR);
origGreenMask   = im2bw(imageGreen, levelG);
origBlueMask    = im2bw(imageBlue, levelB);
% Thresholding HSV
satMask = im2bw(imageSat, levelS);

% Combination of RGB masks
greenMask = satMask & origGreenMask & ~origRedMask & ~origBlueMask;

% Elimitation of small objects --------------------------------------------

% aprox length of the long side
imageSizeCM = depth * 1.05;
markerSize = length(image(:,1))/imageSizeCM;
markerArea = markerSize * markerSize /4;

% Get rid of small objects
greenMask   = bwareafilt(greenMask, [markerArea/2 inf]);

% Reconstruction of the segmented image -----------------------------------
% reconstruct an image with all the channels
all(:,:,1) = uint8(greenMask) .* imageRed;
all(:,:,2) = uint8(greenMask) .* imageGreen;
all(:,:,3) = uint8(greenMask) .* imageBlue;

%% Labeling and identification
% Green --------------------------------------------------------------------
% label the image
[LGreen,numGreen] = bwlabel(greenMask);

% get the centroids
sGreen = regionprops(LGreen,'centroid', 'area');
centroidsGreen = cat(1, sGreen.Centroid);
areas = cat(1, sGreen.Area);
% create a matrix with
%   - as many rows as labels there are
%   - 4 columns (one for the label number, 2 for the centroid pos, 1 for the
%   color.
listMarkersGreen = zeros(numGreen,4);

% initialize the max values of each channel and their index in the list
maxGreen= 0;
maxIndGreen = -1;

for i = 1:numGreen
    % LABEL NAME
    listMarkersGreen (i,1) = i;
    
    % CENTROID POSITION
    listMarkersGreen (i,2) = centroidsGreen(i, 1);
    listMarkersGreen(i,3) = centroidsGreen(i, 2);
    
    color = impixel (all, centroidsGreen(i,1), centroidsGreen(i,2));
    [maxColor,Index] = max(color);
    
    listMarkersGreen(i,4) = Index;
    if (maxColor == 0)
        listMarkersGreen(i,4) = 0;
        
        % find the higher values
        % for red
    else
        if maxColor > maxGreen
            %maxRed2 = maxRed;
            maxGreen = maxColor;
            %maxIndRed2 = maxIndRed;
            maxIndGreen = i;
        end
    end
end

%% Ploting and giving output
%figure,
% imshow (image);
% hold on
%
% If you want to plot only the higher marker of each color-----------------
% if maxIndGreen ~= -1
%     plot (listMarkersGreen(maxIndGreen,2), listMarkersGreen(maxIndGreen,3),'g*')
%     hold on
% end

%% Output

% dist in mm
% red 105 yellow 25 green 130 blue 30 mm
d3 = 70;
greenArea = 0;

x3 = 0; y3 = 0;
% green marker
if maxIndGreen~= -1
    x3 = listMarkersGreen(maxIndGreen,2);
    y3 = listMarkersGreen(maxIndGreen,3);
    greenArea = areas(maxIndGreen);
end

green = [x3 y3 0 0 d3];
end