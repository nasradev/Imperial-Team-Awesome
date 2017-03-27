%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% Main script to find the 3D position in the camera frame of the marker at
% the tip of the tool.
%
% This script is intended to be used with one hand, one tool with 2 color
% markers (yellow at the bottom and blue at the top), a black reference
% static checkerboard and a red checckerboard on the glove.
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

%% Variable definitions
% Set the video file and define output video object
%PATH = 'C:\Users\jg5915\OneDrive - Imperial College London\Group project\16_03_17_Validation\';
PATH = 'C:\dev\Matlab\TeamProject\Videos\';
VIDEONAME = '20170316_152250Inverted';

obj = VideoReader(strcat(PATH, 'aurora\', VIDEONAME, '.mp4'));
vidWidth = obj.Width;
vidHeight = obj.Height;
mov = struct('cdata', zeros(vidHeight, vidWidth, 3, 'uint8'), 'colormap',[]);

% CSV file with the groundtruth positions for validation
M = tdfread(strcat(PATH, 'aurora\20170316_152250.csv'), ',');

%Size of checkerboard squares
squareSize = 5.4;

%Load up the camera parameters:
load(strcat(PATH, 'gigiCameraParams2.mat'));
cam = [gigicameraParams2.IntrinsicMatrix', [0; 0; 1]];

% Colors of the checkerboards detected in the image
firstBoard.colour = zeros(1,3);
secondBoard.colour = zeros(1,3);

foundFixedCheckerboard = 0;

% Checkerboard color options
blueCboard = uint8([0 0 255]);
redCboard = uint8([255 0 0]);
blackCboard = uint8([0 0 0]);

% Definition of the colors of the glove and reference checkerboards
gloveBoard = redCboard;
refBoard = blackCboard;

% Intrinsic and extrinsic parameters of the camera
P = [];

% Counters for marker detection
staticRedCounter = 0;
staticYellowCounter = 0;
staticGreenCounter = 0;
staticBlueCounter = 0;

% Define initial time
obj.CurrentTime = 0;
timeOffset = round(obj.FrameRate) * (round(obj.CurrentTime));
k = 1;
NoFrames = round(obj.Duration*obj.frameRate);

% Matrix for euler angles (3 first columns) and translation (3 last ones)
% of the hand checkerboard (? quite sure)
x = zeros(NoFrames, 6);

% Array with one row per frame and 5 columns (Points of the markers)
m0 = zeros(NoFrames, 5);    % First color marker
m1 = zeros(NoFrames, 5);    % Second color marker

% Use if aurora data and video are not aligned
auroraStartOffset = 0;

imagePointsPadding = 40;

% Aurora data for the bottom marker and the hand checkerboard
auroraPoints1 = [];         % marker pos (aurora frame)
auroraOrientations1 = [];   % marker orientation (aurora frame)
auroraPoints2 = [];         % checkerboard pos (aurora frame)
auroraOrientations2 = [];   % checkerboard orientation (aurora frame)

%% Go through the video frames
while hasFrame(obj) && k <= 170
    data = readFrame(obj);
    %[data,asdasdasd] = undistortImage(data,gigicameraParams2,'OutputView','full');
    %[data,asdasdasd] = undistortImage(data,gigicameraParams2);
    %    USE THIS HACK IF IMAGE INTENSITY IS TOO HIGH
    %    data(:,:,1) = abs(data(:,:,1) - 40);
    
    % Get the first checkerboard:
    % If we already have the first checkerboard, try to find it again in
    % the nearby area, if we can't find it there, look in the entire image
    if isfield(firstBoard, 'imagePoints') == 1 && firstBoard.imagePoints(1,1) > -1
        xrange = round([min(firstBoard.imagePoints(:,1)) - imagePointsPadding...
            :max(firstBoard.imagePoints(:,1)) + imagePointsPadding]);
        
        yrange = round([min(firstBoard.imagePoints(:,2)) - imagePointsPadding...
            :max(firstBoard.imagePoints(:,2)) + imagePointsPadding]);
        
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
            % If we did not find the second cboard in the little window
            % try the entire image.
        else
            firstBoard = getBoardObject(data, squareSize);
        end
    else
        firstBoard = getBoardObject(data, squareSize);
%         firstBoard.imagePoints = [firstBoard.imagePoints(:,1) + asdasdasd(1), ...
%              firstBoard.imagePoints(:,2) + asdasdasd(2)];
    end % Now we have a first board (probably)
    
    % Now check again if the first board has been found as it may not have
    % despite running getBoardObject.
    if firstBoard.imagePoints(1,1) > -1
        
        % Draw mask on the first cboard and find the next one
        temp_data = hideCheckerboard(data,...
            [firstBoard.imagePoints(1,:);firstBoard.imagePoints(end,:)]);
        
        % Find the second board
        % If we already have the first checkerboard, try to find it again in
        % the nearby area, if we can't find it there, look in the entire image
        if isfield(secondBoard, 'imagePoints') == 1 && secondBoard.imagePoints(1,1) > -1
            xrange = round([min(secondBoard.imagePoints(:,1)) - imagePointsPadding...
                :max(secondBoard.imagePoints(:,1)) + imagePointsPadding]);
            
            yrange = round([min(secondBoard.imagePoints(:,2)) - imagePointsPadding...
                :max(secondBoard.imagePoints(:,2)) + imagePointsPadding]);
            
            xrange(xrange<1) = 1;
            yrange(yrange<1) = 1;
            xrange(xrange>sz(2)) = sz(2)-1;
            yrange(yrange>sz(1)) = sz(1)-1;
            board = getBoardObject(temp_data(max(yrange(1),1):...
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
                % If we did not find the second cboard in the little window
                % try the entire image.
            else
                secondBoard = getBoardObject(temp_data, squareSize);
            end
        else
            secondBoard = getBoardObject(temp_data, squareSize);
%             secondBoard.imagePoints = [secondBoard.imagePoints(:,1) + asdasdasd(1), ...
%              secondBoard.imagePoints(:,2) + asdasdasd(2)];
        end % Now we have the second board (probably)
        
        % Now check again if the second board has been found as it may not have
        % despite running getBoardObject.
        if secondBoard.imagePoints(1,1) > -1
            % Now that we found 2 checkerboards, see which one looks more "black"
            cb1sum = firstBoard.colour(1) + firstBoard.colour(2) + firstBoard.colour(3);
            cb2sum = secondBoard.colour(1) + secondBoard.colour(2) + secondBoard.colour(3);
            if cb1sum < cb2sum
                if (foundFixedCheckerboard == 0)
                    fixedRefCheckerboard=firstBoard;
                    foundFixedCheckerboard = 1;
                    wp = fixedRefCheckerboard.worldPoints;
                    for i=1:length(wp(:,1))
                        wp(i,1) = wp(i,1) + (wp(i,1)/5.4);
                        wp(i,2) = wp(i,2) + (wp(i,2)/5.4);
                    end
                    fixedRefCheckerboard.worldPoints = wp;
                end
                firstBoard.colour = refBoard;
                secondBoard.colour = gloveBoard;
            else
                if (foundFixedCheckerboard == 0)
                    fixedRefCheckerboard=secondBoard;
                    foundFixedCheckerboard = 1;
                    wp = fixedRefCheckerboard.worldPoints;
                    for i=1:length(wp(:,1))
                        wp(i,1) = wp(i,1) + (wp(i,1)/5.4);
                        wp(i,2) = wp(i,2) + (wp(i,2)/5.4);
                    end
                    fixedRefCheckerboard.worldPoints = wp;
                end
                firstBoard.colour = gloveBoard;
                secondBoard.colour = refBoard;
            end;
            
            % TODO: can comment out the next 6 commands to stop drawing a
            % little circle where the checkerboards' tops is detected.
% %             shapeInserter = vision.ShapeInserter('Shape','Circles','BorderColor','Custom',...
% %                 'CustomBorderColor',firstBoard.colour);
% %             circle = int32([firstBoard.imagePoints(1,1) firstBoard.imagePoints(1,2) 40; 0 0 0]);
% %             data = step(shapeInserter, data, circle);
% %             
% %             shapeInserter = vision.ShapeInserter('Shape','Circles','BorderColor','Custom',...
% %                 'CustomBorderColor',secondBoard.colour);
% %             circle = int32([secondBoard.imagePoints(1,1) secondBoard.imagePoints(1,2) 40; 0 0 0]);
% %             data = step(shapeInserter, data, circle);
            
            
        else
            % Try to tell what colour the ONLY board we found is. Not sure
            % we really need this. Could do with an occlusion handling step here//Nas
            if (firstBoard.colour(1) < 70) && (firstBoard.colour(2) < 70) ...
                    && (firstBoard.colour(3) < 70)...
                    && firstBoard.colour(3) < firstBoard.colour(1) + 30
                firstBoard.colour = blackCboard;
            elseif (firstBoard.colour(1) > (firstBoard.colour(2) - 20)) && ...
                    (firstBoard.colour(1) > (firstBoard.colour(3)))
                firstBoard.colour = redCboard;
            end
        end
        
        
        % Get Euler Angles and Translation Red Checkerboard
        if firstBoard.colour(1) == 255 && firstBoard.imagePoints(1,1)>-1
            [rot, trans] = extrinsics(firstBoard.imagePoints,...
                firstBoard.worldPoints, gigicameraParams2);
            x(k,:) = [rotm2eul(rot.','ZYX') trans];
        elseif secondBoard.colour(1) == 255 && secondBoard.imagePoints(1,1)>-1
            [rot, trans] = extrinsics(secondBoard.imagePoints,...
                secondBoard.worldPoints, gigicameraParams2);
            x(k,:) = [rotm2eul(rot.','ZYX') trans];
        end
        % manual filtering of the checkerboard angles
        if k >1
            if (norm(x(k,1:3)-x(k-1,1:3)) > 2.5 )
                x(k,1:3) = x(k-1,1:3);
            end
        end
    end
    
    %% TODO See if we can introduce logic to find BLACK (i.e. ref frame)
    %  checkerboard once, save its position and then just look for the
    %  RED one in the next frames.
    
    %% GET MARKER POSITIONS:
    % Blue and Yellow markers in the tool
    
    % In the first frame the entire image is checked for markers
    if k == 1
        
        % Yellow Marker
        tinyYellow = temp_data;
        [yellow, yellowArea] = getYellowPos(tinyYellow);
        if( yellow(1) ~=  0 || yellow(2) ~= 0)
            % reset the k to 0 because a marker was detected
            staticRedCounter = 0;
        else
            display('No yellow marker detected');
        end
        
        % Blue marker
        tinyBlue = temp_data;
        [blue, blueArea] = getBluePos(tinyBlue);
        if( blue(1) ~=  0 || blue(2) ~= 0)
            % reset the k to 0 because a marker was detected
            staticRedCounter = 0;
        else
            display('No blue marker detected');
        end
    else
        
        % After the first frame
        % YELLOW MARKER
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
        
        m0(k,:) = blue;
        m1(k,:) = yellow;
        
        %%%% BLUE MARKER %%%%
        % Square centered on the red marker with an area 20 times the marker
        % area
        width = sqrt(blueArea * 20);
        % if the area of the marker is too small, give a min width
        if width < 50
            width = 50;
        end
        
        % do a rectangle
        [rect, xrect, yrect] = doSquare(blue(1), blue(2), width, vidWidth, vidHeight);
        % crop the image around the marker
        tinyBlue = imcrop(data,rect);
        % if no mrker is detected in 3 consecutive frames use a bigger
        % image
        if staticBlueCounter == 0
            % get the new position of the red marker
            lastBlue = blue;
            [blue, blueArea] = getBluePos(tinyBlue);
            if( blue(1) ~=  0 || blue(2) ~= 0)
                blue(1) = blue(1) + xrect;
                blue(2) = blue(2) + yrect;
                % reset the k to 0 because a marker was detected
                staticBlueCounter = 0;
            else
                blue = lastBlue;
                staticBlueCounter = staticBlueCounter + 1;
            end
        else
            % Use the entire image to look for the maker
            tinyBlue = data;
            % get the new position of the red marker
            lastBlue = blue;
            [blue, blueArea] = getBluePos(tinyBlue);
            if( blue(1) ~=  0 || blue(2) ~= 0)
                % reset the k to 0 because a marker was detected
                staticBlueCounter = 0;
            else
                blue = lastBlue;
                staticBlueCounter = staticBlueCounter + 1;
            end
        end
        %Plot the blue marker
        shapeInserter = vision.ShapeInserter('Shape','Circles','BorderColor','Custom',...
            'CustomBorderColor',[0 0 255]);
        circle = int32([ blue(1) blue(2) 20; 0 0 0]);
        data = step(shapeInserter, data, circle);
    end
    
    
    
    %% VALIDATION %% TODO MOVE TO FUNCTION?
    
    % Consider removing the part about Aurora from this portion of the code
    % and just reading all the aurora entries in the end (outside the while loop).
    % We currently have the aurora code here because we need to match the frames, but
    % if we ignore the time vectors we don't need to do that (all the 1.4* logic)
    
    % Get the R and t of the World with respect to the black checkerboard:
    %                 if (isempty(P)) &&  isequal(firstBoard.colour, [0 0 0]) && firstBoard.imagePoints(1,1) > 0
    %                        [R,t] = extrinsics(firstBoard.imagePoints, ...
    %                                 firstBoard.worldPoints, gigicameraParams2);
    %                   P = gigicameraParams2.IntrinsicMatrix * [R t'];
    %                 elseif isempty(P) &&  isequal(secondBoard.colour, [0 0 0]) && secondBoard.imagePoints(1,1) > 0
    %                   [R,t] = extrinsics(secondBoard.imagePoints, ...
    %                                 secondBoard.worldPoints, gigicameraParams2);
    %                   P = gigicameraParams2.IntrinsicMatrix * [R t'];
    %                 elseif isempty(P) &&  isequal(thirdBoard.colour, [0 0 0]) && thirdBoard.imagePoints(1,1) > 0
    %                   [R,t] = extrinsics(thirdBoard.imagePoints, ...
    %                                 thirdBoard.worldPoints, gigicameraParams2);
    %                   P = gigicameraParams2.IntrinsicMatrix * [R t'];
    %
    
    if (isempty(P))
        [R,t] = extrinsics(fixedRefCheckerboard.imagePoints, ...
            fixedRefCheckerboard.worldPoints, gigicameraParams2);
        P = gigicameraParams2.IntrinsicMatrix * [R t'];
    end
    auroraFrame = floor(1.4 *  (timeOffset + k)) + auroraStartOffset;
    
    %%TODO: RENAME THE STUPID CAMPOINT/CAMEULER VARIABLES
    if isempty(P) == 0 && auroraFrame <= length( M.Ty1 )
        
        %% TODO make a transformation aurora to checkerboard
                
        % (Tx, Ty, Tz) is ref checkerboard, 
        % (Tx1, Ty1, Tz1)is tip marker,
        % (Tx2, Ty2, Tz2) is hand checherboard
        % The aurora ref frame goes as follows: 
        %   x to the right
        %   y far from camera
        %   z up
        
        % We want to leave the aurora frame as it is and transform the
        % detected positions to the aurora ref frame.
        
        % record: position and orientation of yellow marker from aurora
        record = [M.Tx1(auroraFrame), M.Ty1(auroraFrame), M.Tz1(auroraFrame), M.Q01(auroraFrame), M.Qx1(auroraFrame), ...
            M.Qy1(auroraFrame), M.Qz1(auroraFrame)];
        
        tic
        % Get the position of the tool aurora sensor in camera frame
        [auroraCurrentPoint1, cameuler, camrotation] = getAuroraTranslation(record, R, t);
        auroraCurrentPoint1 = record(1:3);
        % Get the position of the reference CB in aurora frame

        %Ignore Bad Fitsin
        isBadfit = M.State1(auroraFrame);
        if isBadfit(1)=='B'
            auroraCurrentPoint1 = auroraPoints1(end,:);
            cameuler = auroraOrientations1(end,:);
        end
        auroraPoints1 = [auroraPoints1; auroraCurrentPoint1];
        auroraOrientations1 = [auroraOrientations1; cameuler];
        
        %[focal length in mm]*[resolution]/[sensor size in mm]
        K = gigicameraParams2.IntrinsicMatrix;
        
        % Transform into image point:
        impoint = auroraCurrentPoint1 * K;
        
        % This rescales for Z
        impoint = impoint / impoint(3);
        
        % Little red circle for the aurora position od the tool projected
        % in the image
        shapeInserter = vision.ShapeInserter('Shape','Circles','BorderColor','Custom',...
            'CustomBorderColor',[255 0 0]);
        circle = int32([impoint(1) impoint(2) 10; 0 0 0]);
        data = step(shapeInserter, data, circle);
        
        % BTW camera position C in world frame is:
        % C = -R'*t
        
    end
    
    if isfield(M, 'Ty2') && isempty(P) == 0 && auroraFrame <= length( M.Ty2 )
        
        record = [M.Tx2(auroraFrame), M.Ty2(auroraFrame), M.Tz2(auroraFrame), M.Q02(auroraFrame), M.Qx2(auroraFrame), ...
            M.Qy2(auroraFrame), M.Qz2(auroraFrame)];
        
        % Get the position of the tool sensor in Aurora frame
        [auroraCurrentPoint2, cameuler, camorientation2] = getAuroraTranslation(record, R, t);
        
        % Ignore Bad Fits
        isBadfit = M.State1(auroraFrame);
        if isBadfit(1) == 'B'
            auroraCurrentPoint2 = auroraPoints2(end,:);
            cameuler = auroraOrientations2(end,:);
        end
        
        auroraPoints2 = [auroraPoints2; auroraCurrentPoint2];
        auroraOrientations2 = [auroraOrientations2; cameuler];
        
        %[focal length in mm]*[resolution]/[sensor size in mm]
        K = gigicameraParams2.IntrinsicMatrix;
        % Transform into image point:
        impoint = auroraCurrentPoint2 * K;
        % This rescales for Z
        impoint = impoint / impoint(3);
        
        shapeInserter = vision.ShapeInserter('Shape','Circles','BorderColor','Custom',...
            'CustomBorderColor',[0 255 0]);
        circle = int32([impoint(1) impoint(2) 10; 0 0 0]);
        data = step(shapeInserter, data, circle);
        
        % BTW camera position C in world frame is:
        % C = -R'*t
        toc
    end
    
    
    % The below draws the axes of the reference frame as
    % defined by the R and t. K is the camera intrinsics
    
    % Plot the ref frame of the reference checkerboard first
    [R,t] = extrinsics(fixedRefCheckerboard.imagePoints, ...
            fixedRefCheckerboard.worldPoints, gigicameraParams2);
    [origin, refx, refy, refz] = getFrameImage(R, t, K);
    data = drawReferenceFrame(data, origin, refx, refy, refz);
    
    % Plot camera ref frame
    [origin, refx, refy, refz] = getFrameImage(eye(3), [0 0 0], K);
    data = drawReferenceFrame(data, origin, refx, refy, refz);
    
    % Then plot the RED checkerboard's axes
    if (firstBoard.colour(1) == 255)
        [R,t] = extrinsics(firstBoard.imagePoints, ...
            firstBoard.worldPoints, gigicameraParams2);
        [origin, refx, refy, refz] = getFrameImage(R, t, K);
        data = drawReferenceFrame(data, origin, refx, refy, refz);
    elseif (secondBoard.colour(1) == 255)
        [R,t] = extrinsics(secondBoard.imagePoints, ...
            secondBoard.worldPoints, gigicameraParams2);
        [origin, refx, refy, refz] = getFrameImage(R, t, K);
        data = drawReferenceFrame(data, origin, refx, refy, refz);
    end
    mov(k).cdata = data;
    k = k + 1;
    imshow(data);
    
end %hasFrame

%% Kinematic chain part. 

% Variables Definition
% load('MUpad') %load the variables generated in mupad

%Hand Dimensions
tr = 0; %mm
a = 80*pi/180;

% Observer
squareSize = 5.4; %size of the scheckerboard squares in mm

%% Data
%% DO. BETTER. WITH. VARIABLE. NAMES. please.
dt = 1/obj.FrameRate;%0.01;
T = dt*(k-1);
time = dt : dt : T;

X = [time' x];

X1 = X;%[time' x1];
Xf0 = [x(1,1) zeros(1,2) x(1,2) zeros(1,2) x(1,3) zeros(1,2) x(1,4) ...
    zeros(1,2) x(1,5) zeros(1,2) x(1,6) zeros(1,2)];

M0 = [time', m0(:,3:5)];%tool reference (local)
M1 = [time', m1(:,3:5)];
M2 = M0;%[time', m2(:,3:5)];%tool reference (local)
M3 = M1;%[time', m3(:,3:5)];

Y = [time', m0(:,1:2), m1(:,1:2)];%measure (camer frame)
Y1 = Y;
% Y1 = [time', m2(:,1:2), m3(:,1:2)];%measure (camer frame)

%% TODO: ASK GIGI WHAT THE FOLLOWING MAGIC DOES

%% Marker State Evolution
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

%% Simulation
sim('trackingSim')

%% Data Analysis

% First Tool(blue-yellow)
l = [30; 20; 0];

% Estimated 3D positions in the camera frame
worldPoints = zeros(4,length(time));
% Estimated 3D positions in the camera frame projected in the
% image
imagePoints = zeros(3,length(time));
% Estimated 3D positions in the aurora ref frame
worldPoints1AuRef = zeros(size(worldPoints));

for i = 1:length(time)
    % Estimated position of the Tool (in 3D and image) in camera frame
    [worldPoints(:,i), imagePoints(:,i)] = proj(a,l,-hatX.data(i,:),Xf.data(i,:),cam);
    [frameVect(:,:,i)] = frame_proj(a,l,-hatX.data(i,:),Xf.data(i,:),cam);
       
    % Conversion to aurora ref frame
    worldPoints1AuRef(1:3,i) = cam2aurora(worldPoints(1:3,i), R, t, squareSize);
end
% Estimated orientation of the Tool in camera frame
worldAngles = Xf.data(2:end,1:3) + [zeros(length(time),2), hatX.data(2:end,1) + a];


% Plot aurora vs estimated pos in 3D
figure, 
title('In aurora reference frame'),
subplot(1,3,1)
plot(time(1:length(auroraPoints1)), [worldPoints1AuRef(1,1:length(auroraPoints1)); auroraPoints1(:,1)'])
grid on
xlabel('time [s]')
ylabel('$$P_x$$ [mm]' ,'Interpreter','Latex')
legend('Observed','Measured')
subplot(1,3,2)
plot(time(1:length(auroraPoints1)), [worldPoints1AuRef(2,1:length(auroraPoints1)); auroraPoints1(:,2)'])
grid on
xlabel('time [s]')
ylabel('$$P_y$$ [mm]' ,'Interpreter','Latex')
subplot(1,3,3)
plot(time(1:length(auroraPoints1)), [worldPoints1AuRef(3,1:length(auroraPoints1)); auroraPoints1(:,3)'])
grid on
xlabel('time [s]')
ylabel('$$P_z$$ [mm]' ,'Interpreter','Latex')

%% Hand checkerboard position
l1 = [0; 0; 0];

worldPoints1 = zeros(4,length(time));
imagePoints1 = zeros(3,length(time));

%Position and Orientation of the checkerboard
for i = 1:length(time) %position
    [worldPoints1(:,i), imagePoints1(:,i)] = proj(a,l1,-hatX1.data(i,:),Xf1.data(i,:),cam);
    [frameVect1(:,:,i)] = frame_proj(a,l1,-hatX1.data(i,:),Xf1.data(i,:),cam);
end
worldAngles1 = Xf1.data(2:end,1:3) + [zeros(length(time),2), hatX1.data(2:end,1) + a];
worldAngles1(:,1) = -worldAngles1(:,1);

figure(7)
subplot(1,3,1)
plot(time(1:length(auroraPoints1)), [worldPoints1(1,1:length(auroraPoints1)); auroraPoints2(:,1)'])
grid on
xlabel('time [s]')
ylabel('$$P_x$$ [mm]' ,'Interpreter','Latex')
legend('Observed','Measured')
subplot(1,3,2)
plot(time(1:length(auroraPoints1)), [worldPoints1(2,1:length(auroraPoints1)); auroraPoints2(:,2)'])
grid on
xlabel('time [s]')
ylabel('$$P_y$$ [mm]' ,'Interpreter','Latex')
subplot(1,3,3)
plot(time(1:length(auroraPoints1)), [worldPoints1(3,1:length(auroraPoints1)); auroraPoints2(:,3)'])
grid on
xlabel('time [s]')
ylabel('$$P_z$$ [mm]' ,'Interpreter','Latex')

%% Plot Frame on Video
% Plot first tool position
circleColour1 = [255 255 0];
shapeInserter1 = vision.ShapeInserter('Shape','Circles','BorderColor','Custom',...
    'CustomBorderColor',circleColour1);

% Blue little circle
circleColour2 = [0 0 255];
shapeInserter2 = vision.ShapeInserter('Shape','Circles','BorderColor','Custom',...
    'CustomBorderColor',circleColour2);

% Plot hand checkerboard position in image
figure(11)
for j = 1:length(mov)
    circle1 = int32([imagePoints(1,j) imagePoints(2,j) 10; 0 0 0]);
    circle2 = int32([imagePoints1(1,j) imagePoints1(2,j) 10; 0 0 0]);
    mov(j).cdata = step(shapeInserter1, mov(j).cdata, circle1);
    mov(j).cdata = step(shapeInserter2, mov(j).cdata, circle2);
    
    % %First Tool
    %       frameVect(:,1,j)=frameVect(:,1,j)/frameVect(3,1,j);
    %       frameVect(:,2,j)=frameVect(:,2,j)/frameVect(3,2,j);
    %       frameVect(:,3,j)=frameVect(:,3,j)/frameVect(3,3,j);
    %      shapeInserter = vision.ShapeInserter('Shape','Lines','BorderColor','Custom',...
    %     'CustomBorderColor',[255 50 0],'LineWidth',1);
    % % shapeInserter=vision.ShapeInserter('Shape','Lines')
    %      lxsize = pdist([imagePoints(1,j) imagePoints(2,j); imagePoints(1,j)+frameVect(1,1,j) imagePoints(2)+frameVect(2,1)]);
    %      lineScaleFactor = 1/lxsize * 50;
    %      linex = int32([imagePoints(1,j) imagePoints(2,j) imagePoints(1,j)+lineScaleFactor*frameVect(1,1) imagePoints(2)+lineScaleFactor*frameVect(2,1)]);
    %      data = step(shapeInserter, data, linex);
    %
    %      shapeInserter = vision.ShapeInserter('Shape','Lines','BorderColor','Custom',...
    %     'CustomBorderColor',[0 255 50],'LineWidth',1);
    %
    %      lysize = pdist([imagePoints(1,j) imagePoints(2,j); imagePoints(1,j)+frameVect(1,1,j) imagePoints(2)+frameVect(2,1)]);
    %      lineScaleFactor = 1/lysize * 50;
    %      liney = int32([imagePoints(1,j) imagePoints(2,j) imagePoints(1,j)+lineScaleFactor*frameVect(1,1) imagePoints(2)+lineScaleFactor*frameVect(2,1)]);
    %      data = step(shapeInserter, data, liney);
    %
    %      shapeInserter = vision.ShapeInserter('Shape','Lines','BorderColor','Custom',...
    %     'CustomBorderColor',[50 0 255],'LineWidth',1);
    %
    %      lzsize = pdist([imagePoints(1,j) imagePoints(2,j); imagePoints(1,j)+frameVect(1,1,j) imagePoints(2)+frameVect(2,1)]);
    %      lineScaleFactor = 1/lzsize * 50;
    %      linez = int32([imagePoints(1,j) imagePoints(2,j) imagePoints(1,j)+lineScaleFactor*frameVect(1,1) imagePoints(2)+lineScaleFactor*frameVect(2,1)]);
    %      data = step(shapeInserter, data, linez);
    imshow(mov(j).cdata);
    pause(0.1);
end

%% Output the results to video:
v1 = VideoWriter(strcat(PATH, 'outputVideos\', VIDEONAME, 'Results'));
open(v1)
writeVideo(v1,mov)
close(v1)
% %end %main