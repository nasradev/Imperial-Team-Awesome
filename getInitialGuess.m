function [initialMarkers, initialAreas, currentTime] = getInitialGuess(INvideo, time)
% input: 
% INvideo: video you want to process
% time you want to start processing at in seconds
% output: 
% four arrays, one for each marker giving the 2d position and the 3d 
% translation to the tip of the instrument

% distance from the camera to the tools in cm
depth = 50;

% Load the video
close all;
video = VideoReader(INvideo);
video.CurrentTime = time;
currentTime = time;

while hasFrame(video)
    currentTime = video.currentTime;
    image = readFrame(video);
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
    redMask = satMask & origRedMask & ~origGreenMask & ~origBlueMask ;
    greenMask = satMask & origGreenMask & ~origRedMask & ~origBlueMask;
    blueMask = satMask & origBlueMask & ~origRedMask; % blue marker usualy has green too
    yellowMask = satMask & origRedMask & origGreenMask & ~origBlueMask;
    
    % Elimitation of small objects --------------------------------------------
    
    % aprox length of the long side
    imageSizeCM = depth * 1.05;
    markerSize = length(image(:,1))/imageSizeCM;
    markerArea = markerSize * markerSize /4;
    
    % Get rid of small objects
    redMask     = bwareafilt(redMask, [markerArea/2 inf]);
    greenMask   = bwareafilt(greenMask, [markerArea/2 inf]);
    blueMask    = bwareafilt(blueMask, [markerArea/2 inf]);
    yellowMask    = bwareafilt(yellowMask, [markerArea/2 inf]);
    
    % Reconstruction of the segmented image -----------------------------------
    % reconstruct an image with all the markers
    all(:,:,1) = uint8(redMask) .* imageRed;
    all(:,:,2) = uint8(greenMask) .* imageGreen;
    all(:,:,3) = uint8(blueMask) .* imageBlue;
    
    %% Labeling and identification
    
    % Red ---------------------------------------------------------------------
    % label the image
    [LRed,numRed] = bwlabel(redMask);
    
    % get the centroids
    sRed = regionprops(LRed,'centroid', 'area');
    centroidsRed = cat(1, sRed.Centroid);
    redAreas = cat(1, sRed.Area);
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
    sGreen = regionprops(LGreen,'centroid', 'area');
    centroidsGreen = cat(1, sGreen.Centroid);
    greenAreas = cat(1, sGreen.Area);
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
    
    % Blue ----------------------------------------------------------------
    % label the image
    [LBlue,numBlue] = bwlabel(blueMask);
    
    % get the centroids
    sBlue = regionprops(LBlue,'centroid', 'area');
    centroidsBlue = cat(1, sBlue.Centroid);
    blueAreas = cat(1, sBlue.Area);

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
    % Yellow --------------------------------------------------------------
    % label the image
    [LYellow,numYellow] = bwlabel(yellowMask);
    
    % get the centroids
    sYellow= regionprops(LYellow,'centroid', 'area');
    centroidsYellow = cat(1, sYellow.Centroid);
    yellowAreas = cat(1, sYellow.Area);

    listMarkersYellow = zeros(numYellow,4);
    
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
    imshow (image);
    hold on
    
%    If you want to plot only the higher marker of each color-----------------
    if maxIndRed ~= -1
        plot (listMarkersRed(maxIndRed,2), listMarkersRed(maxIndRed,3),'r*')
        hold on
    end
    if maxIndYellow ~= -1
        plot (listMarkersYellow(maxIndYellow,2), listMarkersYellow(maxIndYellow,3),'y*')
        hold on
    end
    if maxIndGreen ~= -1
        plot (listMarkersGreen(maxIndGreen,2), listMarkersGreen(maxIndGreen,3),'g*')
        hold on
    end
    if maxIndBlue ~= -1
        plot (listMarkersBlue(maxIndBlue,2), listMarkersBlue(maxIndBlue,3),'b*')
        hold on
    end
    
    
    %% Output: markersPosition -------------------------------------------------
    % markersPos has te position in 2D (x,y) of the red, green and blue markers
    % respectively
    
    x = input('Good markers detection? Insert "true" or "false" and press enter');
    
    if x
        
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
        
        % distances in mm
        % red: 105; yellow: 25; green: 130; blue: 30 mm;
        x1 = markersPos(1,1);
        y1 = markersPos(1,2);
        
        x2 = markersPos(2,1);
        y2 = markersPos(2,2);
        
        x3=markersPos(3,1);
        y3=markersPos(3,2);
        
        x4 = markersPos(4,1);
        y4 = markersPos(4,2);
        
        % give 0 in m1 because there is no red marker in this case
        m1 = [x1 y1];
        m2 = [x2 y2];
        m3 = [x3 y3];
        m4 = [x4 y4];
        
        initialAreas = zeros(1,4);
        if maxIndRed ~= -1
            initialAreas(1,1) = redAreas(maxIndRed);
        end
        if maxIndYellow ~= -1
            initialAreas(1,2) = yellowAreas(maxIndYellow);
        end
        if maxIndGreen ~= -1
            initialAreas(1,3) = greenAreas(maxIndGreen);
        end
        if maxIndBlue ~= -1
            initialAreas(1,4) = blueAreas(maxIndBlue);
        end
        initialMarkers = [m1; m2; m3; m4];
        
        break;
        
    end
end
end