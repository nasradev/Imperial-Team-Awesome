function [red, redArea] = getRedPos(image)
% input: image you want to process
% output: four arrays, one for each marker giving the 2d position and the 3
%d translation to the tip of the instrument

% distance from the camera to the tools in cm
depth = 50;

%% Image processing

% take off the white background and shines(if any)-------------------------

% HSV image to get the saturation channel
hsv_image   = rgb2hsv(image);
imageSat    = hsv_image(:,:,2);
%imageHue = hsv_image(:,:,1);
%imageValue = hsv_image(:,:,3);

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

% enhancement of contrast: equalization histogram
%imageRed    = histeq(imageRed);
% imageGreen  = histeq(imageGreen);
% imageBlue   = histeq(imageBlue);

% Generation of the mask --------------------------------------------------

%Thresholds definition
% RGB channels
levelR = graythresh(imageRed);
levelG = graythresh(imageGreen);
levelB = graythresh(imageBlue);
% Saturation channel
levelS = graythresh(imageSat);
%levelH = graythresh(imageHue);
%levelV = graythresh(imageValue);

% Thresholding RGB
origRedMask     = im2bw(imageRed, levelR);
origGreenMask   = im2bw(imageGreen, levelG);
origBlueMask    = im2bw(imageBlue, levelB);
% Thresholding HSV
satMask = im2bw(imageSat, levelS);

% Combination of RGB masks
redMask = satMask & origRedMask & ~origGreenMask & ~origBlueMask ;

% Elimitation of small objects --------------------------------------------

% % aprox length of the long side
% imageSizeCM = depth * 1.05;
% markerSize = length(image(:,1))/imageSizeCM;
% % area = long side * short side (1/4 of the long one)
% markerArea = markerSize * markerSize /4;
% 
% % Get rid of small objects
% redMask     = bwareafilt(redMask, [markerArea/2 inf]);
redMask = imerode(redMask, strel('line',10,9));

% Reconstruction of the segmented image -----------------------------------
% reconstruct an image with all the markers
all(:,:,1) = uint8(redMask) .* imageRed;
all(:,:,2) = uint8(redMask) .* imageGreen;
all(:,:,3) = uint8(redMask) .* imageBlue;

%% Labeling and identification

% Red ---------------------------------------------------------------------
% label the image
[LRed,numRed] = bwlabel(redMask);

% get the centroids
sRed = regionprops(LRed,'centroid', 'area');
centroidsRed = cat(1, sRed.Centroid);
areas = cat(1, sRed.Area);
% create a matrix with
%   - as many rows as labels there are
%   - 4 columns (one for the label number, 2 for the centroid pos, 1 for the
%   color.
listMarkersRed = zeros(numRed,4);

% initialize the max values of each channel and their index in the list
maxRed = 0;
maxIndRed = -1;

for i = 1:numRed
    % LABEL NAME
    listMarkersRed (i,1) = i;
    
    % CENTROID POSITION
    listMarkersRed (i,2) = centroidsRed(i, 1);
    listMarkersRed (i,3) = centroidsRed(i, 2);
    
    color = impixel (all, centroidsRed(i,1), centroidsRed(i,2));
    [maxColor,Index] = max(color);
    
    listMarkersRed(i,4) = Index;
    if (maxColor == 0 || areas(i) < 50)
        listMarkersRed(i,4) = 0;
        
        % find the higher values
        % for red
    else
        if maxColor > maxRed
            %maxRed2 = maxRed;
            maxRed = maxColor;
            %maxIndRed2 = maxIndRed;
            maxIndRed = i;
        end
    end
end

%% Ploting and giving output
% figure,
% imshow (image);
% hold on
% 
% %If you want to plot only the higher marker of each color-----------------
% if maxIndRed ~= -1
%     plot (listMarkersRed(maxIndRed,2), listMarkersRed(maxIndRed,3),'r*')
%     hold on
% end

%% Output

% dist in mm
% red: 105; yellow: 25; green: 130; blue: 30 mm;
d1 = 105;
redArea = 0;
x1 = 0; y1 = 0;

% red marker_1
if maxIndRed~= -1
    x1 = listMarkersRed(maxIndRed,2);
    y1 = listMarkersRed(maxIndRed,3);
    redArea = areas(maxIndRed);
end

% give 0 in m1 because there is no red marker in this case
red = [x1 y1 0 0 d1];

end