function [markersPos] = getMarkersPos(image)
clear;
close all;
% % Load the image
% image = imread('IMG_5575.JPG');

%% take off the white background (if any)
% Initialise
noBack_r = image(:,:,1);
noBack_g = image(:,:,2);
noBack_b = image(:,:,3);
for i = 1:length(image(:,1,1))
    for j = 1:length(image(1,:,1))
        if (noBack_r(i,j) > 150 && noBack_g(i,j) > 150 && noBack_b(i,j) > 150)
            noBack_r(i,j) = 0;
            noBack_g(i,j) = 0;
            noBack_b(i,j) = 0;
        end
    end
end

%% Thresholding
%Threshold red
levelR = graythresh(noBack_r);
redMask = im2bw(noBack_r, levelR);

%Threshold green
levelG = graythresh(noBack_g);
greenMask = im2bw(noBack_g, levelG);

%Threshold blue
levelB = graythresh(noBack_b);
blueMask = im2bw(noBack_b, levelB);

% create a mask of the three colors
allMask = redMask | greenMask | blueMask;

%erode the mask
allMask = imerode(allMask, strel('diamond',3));

% Get rid of small objects.
allMask = bwareafilt(allMask ,[2000 200000]);

% reconstruct an image with all the markers
all(:,:,1) = uint8(allMask) .* noBack_r;
all(:,:,2) = uint8(allMask) .* noBack_g;
all(:,:,3) = uint8(allMask) .* noBack_b;

%% Labeling and finding centroids

% label the image
[L,num] = bwlabel(allMask);

% get the centroids
s = regionprops(L,'centroid', 'orientation', 'BoundingBox');
centroids = cat(1, s.Centroid);

% go through all the centroids and check to what color they correspond
% create a matrix with
%   - as many rows as labels there are
%   - 5 columns (one for the label number, 2 for the centroid pos, 1 for the
%   color, 1 for the ratio width/height).
listIndex = zeros(num,5);
for i = 1:num
    % LABEL NAME
    listIndex (i,1) = i;
    % CENTROID POSITION
    listIndex (i,2) = centroids(i, 1);
    listIndex (i,3) = centroids(i, 2);
    % COLOR
    % if not all 3 channels are 0
    % See the colors of the centroids
    color = impixel (all, centroids(i,1), centroids(i,2));
    if (color(1) ~= 0 || color(2) ~= 0 || color(3) ~= 0)
        [MaxColor,Index] = max(color);
        orderedColors = sort(color);
        if (orderedColors(3)-orderedColors(2) > 10)
            listIndex(i,4) = Index;
        end
    end
end

%% Edge detection
% find the orientation of the labels
angles = cat(1, s.Orientation);

% compute de bounding box
bb = cat(1, s.BoundingBox);

% find edges along that direction near the centroid
for i = 1:num
    if (listIndex(i,4)~= 0)
        tinyLabel = imcrop(L ,bb(i,:));
        tinyLabel = imrotate(tinyLabel, -angles(i));
        %figure, imshow(tinyLabel);
        
        % label the image
        [Ltemp,numTemp] = bwlabel(tinyLabel);
        
        % get the centroids
        sTemp = regionprops(Ltemp,'BoundingBox');
        
        % compute de bounding box
        bbTemp = cat(1, sTemp.BoundingBox);
        
        % calculate ratio
        listIndex(i,5) = bbTemp(1,3) / bbTemp(1,4);
    end
end

%% Ploting
figure, imshow (image);
hold on
for i = 1:length(listIndex)
    % Stablish criteria:
    % if the centroid is inside the marker
    % if the ratio width/heigth > 2.8
    % if the ratio width/heigth < 4.3
    if (listIndex(i,4)~= 0 && (2.5 < listIndex(i,5)) && (listIndex(i,5) < 4.3))
        % plot red
        if (listIndex(i,4) == 1)
            plot (listIndex(i,2), listIndex(i,3),'r*')
            hold on
        end
        % plot green
        if (listIndex(i,4) == 2)
            plot (listIndex(i,2), listIndex(i,3),'g*')
            hold on
        end
        % plot blue
        if (listIndex(i,4) == 3)
            plot (listIndex(i,2), listIndex(i,3),'b*')
            hold on
        end
    end
end

markersPos = [];
for i = length(listIndex)
    if (listIndex(i,4)~= 0 ...
            && (2.5 < listIndex(i,5)) ...
            && (listIndex(i,5) < 4.3))
        numberMarkers(i,1) = listIndex(i,2);
        numberMarkers(i,2) = listIndex(i,3);
    end
end
end