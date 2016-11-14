function [markersPos] = getMarkersPos2(image)
close all;

% Load the image (uncomment if not using a video)
%image = imread(image);

%% Image processing
% take off the white background (if any)-----------------------------------
% Initialise
noBack_r = image(:,:,1);
noBack_g = image(:,:,2);
noBack_b = image(:,:,3);
for i = 1:length(image(:,1,1))
    for j = 1:length(image(1,:,1))
        if (noBack_r(i,j) > 160 ...
                && noBack_g(i,j) > 160 ...
                && noBack_b(i,j) > 160)
            noBack_r(i,j) = 0;
            noBack_g(i,j) = 0;
            noBack_b(i,j) = 0;
        end
    end
end
% added
% noBack(:,:,1) = noBack_r;
% noBack(:,:,2) = noBack_g;
% noBack(:,:,3) = noBack_b;
% imshow(noBack);
% pause


% Generation of a mask ----------------------------------------------------
%Threshold red
levelR = graythresh(noBack_r);
levelG = graythresh(noBack_g);
levelB = graythresh(noBack_b);

% levelsR = multithresh(noBack_r,2);
% redMask = imquantize(noBack_r, levelsR);
redMask = im2bw(noBack_r, levelR);
%redMask = uint8(redMask*50);
% imshow(redMask);
% pause

%Threshold green
greenMask = im2bw(noBack_g, levelG);

%Threshold blue
blueMask = im2bw(noBack_b, levelB);

redMask = redMask & ~greenMask & ~blueMask;
greenMask = greenMask & ~redMask & ~blueMask;
blueMask = blueMask & ~redMask;

% aprox length of the long side
imageSizeCM = 25;
markerSize = length(image(:,1))/imageSizeCM;
% area = long side * short side (1/4 of the long one)
markerArea = markerSize * markerSize /4;

% Get rid of small objects.
redMask = bwareafilt(redMask , [markerArea/2 inf]);%[2000 200000]);
greenMask = bwareafilt(greenMask , [markerArea/2 inf]);
blueMask = bwareafilt(blueMask , [markerArea/2 inf]);

% create a mask of the three colors
allMask = redMask | greenMask | blueMask;

%erode the mask
allMask = imerode(allMask, strel('diamond',3));

% reconstruct an image with all the markers
all(:,:,1) = uint8(allMask) .* noBack_r;
all(:,:,2) = uint8(allMask) .* noBack_g;
all(:,:,3) = uint8(allMask) .* noBack_b;

%% Labeling and identification

% label the image
[L,num] = bwlabel(allMask);

% get the centroids
s = regionprops(L,'centroid', 'BoundingBox', 'area');
centroids = cat(1, s.Centroid);

% go through all the centroids and check to what color they correspond
% create a matrix with
%   - as many rows as labels there are
%   - 4 columns (one for the label number, 2 for the centroid pos, 1 for the
%   color.
listIndex = zeros(num,4);
maxRed = 0;
maxIndRed = -1;
maxGreen = 0;
maxIndGreen = -1;
maxBlue = 0;
maxIndBlue = -1;
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
    [maxColor,Index] = max(color);
    listIndex(i,4) = Index;
    
    % find the higher values
    % for red
    if Index == 1
        if maxColor > maxRed
            maxRed = maxColor;
            maxIndRed = i;
        end
    end
    
    % for green
    if Index == 2
        if maxColor > maxGreen
            maxGreen = maxColor;
            maxIndGreen = i;
        end
    end
    
    % for blue
    if Index == 3
        if maxColor > maxBlue
            maxBlue = maxColor;
            maxIndBlue = i;
        end
    end
end

%% Ploting and giving output
 figure, imshow (image);
 hold on
% if maxIndRed ~= -1
% plot (listIndex(maxIndRed,2), listIndex(maxIndRed,3),'r*')
% hold on
% end
% if maxIndGreen ~= -1
% plot (listIndex(maxIndGreen,2), listIndex(maxIndGreen,3),'g*')
% hold on
% end
% if maxIndBlue ~= -1
% plot (listIndex(maxIndBlue,2), listIndex(maxIndBlue,3),'b*')
% end
% hold off

for i = 1:num
    % establish criteria:
    % - if the centroid is inside the marker
    % - if the ratio width/heigth > 2.8
    % - if the ratio width/heigth < 4.3
    if (listIndex(i,4)~= 0 )
        % plot red
%         if (listIndex(i,4) == 1)
%             plot (listIndex(i,2), listIndex(i,3),'r*')
%             hold on
%         end
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

% Output: markersPosition -------------------------------------------------
markersPos = zeros(num,2);
for i = 1:num
    if (listIndex(i,4)~= 0 )
        markersPos(i,1) = listIndex(i,2);
        markersPos(i,2) = listIndex(i,3);
    end
end
end