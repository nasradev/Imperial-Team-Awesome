%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% Main script to find the 3D position in the camera frame of the checkerboa
% rds, and the color markers.
% 
% This script is intended to be used with two hands, two tools with 1 color
% marker in each and one checkerboard on each hand.
%
% 2017
% 
% Authors:
%   | Gonzalez-Bueno, Juana   |
%   | Mohamed, Nairouz        |
%   | Pittiglio, Giovanni     |
%   | Radev, Nasko            |
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

clear
clc
close all
warning off

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%                     Variable definitions 
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Set the video file and define output video object
% Path of the video to analise
PATH = 'C:\Users\jg5915\OneDrive - Imperial College London\Group project\26_04_17\';
% Video to analise (without extension)
VIDEONAME = '20170426_124947';
% Select experts OR novices for the output path
%LEVEL = 'experts\'; 
LEVEL = 'novices\';

% Select parameters to crop the video (to take off undesired background)
% and analise from 3rd - 9th stich
crop = [1 1000 1 720];  % [Xi Xf Yi Yf]
initialTime = 95.69;    % [seconds] 3rd stich
finalTime = 246;        % [second] 8th stich

%Size of checkerboard squares
squareSize = 5.1;     % (the black one is 6.1 but it's handled in the code)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%                     Initialise parameters
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Initialise the video
obj = VideoReader(strcat(PATH, VIDEONAME, '.mp4'));
vidWidth  = obj.Width;
vidHeight = obj.Height;

%Load up the camera parameters (from calibration):
load('gigiCameraParams3')
cam = [gigiCameraParams3.IntrinsicMatrix; [0, 0, 1]]; 
% Need to work on row vectors in gigiCameraParams3.IntrinsicMatrix'

% Initialise colors of the checkerboards detected in the image
firstBoard.colour = zeros(1,3);
secondBoard.colour = zeros(1,3);

% Checkerboard color options
blueCboard = uint8([0 0 255]);
redCboard  = uint8([255 0 0]);

% Intrinsic and extrinsic parameters of the camera
P = [];

% Counters for marker detection
staticRedCounter    = 0;
staticYellowCounter = 0;
staticGreenCounter  = 0;
staticBlueCounter   = 0;

% Define initial time for the video
obj.CurrentTime = initialTime;
timeOffset = round(obj.FrameRate * obj.CurrentTime); % [# of frames]
NoFrames = round((finalTime-initialTime)*obj.frameRate) + 1;
k = 1;  % frame counter

% Matrix to store euler angles (3 first columns) and translation (3 last on
% es) of the hand checkerboard for each frame
x  = zeros(NoFrames, 6);    % Red checkerboard (we assume it's in Right hand!)
x1 = zeros(NoFrames, 6);    % Blue checkerboard (left hand)

% Array with one row per frame and 5 columns (Points of the markers)
% the first two components will be [x,y] position of the marker in the
% image and the three last are the [x,y,z] distance from the marker to the
% tip of the tool in the tool reference frame
m0 = zeros(NoFrames, 5);    % First color marker (right hand tool)
m1 = zeros(NoFrames, 5);    % Second color marker (right hand tool)
m2 = zeros(NoFrames, 5);    % First color marker (left hand tool)
m3 = zeros(NoFrames, 5);    % Second color marker (left hand tool)

% Padding used to hide the checkerboards temporaly
imagePointsPadding = 40;    % in pixels

%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%                     Video frames loop
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
while hasFrame(obj) && obj.CurrentTime<= finalTime
    % Store the frame in the 'data' variable
    data = readFrame(obj);
    
    % Crop the image
    data = data(crop(3):crop(4), crop(1):crop(2), :);
    
    %    USE THIS HACK IF IMAGE INTENSITY IS TOO HIGH (takes out of red
    %    channel)
    %    data(:,:,1) = abs(data(:,:,1) - 40);
    
    % Get the first checkerboard:
    % If we already have the first checkerboard, try to find it again in
    % the nearby area, if we can't find it there, look in the entire image
    if isfield(firstBoard, 'imagePoints') == 1 && firstBoard.imagePoints(1,1) > -1
        xrange = round(min(firstBoard.imagePoints(:,1)) - imagePointsPadding...
            :max(firstBoard.imagePoints(:,1)) + imagePointsPadding);
        
        yrange = round(min(firstBoard.imagePoints(:,2)) - imagePointsPadding...
            :max(firstBoard.imagePoints(:,2)) + imagePointsPadding);
        
        sz = size(data);
        xrange(xrange<1) = 1;
        yrange(yrange<1) = 1;
        xrange(xrange>sz(2)) = sz(2)-1;
        yrange(yrange>sz(1)) = sz(1)-1;
        board = getBoardObject(data(yrange,xrange,:),...
            squareSize);
        % If we found the checkerboard in the little window, add an offset to
        % the points corresponding to the window's offset in the entire image.
        if board.imagePoints(1,1) > -1
            firstBoard.imagePoints = [];
            firstBoard.imagePoints(:,1) = board.imagePoints(:,1) + xrange(1);
            firstBoard.imagePoints(:,2) = board.imagePoints(:,2) + yrange(1);
            firstBoard.worldPoints = board.worldPoints;
            firstBoard.threePoints(:,1) = board.threePoints(:,1)...
                + xrange(1);
            
            firstBoard.threePoints(:,2) = board.threePoints(:,2)...
                + yrange(1);
            firstBoard.colour = board.colour;
            % If we did not find the second cboard in the little window
            % try the entire image.
        else
            firstBoard = getBoardObject(data, squareSize);
        end
    else
        firstBoard = getBoardObject(data, squareSize);
    end % Now we have a first board (probably)
    
    % Now check again if the first board has been found as it may not have
    % despite running getBoardObject.
    if firstBoard.imagePoints(1,1) > -1
        
        %[firstBoard.imagePoints(1,:);firstBoard.imagePoints(end,:)]);
        data = hideCheckerboardTemp(data, firstBoard.imagePoints);
        % Find the second board
        % If we already have the first checkerboard, try to find it again in
        % the nearby area, if we can't find it there, look in the entire image
        if isfield(secondBoard, 'imagePoints') == 1 && secondBoard.imagePoints(1,1) > -1
            xrange = round(min(secondBoard.imagePoints(:,1)) - imagePointsPadding...
                :max(secondBoard.imagePoints(:,1)) + imagePointsPadding);
            
            yrange = round(min(secondBoard.imagePoints(:,2)) - imagePointsPadding...
                :max(secondBoard.imagePoints(:,2)) + imagePointsPadding);
            
            sz = size(data);
            xrange(xrange<1) = 1;
            yrange(yrange<1) = 1;
            xrange(xrange>sz(2)) = sz(2)-1;
            yrange(yrange>sz(1)) = sz(1)-1;
            board = getBoardObject(data(max(yrange(1),1):...
                min(yrange(end),length(data(:,1,1))),...
                max(xrange(1),1):...
                min(xrange(end),length(data(1,:,1))),:),...
                squareSize);
            % If we found the checkerboard in the little window, add an offset to
            % the points corresponding to the window's offset in the entire image.
            if board.imagePoints(1,1) > -1
                secondBoard.imagePoints = [];
                secondBoard.imagePoints(:,1) = board.imagePoints(:,1) + xrange(1);
                secondBoard.imagePoints(:,2) = board.imagePoints(:,2) + yrange(1);
                secondBoard.worldPoints = board.worldPoints;
                secondBoard.threePoints(:,1) = board.threePoints(:,1)...
                    + xrange(1);
                secondBoard.threePoints(:,2) = board.threePoints(:,2)...
                    + yrange(1);
                secondBoard.colour = board.colour;
                % If we did not find the second cboard in the little window
                % try the entire image.
            else
                secondBoard = getBoardObject(data, squareSize);
            end
        else
            secondBoard = getBoardObject(data, squareSize);
        end % Now we have the second board (probably)
        
        % Now check again if the second board has been found as it may not have
        % despite running getBoardObject.
        if secondBoard.imagePoints(1,1) > -1
                        
            cb1sum = firstBoard.colour(1) + firstBoard.colour(2) + firstBoard.colour(3);
            cb2sum = secondBoard.colour(1) + secondBoard.colour(2) + secondBoard.colour(3);
            minColour = min([cb1sum, cb2sum]);
%             if firstBoard.colour(1) > secondBoard.colour(1)
%                 firstBoard.colour = redCboard;
%                 secondBoard.colour = blueCboard;
%             else
%                 firstBoard.colour = blueCboard;
%                 secondBoard.colour = redCboard;
%             end
        [val index] = max(firstBoard.colour);
            if index == 1
                firstBoard.colour = redCboard;
                secondBoard.colour = blueCboard;
            elseif index == 3
                firstBoard.colour = blueCboard;
                secondBoard.colour = redCboard;               
            else
                if firstBoard.colour(1) > secondBoard.colour(1)
                    firstBoard.colour = redCboard;
                    secondBoard.colour = blueCboard;
                else
                    firstBoard.colour = blueCboard;
                    secondBoard.colour = redCboard;
                end
            end

        else
            % Try to tell what colour the ONLY board we found is. Not sure
            % we really need this. Could do with an occlusion handling step here//Nas
            if (firstBoard.colour(1) > (firstBoard.colour(2) - 20)) && ...
                    (firstBoard.colour(1) > (firstBoard.colour(3)))
                firstBoard.colour = redCboard;
            else
                firstBoard.colour = blueCboard;
            end
        end
        
        % -----------------------------------------------------------------
        % Once we know which checkerboard is which we store their 3D
        % position and orientation
        
        % (1) Get Euler Angles and Translation Red Checkerboard and save in
        % x matrix
        if firstBoard.colour(1) == 255 && firstBoard.imagePoints(1,1)>-1
            [R,t] = ...
                estimateWorldCameraPose(firstBoard.imagePoints,...
                [firstBoard.worldPoints zeros(length(firstBoard.worldPoints(:,1)), 1)],...
                gigiCameraParams3);
            [R, t] = cameraPoseToExtrinsics(R, t);
            % Save angles (about z, y and x axis) and the translation (x, y
            % , z)
            x(k,:) = [rotm2eul(R.','ZYX') t];
            % Save origin of red CB
            redOrigin = firstBoard.imagePoints(1,:);
            % Draw mask on the first cboard
            data = hideCheckerboard(data, firstBoard.worldPoints, gigiCameraParams3, R, t);
        elseif secondBoard.colour(1) == 255 && secondBoard.imagePoints(1,1)>-1
            [R,t] = ...
                estimateWorldCameraPose(secondBoard.imagePoints,...
                [secondBoard.worldPoints zeros(length(secondBoard.worldPoints(:,1)), 1)],...
                gigiCameraParams3);
            [R, t] = cameraPoseToExtrinsics(R, t);
            x(k,:) = [rotm2eul(R.','ZYX') t];
            % Save origin in the image of red CB
            redOrigin = secondBoard.imagePoints(1,:);
            % Draw mask on the second cboard
            data = hideCheckerboard(data, secondBoard.worldPoints, gigiCameraParams3, R, t);
        end
        % Manual filtering of the checkerboard angles. If the angle changes
        % a lot suddenly, take the last orientation.
        if k >1
            if (norm(x(k,1:3)-x(k-1,1:3)) > 2.5 )
                x(k,1:3) = x(k-1,1:3);
            end
        end
        
        % (2) Get Euler Angles and Translation Blue Checkerboard and save
        % in x1 matrix
        if firstBoard.colour(3) == 255 && firstBoard.imagePoints(1,1)>-1
            [R,t] = ...
                estimateWorldCameraPose(firstBoard.imagePoints,...
                [firstBoard.worldPoints zeros(length(firstBoard.worldPoints(:,1)), 1)],...
                gigiCameraParams3);
            [R, t] = cameraPoseToExtrinsics(R, t);
            % Save angles (about z, y and x axis) and the translation (x,
            % y,z)
            x1(k,:) = [rotm2eul(R.','ZYX') t];
            % Draw mask on the first cboard
            data = hideCheckerboard(data, firstBoard.worldPoints, gigiCameraParams3, R, t);
        elseif secondBoard.colour(3) == 255 && secondBoard.imagePoints(1,1)>-1
            [R,t] = ...
                estimateWorldCameraPose(secondBoard.imagePoints,...
                [secondBoard.worldPoints zeros(length(secondBoard.worldPoints(:,1)), 1)],...
                gigiCameraParams3);
            [R, t] = cameraPoseToExtrinsics(R, t);
            x1(k,:) = [rotm2eul(R.','ZYX') t];
            % Draw mask on the second cboard
            data = hideCheckerboard(data, secondBoard.worldPoints, gigiCameraParams3, R, t);
        end
        % manual filtering of the checkerboard angles
        if k >1
            if (norm(x(k,1:3)-x(k-1,1:3)) > 2.5 )
                x(k,1:3) = x(k-1,1:3);
            end
        end
    end
    
    %% --------------------------------------------------------------------
    % Get color makers (of the tools) positions
    
    % In the first frame the entire image is checked for markers
    % Red and green markers commented as we only used yellow and blue in
    % the end.
    if k == 1 % ----------------


%         % Red marker
%         tinyRed = data(redOrigin(2):redOrigin(2)+ 125, redOrigin(1)-300:redOrigin(1), :);
%         [red, redArea] = getRedPos(tinyRed);
%         if( red(1) ~=  0 || red(2) ~= 0)
%             % reset the k to 0 because a marker was detected
%             staticRedCounter = 0;
%         else
%             disp('No red marker detected');
%         end
    

        % Yellow Marker
        tinyYellow = data;
        [yellow, yellowArea] = getYellowPos(tinyYellow);
        if( yellow(1) ~=  0 || yellow(2) ~= 0)
            % reset the k to 0 because a marker was detected
            staticRedCounter = 0;
        else
            disp('No yellow marker detected');
        end
        
        
        % Blue marker
        tinyBlue = data;
        [blue, blueArea] = getBluePos(tinyBlue);
        if( blue(1) ~=  0 || blue(2) ~= 0)
            % reset the counter to 0 because a marker was detected
            staticRedCounter = 0;
        else
            disp('No blue marker detected');
        end
        
        
%         % Green marker
%         tinyGreen = data;
%         [green, greenArea] = getGreenPos(tinyGreen);
%         if( green(1) ~=  0 || green(2) ~= 0)
%             % reset the counter to 0 because a marker was detected
%             staticGreenCounter = 0;
%         else
%             disp('No green marker detected');
%         end
        

    % For the following frames ----------------
    else
        
%         %%%% RED MARKER  %%%%
%         % Square centered on the red marker with an area 5 times the marker
%         % area
%         width = sqrt(redArea * 20);
%         % if the area of the marker is too small, give a min width
%         if width < 50
%             width = 50;
%         end
%         
%         % do the rectangle
%         %[rect, xrect, yrect] = doSquare(red(1), red(2), width, vidWidth, vidHeight);
%         
%         % crop the image around the marker
%         %tinyRed = imcrop(data,rect);
%         tinyRed = data(redOrigin(2):redOrigin(2)+ 125, redOrigin(1)-300:redOrigin(1), :);
%         
%         % if a marker was detected in the last frame
%         if staticRedCounter == 0
%             % get the new position of the red marker
%             lastRed = red;
%             [red, redArea] = getRedPos(tinyRed);
%             if( red(1) ~=  0 || red(2) ~= 0)
%                 red(1) = red(1) + redOrigin(1)-300;
%                 red(2) = red(2) + redOrigin(2);
%                 % reset the k to 0 because a marker was detected
%                 staticRedCounter = 0;
%             else
%                 red = lastRed;
%                 staticRedCounter = staticRedCounter + 1;
%             end
%             % if no marker is detected in 3 consecutive frames use a bigger
%             % image
%         else
%             % Use the entire image to look for the maker
%             tinyRed = data;
%             % get the new position of the red marker
%             lastRed = red;
%             [red, redArea] = getRedPos(tinyRed);
%             if( red(1) ~=  0 || red(2) ~= 0)
%                 % reset the k to 0 because a marker was detected
%                 staticRedCounter = 0;
%             else
%                 red = lastRed;
%                 staticRedCounter = staticRedCounter + 1;
%             end
%         end
%         
%         %Plot the red marker
%         shapeInserter = vision.ShapeInserter('Shape','Circles','BorderColor','Custom',...
%             'CustomBorderColor',[247 20 14]);
%         circle = int32([ red(1) red(2) 20; 0 0 0]);
%         data = step(shapeInserter, data, circle);


        %%%% YELLOW MARKER  %%%%
        % Square centered on the red marker with an area 5 times the marker
        % area
        width = sqrt(yellowArea * 20);
        % if the area of the marker is too small, give a min width
        if width < 50
            width = 50;
        end
        
        % do a rectangle
        [rect, xrect, yrect] = doSquare(yellow(1), yellow(2), width, vidWidth, vidHeight);
        
        % crop the image around the marker
        tinyYellow = imcrop(data,rect);
        
        % if a marker was detected in the last frame
        if staticYellowCounter == 0
            % get the new position of the red marker
            lastYellow = yellow;
            [yellow, yellowArea] = getYellowPos(tinyYellow);
            if( yellow(1) ~=  0 || yellow(2) ~= 0)
                yellow(1) = yellow(1) + xrect;
                yellow(2) = yellow(2) + yrect;
                % reset the k to 0 because a marker was detected
                staticYellowCounter = 0;
            else
                yellow = lastYellow;
                staticYellowCounter = staticYellowCounter + 1;
            end
            % if no marker is detected in 3 consecutive frames use a bigger
            % image
        else
            % Use the entire image to look for the maker
            tinyYellow = data;
            % get the new position of the red marker
            lastYellow = yellow;
            [yellow, yellowArea] = getYellowPos(tinyYellow);
            if( yellow(1) ~=  0 || yellow(2) ~= 0)
                % reset the k to 0 because a marker was detected
                staticYellowCounter = 0;
            else
                yellow = lastYellow;
                staticYellowCounter = staticYellowCounter + 1;
            end
        end
        
        %Plot the yellow marker
        shapeInserter = vision.ShapeInserter('Shape','Circles','BorderColor','Custom',...
            'CustomBorderColor',[247 247 14]);
        circle = int32([ yellow(1) yellow(2) 20; 0 0 0]);
        data = step(shapeInserter, data, circle);
        
        
        %%%% BLUE MARKER %%%%
        % Square centered on the red marker with an area 20 times the marker
        % area
        width = sqrt(blueArea * 20);
        % if the area of the marker is too small, give a min width
        if width < 50
            width = 50;
        end
        
        % Do a rectangle
        [rect, xrect, yrect] = doSquare(blue(1), blue(2), width, vidWidth, vidHeight);
        % Crop the image around the marker
        tinyBlue = imcrop(data,rect);
        % If no marker is detected in 3 consecutive frames use a bigger
        % image
        if staticBlueCounter == 0
            % Get the new position of the red marker
            lastBlue = blue;
            [blue, blueArea] = getBluePos(tinyBlue);
            if( blue(1) ~=  0 || blue(2) ~= 0)
                blue(1) = blue(1) + xrect;
                blue(2) = blue(2) + yrect;
                % Reset the counter to 0 because a marker was detected
                staticBlueCounter = 0;
            else
                blue = lastBlue;
                staticBlueCounter = staticBlueCounter + 1;
            end
        else
            % Use the entire image to look for the maker
            tinyBlue = data;
            % Get the new position of the red marker
            lastBlue = blue;
            [blue, blueArea] = getBluePos(tinyBlue);
            if( blue(1) ~=  0 || blue(2) ~= 0)
                % reset the counter to 0 because a marker was detected
                staticBlueCounter = 0;
            else
                blue = lastBlue;
                staticBlueCounter = staticBlueCounter + 1;
            end
        end
        
        % Plot the blue marker
        shapeInserter = vision.ShapeInserter('Shape','Circles','BorderColor','Custom',...
            'CustomBorderColor',[0 0 255]);
        circle = int32([ blue(1) blue(2) 20; 0 0 0]);
        data = step(shapeInserter, data, circle);
        

%         %%%% GREEN MARKER %%%%
%         % Square centered on the red marker with an area 5 times the marker
%         % area
%         width = sqrt(greenArea * 20);
%         if width < 50
%             width = 50;
%         end
%         % do a rectangle
%         [rect, xrect, yrect] = doSquare(green(1), green(2), width, vidWidth, vidHeight);
%         % crop the image around the marker
%         tinyGreen = imcrop(data,rect);
%         % if no mrker is detected in 3 consecutive frames use a bigger
%         % image
%         if staticGreenCounter == 0
%             % get the new position of the red marker
%             lastGreen = green;
%             [green, greenArea] = getGreenPos(tinyGreen);
%             if( green(1) ~=  0 || green(2) ~= 0)
%                 green(1) = green(1) + xrect;
%                 green(2) = green(2) + yrect;
%                 % reset the counter to 0 because a marker was detected
%                 staticGreenCounter = 0;
%             else
%                 green = lastGreen;
%                 staticGreenCounter = staticGreenCounter + 1;
%             end
%         else
%             % Use the entire image to look for the maker
%             tinyGreen = data;
%             % get the new position of the red marker
%             lastGreen = green;
%             [green, greenArea] = getGreenPos(tinyGreen);
%             if( green(1) ~=  0 || green(2) ~= 0)
%                 % reset the counter to 0 because a marker was detected
%                 staticGreenCounter = 0;
%             else
%                 green = lastGreen;
%                 statiGreenCounter = staticGreenCounter + 1;
%             end
%         end
%         
%         %Plot the green marker
%         shapeInserter = vision.ShapeInserter('Shape','Circles','BorderColor','Custom',...
%             'CustomBorderColor',[0 255 0]);
%         circle = int32([ green(1) green(2) 20; 0 0 0]);
%         data = step(shapeInserter, data, circle);
        

        % Save the positions of the markers for the Observer part ---------
        % Now only using one marker per tool so repeated
        % Right hand
        m0(k,:) = yellow;   % top marker
        m1(k,:) = yellow;   % bottom marker
        % Left hand
        m2(k,:) = blue;     % top marker
        m3(k,:) = blue;     % bottom marker
    end
    
    
    %% Plot frames
    % Plot a circle at the origin of both checkerboards
    shapeInserter = vision.ShapeInserter('Shape','Circles','BorderColor','Custom',...
        'CustomBorderColor',firstBoard.colour);
    circle = int32([firstBoard.imagePoints(1,1) firstBoard.imagePoints(1,2) 40; 0 0 0]);
    data = step(shapeInserter, data, circle);
    
    shapeInserter = vision.ShapeInserter('Shape','Circles','BorderColor','Custom',...
        'CustomBorderColor',secondBoard.colour);
    circle = int32([secondBoard.imagePoints(1,1) secondBoard.imagePoints(1,2) 40; 0 0 0]);
    data = step(shapeInserter, data, circle);
    
    % Plot checkerboard axis. For that we need to know their orientation
    % and position in 3D in camera reference frame (R and t) and project
    % that into the image using the K matrix.
    
    % Get K matrix (from calibration)
    K = gigiCameraParams3.IntrinsicMatrix;
    
    % Then plot the RED checkerboard's axes
    if (firstBoard.colour(1) == 255)        % if firstBoard is red
        % Get rotation and translation
        [R,t] = ...
            estimateWorldCameraPose(firstBoard.imagePoints,...
            [firstBoard.worldPoints zeros(length(firstBoard.worldPoints(:,1)), 1)],...
            gigiCameraParams3);
        [R, t] = cameraPoseToExtrinsics(R, t);
        % Get the axis in the image reference frame
        [origin, refx, refy, refz] = getFrameImage(R, t, K);
        % Draw it in the image
        data = drawReferenceFrame(data, origin, refx, refy, refz);
        
    elseif (secondBoard.colour(1) == 255)   % if secondBoard is red
        % Get rotation and translation
        [R,t] = ...
            estimateWorldCameraPose(secondBoard.imagePoints,...
            [secondBoard.worldPoints zeros(length(secondBoard.worldPoints(:,1)), 1)],...
            gigiCameraParams3);
        [R, t] = cameraPoseToExtrinsics(R, t);
        % Get the axis in the image reference frame
        [origin, refx, refy, refz] = getFrameImage(R, t, K);
        % Draw it in the image
        data = drawReferenceFrame(data, origin, refx, refy, refz);
    end
    
    
    % Then get the BLUE checkerboard's axes
    if (firstBoard.colour(3) == 255)        % if firstBoard is blue
        % Get rotation and translation
        [R2,t2] = ...
            estimateWorldCameraPose(firstBoard.imagePoints,...
            [firstBoard.worldPoints zeros(length(firstBoard.worldPoints(:,1)), 1)],...
            gigiCameraParams3);
        [R2, t2] = cameraPoseToExtrinsics(R2, t2);
        % Get the axis in the image reference frame
        [origin, refx, refy, refz] = getFrameImage(R2, t2, K);
        % Draw it in the image
        data = drawReferenceFrame(data, origin, refx, refy, refz);
        
    elseif (secondBoard.colour(3) == 255)   % if secondBoard is blue
        % Get rotation and translation
        [R2,t2] = ...
            estimateWorldCameraPose(secondBoard.imagePoints,...
            [secondBoard.worldPoints zeros(length(secondBoard.worldPoints(:,1)), 1)],...
            gigiCameraParams3);
        [R2, t2] = cameraPoseToExtrinsics(R2, t2);
        % Get the axis in the image reference frame
        [origin, refx, refy, refz] = getFrameImage(R2, t2, K);
        % Draw it in the image
        data = drawReferenceFrame(data, origin, refx, refy, refz);
    end

    
    % Update the frame counter
    k = k + 1;
    
    % Show the video
    imshow(data);
    
end % video loop

%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%                     Kinematic chain part.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% Variables Definition ------------------------
% load('MUpad'); %load the variables generated in mupad

%Hand Dimensions
tr = 0;         % [mm] (initial guess)
a  = 0;         % [rad] Angle alpha for right hand (set to 0 for needle holder)
a2 = 50*pi/180; % [rad] Angle alpha for left hand


% Prepare data for simulink -------------------
% Time data %
% Time step
dt = 1/obj.FrameRate;
% Total time
T = dt*(k-1);
% Time array
time = dt : dt : T;

% Checkerboards data %
% Make sure we don't take a longer array of checkerboard data
x  = x(1:length(time),:);
x1 = x1(1:length(time),:);
% Create matrix with both time info and checkerboard data
X  = [time' x];
X1 = [time' x1];
% Big matrix all combined
Xf0 = [x(1,1) zeros(1,2) x(1,2) zeros(1,2) x(1,3) zeros(1,2) x(1,4) ...
    zeros(1,2) x(1,5) zeros(1,2) x(1,6) zeros(1,2)];

% Color markers data %
% Create matrix (one per marker) with both time info and marker data (only 
% the distance between marker and tool tip in tool reference frame(local))
M0 = [time', m0(1:length(time),3:5)];
M1 = [time', m1(1:length(time),3:5)];
M2 = [time', m2(1:length(time),3:5)];
M3 = [time', m3(1:length(time),3:5)];
% Create matrix (one per tool) with both time info and marker data (the 2D
% position of the markers in the image)
Y  = [time', m0(1:length(time),1:2), m1(1:length(time),1:2)]; %measure (camera frame)
Y1 = [time', m2(1:length(time),1:2), m3(1:length(time),1:2)]; %measure (camera frame)


%% Marker State Evolution
% Transfer function
s = tf('s');
Gol2 = 1/s^2*eye(4);
[F1, B1, C1, D1] = ssdata(Gol2);
z0m = zeros(1,8);


%% Gain
load('K')
[Ak, Bk, Ck, Dk] = ssdata(K1);
[Ak_1, Bk_1, Ck_1, Dk_1] = ssdata(K2);


%% Minimu Jerk Filter

Dd = 0.05 * T;

Af1 = [0 1 0;
    0 0 1;
    -60/(Dd)^3 -36/(Dd)^2 -9/(Dd)];
Af = [Af1, zeros(3,3), zeros(3,3), zeros(3,3), zeros(3,3), zeros(3,3);
    zeros(3,3), Af1, zeros(3,3), zeros(3,3), zeros(3,3), zeros(3,3);
    zeros(3,3), zeros(3,3), Af1, zeros(3,3), zeros(3,3), zeros(3,3);
    zeros(3,3), zeros(3,3), zeros(3,3), Af1, zeros(3,3), zeros(3,3);
    zeros(3,3), zeros(3,3), zeros(3,3), zeros(3,3), Af1, zeros(3,3);
    zeros(3,3), zeros(3,3), zeros(3,3), zeros(3,3), zeros(3,3), Af1];

Bf1 = [0;
    0;
    60 / (Dd^3)];

Bf = [Bf1 zeros(3,1) zeros(3,1) zeros(3,1) zeros(3,1) zeros(3,1);
    zeros(3,1) Bf1 zeros(3,1) zeros(3,1) zeros(3,1) zeros(3,1);
    zeros(3,1) zeros(3,1) Bf1 zeros(3,1) zeros(3,1) zeros(3,1);
    zeros(3,1) zeros(3,1) zeros(3,1) Bf1 zeros(3,1) zeros(3,1);
    zeros(3,1) zeros(3,1) zeros(3,1) zeros(3,1) Bf1 zeros(3,1);
    zeros(3,1) zeros(3,1) zeros(3,1) zeros(3,1) zeros(3,1) Bf1];

Cf1 = [1 0 0];

Cf = [Cf1 zeros(1,3) zeros(1,3) zeros(1,3) zeros(1,3) zeros(1,3);
    zeros(1,3) Cf1 zeros(1,3) zeros(1,3) zeros(1,3) zeros(1,3);
    zeros(1,3) zeros(1,3) Cf1 zeros(1,3) zeros(1,3) zeros(1,3);
    zeros(1,3) zeros(1,3) zeros(1,3) Cf1 zeros(1,3) zeros(1,3);
    zeros(1,3) zeros(1,3) zeros(1,3) zeros(1,3) Cf1 zeros(1,3);
    zeros(1,3) zeros(1,3) zeros(1,3) zeros(1,3) zeros(1,3) Cf1];

sys = ss(Af,Bf,Cf,[]);

[zero, pole, gain] = zpkdata(sys);


%% Simulation in simulink
sim('trackingSim')

%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%                     Data Analysis
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% First Tool (In the right hand) ------------------------------------------

% l1: distance in 3D from checkerboard origin to finger ref frame in [mm]
% Use this instead if grasper in right hand
%l1 = [70; 70; 50];
% Use this instead if needle holder in right hand
l1 = [30; 30; 30];

% Estimated 3D positions in the camera frame
worldPoints1 = zeros(length(time),4);
% Estimated 3D positions in the camera frame projected in the
% image
imagePoints1 = zeros(length(time),3);

for i = 1:length(time)
    % Estimated position of the Tool (in 3D and image) in camera frame
    [worldPoints1(i,:), imagePoints1(i,:)] = proj(a, l1, hatX.data(i,:), Xf.data(i,:), cam);
    % Change sign of x and y data
    worldPoints1(i, 1) = - worldPoints1(i, 1);
    worldPoints1(i, 2) = - worldPoints1(i, 2);
end
% Estimated orientation of the Tool in camera frame (not used)
worldAngles1 = Xf.data(2:end,1:3) + [zeros(length(time),2), hatX.data(2:end,1) + a];

% Plot estimated pos in 3D in the camera ref frame
figure(2),
title('In camera reference frame'),
subplot(1,3,1)
plot(time, worldPoints1(:,1))
%ylim([-150 300])
grid on
xlabel('time [s]')
ylabel('$$P_x$$ [mm]' ,'Interpreter','Latex')
legend('Observed','Measured')
subplot(1,3,2)
plot(time, worldPoints1(:,2))
%ylim([-150 300])
grid on
xlabel('time [s]')
ylabel('$$P_y$$ [mm]' ,'Interpreter','Latex')
subplot(1,3,3)
plot(time, worldPoints1(:,3))
%ylim([-150 300])
grid on
xlabel('time [s]')
ylabel('$$P_z$$ [mm]' ,'Interpreter','Latex')

% Second tool (Left hand) -------------------------------------------------

% l2: distance in 3D from checkerboard origin to finger ref frame in [mm]
% Use this if needle holder on left hand:
%l2 = [30; 30; 30];
% Use this if grasper on left hand:
l2 = [50; 70; 50];

% Estimated 3D positions in the camera frame
worldPoints2 = zeros(length(time),4);
% Estimated 3D positions in the camera frame projected in the
% image
imagePoints2 = zeros(length(time),3);

for i = 1:length(time)
    % Estimated position of the Tool (in 3D and image) in camera frame
    [worldPoints2(i,:), imagePoints2(i,:)] = proj(a2,l2,hatX1.data(i,:),Xf1.data(i,:),cam);
    % Change sign
    worldPoints2(i,1) = - worldPoints2(i,1);
    worldPoints2(i,2) = - worldPoints2(i,2);
end
% Estimated orientation of the Tool in camera frame
worldAngles2 = Xf1.data(2:end,1:3) + [zeros(length(time),2), hatX1.data(2:end,1) + a2];

% Plot estimated pos in 3D in camera ref frame
figure(3),
title('In camera reference frame'),
subplot(1,3,1)
plot(time, worldPoints2(:,1))
%ylim([-150 300])
grid on
xlabel('time [s]')
ylabel('$$P_x$$ [mm]' ,'Interpreter','Latex')
legend('Observed')
subplot(1,3,2)
plot(time, worldPoints2(:,2))
%ylim([-150 300])
grid on
xlabel('time [s]')
ylabel('$$P_y$$ [mm]' ,'Interpreter','Latex')
subplot(1,3,3)
plot(time, worldPoints2(:,3))
%ylim([-150 300])
grid on
xlabel('time [s]')
ylabel('$$P_z$$ [mm]' ,'Interpreter','Latex')

%% Saving data for skill assessment
save(strcat(PATH, LEVEL , VIDEONAME, '.mat'), 'worldPoints1', 'worldPoints2');

% Save image of the suture at the end (save last frame)
obj.CurrentTime = obj.Duration - 1/obj.FrameRate;
Finaldata = readFrame(obj);
figure
saveas(imshow(Finaldata), strcat(PATH, VIDEONAME, '.pdf'));
