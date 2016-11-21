function [markersPos] = getMarkersPos(image)
% input: image you want to process
% output: a matrix called markersPos with the position of the markers, one
% for each color.
% we get two red markers, two blue and one green

close all;

% distance from the camera to the tools in cm
depth = 64;

% Load the image (comment if using a video)
% image = imread(image);

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

% Thresholding RGB 
redMask     = im2bw(imageRed, levelR);
greenMask   = im2bw(imageGreen, levelG);
blueMask    = im2bw(imageBlue, levelB);

% Thresholding Saturation
satMask     = im2bw(imageSat, levelS);

% Combination of RGB masks
redMask = redMask & ~greenMask & ~blueMask;
greenMask = greenMask & ~redMask & ~blueMask;
blueMask = blueMask & ~redMask; % blue marker usualy has green too

% Elimitation of small objects --------------------------------------------

% aprox length of the long side
imageSizeCM = depth * 1.05;
markerSize = length(image(:,1))/imageSizeCM;
% area = long side * short side (1/4 of the long one)
markerArea = markerSize * markerSize /4;

% Get rid of small objects
redMask     = bwareafilt(redMask, [markerArea/2 inf]);
greenMask   = bwareafilt(greenMask, [markerArea/2 inf]);
blueMask    = bwareafilt(blueMask, [markerArea/2 inf]);
satMask     = bwareafilt(satMask, [markerArea/2 inf]);

% Reconstruction of the segmented image -----------------------------------

% create a mask of the three colors
finalMask = satMask & (redMask | greenMask | blueMask);

% erode the mask
finalMask = imerode(finalMask, strel('diamond',5));

% reconstruct an image with all the markers
all(:,:,1) = uint8(finalMask) .* imageRed;
all(:,:,2) = uint8(finalMask) .* imageGreen;
all(:,:,3) = uint8(finalMask) .* imageBlue;

%% Labeling and identification

% label the image
[L,num] = bwlabel(finalMask);

% get the centroids
s = regionprops(L,'centroid', 'BoundingBox', 'area');
centroids = cat(1, s.Centroid);

% go through all the centroids and check to what color they correspond
% create a matrix with
%   - as many rows as labels there are
%   - 4 columns (one for the label number, 2 for the centroid pos, 1 for the
%   color.
listMarkers = zeros(num,4);
% initialize the max values of each channel and their index in the list
maxRed = 0;
maxRed2 = 0;
maxIndRed = -1;
maxIndRed2 = -1;

maxGreen = 0;
maxIndGreen = -1;

maxBlue = 0;
maxBlue2 = 0;
maxIndBlue = -1;
maxIndBlue2 = -1;


for i = 1:num
    % LABEL NAME
    listMarkers (i,1) = i;
    % CENTROID POSITION
    listMarkers (i,2) = centroids(i, 1);
    listMarkers (i,3) = centroids(i, 2);
    % COLOR
    % if not all 3 channels are 0
    % See the colors of the centroid
    color = impixel (all, centroids(i,1), centroids(i,2));
    [maxColor,Index] = max(color);
    
    % If the color is   red     then put    1
    %                   green               2
    %                   blue                3
    %                   none                0
    listMarkers(i,4) = Index;
    if (maxColor == 0)
        listMarkers(i,4) = 0;
    end
    
    % colors ordered in ascending order
    sortedColor = sort(color);
    
    % if the two bigger colors are almost the same and red is low
    % then its a glove so I put it at 0
    % GLOVE
    if (abs(sortedColor(2)-sortedColor(3)) < 10 && sortedColor(1) == color(1))
        listMarkers(i,4) = 0;
    end
    
    % Take off red stuff that is not the red marker
    % the red marker has very low green and blue values
    % RED BUT NOT A MARKER
    if (Index == 1 && ~(sortedColor(1)< 30 && sortedColor(2) < 30))
           % if it's detected as red marker but blue and green are very low
        listMarkers(i,4) = 0;
    end
    
    % find the higher values
    % for red
    if listMarkers(i,4) == 1
        if maxColor > maxRed
            maxRed2 = maxRed;
            maxRed = maxColor;
            maxIndRed2 = maxIndRed;
            maxIndRed = i;
        end
    end
    
    % for green
    if listMarkers(i,4) == 2
        if maxColor > maxGreen
            maxGreen = maxColor;
            maxIndGreen = i;
        end
    end
    
    % for blue
    if listMarkers(i,4) == 3
        if maxColor > maxBlue
            maxBlue2 = maxBlue;
            maxBlue = maxColor;
            maxIndBlue2 = maxIndBlue;
            maxIndBlue = i;
        end
    end
end

%% Ploting and giving output
figure, imshow (image);
hold on

% If you want to plot only the higher marker of each color-----------------
if maxIndRed ~= -1
    plot (listMarkers(maxIndRed,2), listMarkers(maxIndRed,3),'r*')
    hold on
    if maxIndRed2 ~= -1
        plot (listMarkers(maxIndRed2,2), listMarkers(maxIndRed2,3),'ro')
        hold on
    end
end
if maxIndGreen ~= -1
    plot (listMarkers(maxIndGreen,2), listMarkers(maxIndGreen,3),'g*')
    hold on
end
if maxIndBlue ~= -1
    plot (listMarkers(maxIndBlue,2), listMarkers(maxIndBlue,3),'b*')
    hold on
    if maxIndBlue2 ~= -1
        plot (listMarkers(maxIndBlue2,2), listMarkers(maxIndBlue2,3),'bo')
        hold on
    end
end
hold off

% If you want to plot all the detected markers ----------------------------
% for i = 1:num
%     % establish criteria:
%     % - if the centroid is inside the marker
%     if (listMarkers(i,4)~= 0 )
%         % plot red
%         if (listMarkers(i,4) == 1)
%             plot (listMarkers(i,2), listMarkers(i,3),'r*')
%             hold on
%         end
%         % plot green
%         if (listMarkers(i,4) == 2)
%             plot (listMarkers(i,2), listMarkers(i,3),'g*')
%             hold on
%         end
%         % plot blue
%         if (listMarkers(i,4) == 3)
%             plot (listMarkers(i,2), listMarkers(i,3),'b*')
%             hold on
%         end
%     end
% end

% Output: markersPosition -------------------------------------------------
% markersPos has te position in 2D (x,y) of the red, green and blue markers
% respectively

markersPos = zeros(3,2);

% red marker
if maxIndRed~= -1
    markersPos(1,:) = [listMarkers(maxIndRed,2), listMarkers(maxIndRed,3)];
end

% green marker
if maxIndGreen~= -1
    markersPos(2,:) = [listMarkers(maxIndGreen,2), listMarkers(maxIndGreen,3)];
end

% blue marker
if maxIndBlue~= -1
    markersPos(3,:) = [listMarkers(maxIndBlue,2), listMarkers(maxIndBlue,3)];
end

end