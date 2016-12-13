function [yellow, yellowArea] = getYellowPos(image)
% input: image you want to process
% output: four arrays, one for each marker giving the 2d position and the 3
% d translation to the tip of the instrument

% distance from the camera to the tools in cm
depth = 50;

% Load the image (comment if using a video)
%% Image processing

% take off the white background and shines(if any)-------------------------

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
yellowMask = satMask & origRedMask & origGreenMask & ~origBlueMask;
yellowMask = imerode(yellowMask, strel('line',10,9));

% Elimitation of small objects --------------------------------------------

% aprox length of the long side
imageSizeCM = depth * 1.05;
markerSize = length(image(:,1))/imageSizeCM;
markerArea = markerSize * markerSize /4;

% Get rid of small objects
yellowMask    = bwareafilt(yellowMask, [markerArea/2 inf]);

%% Labeling and identification

% Yellow --------------------------------------------------------------------
% label the image
[LYellow,numYellow] = bwlabel(yellowMask);

% get the centroids
sYellow= regionprops(LYellow,'centroid', 'BoundingBox', 'area');
centroidsYellow = cat(1, sYellow.Centroid);
areas = cat(1, sYellow.Area);
% create a matrix with
%   - as many rows as labels there are
%   - 4 columns (one for the label number, 2 for the centroid pos, 1 for the
%   color.
listMarkersYellow= zeros(numYellow,4);

% initialize the max values of each channel and their index in the list
maxYellow = 0;
maxIndYellow = -1;

for i = 1:numYellow
    % LABEL NAME
    listMarkersYellow(i,1) = i;
    
    % CENTROID POSITION
    listMarkersYellow(i,2) = centroidsYellow(i, 1);
    listMarkersYellow(i,3) = centroidsYellow(i, 2);
    
    color = impixel (image, centroidsYellow(i,1), centroidsYellow(i,2));
    [maxColor,Index] = max(color);
    
    listMarkersYellow(i,4) = 4;
    if (maxColor == 0)
        listMarkersYellow(i,4) = 0;
    else
        if maxColor > maxYellow
            maxYellow = maxColor;
            maxIndYellow = i;
        end
    end
    
end

%% Ploting and giving output
%figure,
% imshow (image);
% hold on
%
% If you want to plot only the higher marker of each color-----------------
% if maxIndYellow ~= -1
%     plot (listMarkersYellow(maxIndYellow,2), listMarkersYellow(maxIndYellow,3),'y*')
%     hold on
% end

%% Output

%dist in mm
%red 105 yellow 25 green 130 blue 30 mm
d2 = 25;
yellowArea = 0;
x2 = 0; y2 = 0;
% yellow
if maxIndYellow~= -1
    x2 = listMarkersYellow(maxIndYellow,2);
    y2 = listMarkersYellow(maxIndYellow,3);
    yellowArea = areas(maxIndYellow);
end

% give 0 in m1 because there is no red marker in this case
yellow = [x2 y2 0 0 d2];
end