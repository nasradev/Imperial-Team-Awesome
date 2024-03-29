function [m1,m2,m3,m4] = getMarkerPos(image)
% input: image you want to process
% output: four arrays, one for each marker giving the 2d position and the 3
%d translation to the tip of the instrument

% distance from the camera to the tools in cm
depth = 50;

% Load the image (comment if using a video)

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
%hueMask = im2bw(imageHue, levelH);
satMask = im2bw(imageSat, levelS);
%valMask= im2bw(imageValue, levelV);

% Combining HSV masks
%blueMask= hueMask & satMask;
%yellowMask



% Combination of RGB masks
redMask = satMask & origRedMask & ~origGreenMask & ~origBlueMask ;
greenMask = satMask & origGreenMask & ~origRedMask & ~origBlueMask;
blueMask = satMask & origBlueMask & ~origRedMask; % blue marker usualy has green too
yellowMask = satMask & origRedMask & origGreenMask & ~origBlueMask;

% imshow(uint16(hsv_image(:,:,2).*hsv_image(:,:,3)),[]) % red yellow blue
% imshow(uint16(hsv_image(:,:,1).*hsv_image(:,:,2)),[]) % blue
% imshow(uint16(hsv_image(:,:,2)) % all
% r g y b
% 1 1 1 1
% 1 0 1 1

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
yellowMask    = bwareafilt(yellowMask, [markerArea/2 inf]);

% Reconstruction of the segmented image -----------------------------------

% create a mask of the three colors
%finalMask = satMask & (redMask | greenMask | blueMask);

% erode the mask
%finalMask = imerode(finalMask, strel('diamond',5));

% reconstruct an image with all the markers
all(:,:,1) = uint8(redMask) .* imageRed;
all(:,:,2) = uint8(greenMask) .* imageGreen;
all(:,:,3) = uint8(blueMask) .* imageBlue;

%% Labeling and identification

% Red ---------------------------------------------------------------------
% label the image
[LRed,numRed] = bwlabel(redMask);

% get the centroids
sRed = regionprops(LRed,'centroid', 'BoundingBox', 'area');
centroidsRed = cat(1, sRed.Centroid);
%areas = cat(1, s.Area);
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
    if (maxColor == 0)
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

% Green --------------------------------------------------------------------
% label the image
[LGreen,numGreen] = bwlabel(greenMask);

% get the centroids
sGreen = regionprops(LGreen,'centroid', 'BoundingBox', 'area');
centroidsGreen = cat(1, sGreen.Centroid);
%areas = cat(1, s.Area);
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

% Blue --------------------------------------------------------------------
% label the image
[LBlue,numBlue] = bwlabel(blueMask);

% get the centroids
sBlue = regionprops(LBlue,'centroid', 'BoundingBox', 'area');
centroidsBlue = cat(1, sBlue.Centroid);
%areas = cat(1, s.Area);
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
    % for red
    else 
        if maxColor > maxBlue
            maxBlue = maxColor;
            maxIndBlue = i;
        end
    end
end
% Yellow --------------------------------------------------------------------
% label the image
[LYellow,numYellow] = bwlabel(yellowMask);

% get the centroids
sYellow= regionprops(LYellow,'centroid', 'BoundingBox', 'area');
centroidsYellow = cat(1, sYellow.Centroid);
% areas = cat(1, s.Area);
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
% --------------------------------------------------------
%% OLD CODE
% maxYellow=0;
% maxIndYellow = -1;
% 
% maxGreen = 0;
% maxIndGreen = -1;
% 
% maxBlue = 0;
% %maxBlue2 = 0;
% maxIndBlue = -1;
% %maxIndBlue2 = -1;
% 
% 
% for i = 1:num
%     % LABEL NAME
%     listMarkers (i,1) = i;
%   %  A_listMarkers(i,1)=i;
%     % CENTROID POSITION
%     listMarkers (i,2) = centroids(i, 1);
%     listMarkers (i,3) = centroids(i, 2);
% %    A_listMarkers (i) = areas(i);
%     % COLOR
%     % if not all 3 channels are 0
%     % See the colors of the centroid
%     color = impixel (all, centroids(i,1), centroids(i,2));
%     [maxColor,Index] = max(color);
%     
%     % If the color is   red     then put    1
%     %                   green               2
%     %                   blue                3
%     %                   yellow              4
%     %                   none                0
%     listMarkers(i,4) = Index;
%     if (maxColor == 0)
%         listMarkers(i,4) = 0;
%     end
%     
%     % colors ordered in ascending order
%     sortedColor = sort(color);
%     
%     % if red and green are very big and blue almost zero
%     % then its is yellow
%     % YELLOW
%     if (sortedColor(3)> 120 && sortedColor(2)> 120 && sortedColor(1) < 50 ...
%            && Index ~= 3)
%         listMarkers(i,4) = 4;
%     end    
%     % if the two bigger colors are almost the same and red is low
%     % then its a glove so I put it at 0
%     % GLOVE
%     if (abs(sortedColor(2)-sortedColor(3)) < 10 && sortedColor(1) == color(1))
%         listMarkers(i,4) = 0;
%     end
%     
% 
%     
%     % Take off red stuff that is not the red marker
%     % the red marker has very low green and blue values
%     % RED BUT NOT A MARKER
%     if (Index == 1 && ~(sortedColor(1)< 30 && sortedColor(2) < 30) && listMarkers(i,4) ~= 4)
%            % if it's detected as red marker but blue and green are very low
%         listMarkers(i,4) = 0;
%     end
%     
%     % find the higher values
%     % for red
%     if listMarkers(i,4) == 1
%         if maxColor > maxRed
%             maxRed2 = maxRed;
%             maxRed = maxColor;
%             maxIndRed2 = maxIndRed;
%             maxIndRed = i;
%         end
%     end
%     % for yellow
%     if listMarkers(i,4) == 4
%         if maxColor > maxYellow
%             maxYellow = maxColor;
%             maxIndYellow = i;
%         end
%     end
%     
%     % for green
%     if listMarkers(i,4) == 2
%         if maxColor > maxGreen
%             maxGreen = maxColor;
%             maxIndGreen = i;
%         end
%     end
%     
%     % for blue
%     if listMarkers(i,4) == 3
%         if maxColor > maxBlue
%         end
%     end
% end

%% Ploting and giving output
% figure, imshow (image);
% hold on
% 
% % If you want to plot only the higher marker of each color-----------------
% if maxIndRed ~= -1
%     plot (listMarkersRed(maxIndRed,2), listMarkersRed(maxIndRed,3),'r*')
%     hold on
% end
% if maxIndYellow ~= -1
%     plot (listMarkersYellow(maxIndYellow,2), listMarkersYellow(maxIndYellow,3),'y*')
%     hold on
% end
% if maxIndGreen ~= -1
%     plot (listMarkersGreen(maxIndGreen,2), listMarkersGreen(maxIndGreen,3),'g*')
%     hold on
% end
% if maxIndBlue ~= -1
%     plot (listMarkersBlue(maxIndBlue,2), listMarkersBlue(maxIndBlue,3),'b*')
%     hold on
% end


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

%% Measure the distance between the marker centroid of markers and the tool tip
% if maxIndRed ~= -1
%         d1=dist_points([listMarkers(maxIndRed,2), listMarkers(maxIndRed,3)] , [tool_tipx tool_tipy]);
% end
% if maxIndYellow~= -1
%         d2=dist_points([listMarkers(maxIndYellow,2), listMarkers(maxIndYellow,3)],[tool_tipx tool_tipy]);
% end
    


%% Check if the 3 centroids lie on a straight line (rougly)
% if maxIndRed~= -1 && maxIndRed2~= -1 | maxIndRed~= -1 && maxIndBlue2~= -1 | maxIndRed2~= -1 && maxIndBlue2~= -1
% xData=[listMarkers(maxIndBlue2,2), listMarkers(maxIndRed2,2), listMarkers(maxIndRed,2)];
% yData=[listMarkers(maxIndBlue2,2), listMarkers(maxIndRed2,3), listMarkers(maxIndRed,3)];
% hold on, line(xData,yData, 'LineStyle','-');
% hold off
% end

% Output: markersPosition -------------------------------------------------
% markersPos has te position in 2D (x,y) of the red, green and blue markers
% respectively

markersPos = zeros(4,2);

% red marker_1
if maxIndRed~= -1
    markersPos(1,:) = [listMarkersRed(maxIndRed,2), listMarkersRed(maxIndRed,3)];
 %   marker1_area=A_listMarkers(maxIndRed);
end

% yellow
if maxIndYellow~= -1 
  markersPos(2,:) = [listMarkersYellow(maxIndYellow,2), listMarkersYellow(maxIndYellow,3)];
%marker2_area=A_listMarkers(maxIndYellow);
end

% avg small red adn blue
% if maxIndBlue~= -1 && maxIndBlue2~= -1
%     
% % markersPos(2,:) = 0.5*([listMarkersBlue(maxIndBlue,2), listMarkersBlue(maxIndBlue,3)]+[listMarkersBlue(maxIndBlue2,2), listMarkersBlue(maxIndBlue2,3)]);
% %marker2_area=A_listMarkers(maxIndYellow);
% end

% green marker
if maxIndGreen~= -1
    markersPos(3,:) = [listMarkersGreen(maxIndGreen,2), listMarkersGreen(maxIndGreen,3)];
 %   marker3_area=A_listMarkers(maxIndGreen);
end

% blue marker
if maxIndBlue~= -1
    markersPos(4,:) = [listMarkersBlue(maxIndBlue,2), listMarkersBlue(maxIndBlue,3)];
%    marker4_area=A_listMarkers(maxIndBlue);
end
%% Output
RealW=400; % camera field (width in mm)
RealH=200; % camera field (height in mm)
[imgH imgW]=size(image); % number of pixels
real_pxW=RealW/imgW; % 1 pixel width in mm
real_pxH=RealH/imgH; %1 pixel height in mm

%dist in mm
%red 105 yellow 25 green 130 blue 30 mm
y1 = markersPos(1,1) * real_pxW;
x1 = markersPos(1,2) * real_pxH;
d1=105;

y2 = markersPos(2,1) * real_pxW;
x2 = markersPos(2,2) * real_pxH;
d2 = 25;

y3=markersPos(3,1) * real_pxW;
x3=markersPos(3,2) * real_pxH;
d3 = 130;

y4 = markersPos(4,1) * real_pxW;
x4 = markersPos(4,2) * real_pxH;
d4 = 30;

% give 0 in m1 because there is no red marker in this case
m1 = [x1 y1 0 0 d1];
m2 = [x2 y2 0 0 d2];
m3 = [x3 y3 0 0 d3];
m4 = [x4 y4 0 0 d4];
end
