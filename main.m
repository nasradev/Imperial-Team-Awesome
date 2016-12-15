%main code
%function main()
clear
clc
close all 
warning off
%%Definitions
%Set the video file and define output video object
obj = VideoReader('IMG_6159.MOV');
vidWidth = obj.Width;
vidHeight = obj.Height;
mov = struct('cdata',zeros(vidHeight,vidWidth,3,'uint8'), 'colormap',[]);

M = tdfread('take1_005.csv', ',');


%Framerate Iphon
%dt = 1/30;

%Framerate Webcam
%dt = 1/25;

%Size of checkerboard squares
squareSize = 5.4;

%Load up the camera parameters:
load('iphoneCam.mat') %or whatever
cam = [cameraParams.IntrinsicMatrix', [0; 0; 1]];

firstBoard.colour = zeros(1,3);
secondBoard.colour = zeros(1,3);
thirdBoard.colour = zeros(1,3);


blueCboard = uint8([0 0 255]);
redCboard = uint8([255 0 0]);
blackCboard = uint8([0 0 0]);
    
    
P = [];
% Go through the video frames
obj.CurrentTime = 0;
timeOffset = round(obj.FrameRate) * (round(obj.CurrentTime));
k = 1;

% initialise marker detection the counters
staticRedCounter = 0;
staticYellowCounter = 0;
staticBlueCounter = 0;

%%%%%%%%%%% added by JUANA%%%%%%%%%%%%%%%%%%%
% Initialization of variables
NoFrames = round(obj.Duration*obj.frameRate);
x = zeros(NoFrames, 6);     % matrix for euler angles and tranlation
p0 = zeros(NoFrames, 5);    % points of the checkerboard
p1 = zeros(NoFrames, 5);
p2 = zeros(NoFrames, 5);
m0 = zeros(NoFrames, 5);    % points of the markers
m1 = zeros(NoFrames, 5);
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


% Contrived:
auroraStartOffset = 0;

imagePointsPadding = 40;

campoint11 = []
camorientation11 = []
campoint12 = []
% Go through the video frames
while hasFrame(obj);  
    data = readFrame(obj);
    
    data(:,:,1) = abs(data(:,:,1) - 40);
    
    tic
    % Get the first checkerboard:
    % If we already have the first checkerboard, try to find it again in
    % the nearby area:
    
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
    if board.imagePoints(1,1) > -1   
     firstBoard.imagePoints = [];
     firstBoard.imagePoints(:,1) = board.imagePoints(:,1) + xrange(1);
     firstBoard.imagePoints(:,2) = board.imagePoints(:,2) + yrange(1);
     firstBoard.worldPoints = board.worldPoints;
     firstBoard.threePoints(:,1) = board.threePoints(:,1)...
                                        + xrange(1);
                                    
     firstBoard.threePoints(:,2) = board.threePoints(:,2)...
                                        + yrange(1);
    else
      firstBoard.imagePoints = board.imagePoints;
      firstBoard.worldPoints = board.worldPoints;
    end
    else
      firstBoard = getBoardObject(data, squareSize);
    end
    
    p0(k,:) = zeros(5,1);%first step
    p1(k,:) = zeros(5,1);
    p2(k,:) = zeros(5,1);
    
         
    if k > 1 %next steps
        p0(k,:) = p0(k-1,:);
        p1(k,:) = p1(k-1,:);
        p2(k,:) = p2(k-1,:);
    end
    
    % Now check again if the first board has been found as it may not have
    % despite running getBoardObject.
    if firstBoard.imagePoints(1,1) > -1

     % Draw mask on the first cboard and find the next one
     temp_data = hideCheckerboard(data,...
         [firstBoard.imagePoints(1,:);firstBoard.imagePoints(end,:)]);
     
     %Plot the points (TODO remove)
     shapeInserter = vision.ShapeInserter('Shape','Circles','BorderColor','Custom',...
    'CustomBorderColor',firstBoard.colour);
     circle = int32([firstBoard.imagePoints(1,1) firstBoard.imagePoints(1,2) 40; 0 0 0]);
     data = step(shapeInserter, data, circle);
     
     % Find the second board
     
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
     if board.imagePoints(1,1) > -1   
      secondBoard.imagePoints = [];
      secondBoard.imagePoints(:,1) = board.imagePoints(:,1) + xrange(1);
      secondBoard.imagePoints(:,2) = board.imagePoints(:,2) + yrange(1);
      secondBoard.worldPoints = board.worldPoints;
      secondBoard.threePoints(:,1) = board.threePoints(:,1)...
                                       + xrange(1);
      secondBoard.threePoints(:,2) = board.threePoints(:,2)...
                                       + yrange(1);
     else
      secondBoard.imagePoints = [];
      secondBoard.imagePoints = [-1 -1];
      secondBoard.worldPoints = board.worldPoints;
     end
% %      txt = strcat('First Board: ', num2str(firstBoard.imagePoints(1,1)), ',', ...
% %           num2str(firstBoard.imagePoints(1,2)), '. Second Board:', ...
% %           num2str(secondBoard.imagePoints(1,1)), ',',  num2str(secondBoard.imagePoints(1,1)));
% %         position = [50 50];
% %      data = insertText(data, position, txt, 'FontSize',18,'BoxColor',...
% %      [0 0 255],'BoxOpacity',0.4,'TextColor','white');
    else
      secondBoard = getBoardObject(temp_data, squareSize);
      if isequal(firstBoard.colour,blackCboard) && ...
                      isequal(secondBoard.colour, blackCboard)
        secondBoard.colour = redCboard;
      end
        
    end
     
     
     
     if secondBoard.imagePoints(1,1) > -1
      
       shapeInserter = vision.ShapeInserter('Shape','Circles','BorderColor','Custom',...
    'CustomBorderColor',secondBoard.colour);
     circle = int32([secondBoard.imagePoints(1,1) secondBoard.imagePoints(1,2) 40; 0 0 0]);
     data = step(shapeInserter, data, circle); 
     
% %       % Draw mask on the second cboard and find the next one
% %       %THIRD BOARD
      temp_data = hideCheckerboard(temp_data,...
         [secondBoard.imagePoints(1,:);secondBoard.imagePoints(end,:)]);

      if isfield(thirdBoard, 'imagePoints') == 1 && thirdBoard.imagePoints(1,1) > -1
       xrange = round([min(thirdBoard.imagePoints(:,1)) - imagePointsPadding...
                    :max(thirdBoard.imagePoints(:,1)) + imagePointsPadding]);

       yrange = round([min(thirdBoard.imagePoints(:,2)) - imagePointsPadding...
                    :max(thirdBoard.imagePoints(:,2)) + imagePointsPadding]);

       xrange(xrange<1) = 1;
       yrange(yrange<1) = 1;
      xrange(xrange>sz(2)) = sz(2)-1;
      yrange(yrange>sz(1)) = sz(1)-1;
       board = getBoardObject(temp_data(max(yrange(1),1):...
                                   min(yrange(end),length(data(:,1,1))),...
                                   max(xrange(1),1):...
                                   min(xrange(end),length(data(1,:,1))),:),...
                                   squareSize);
       if board.imagePoints(1,1) > -1   
        thirdBoard.imagePoints = [];
        thirdBoard.imagePoints(:,1) = board.imagePoints(:,1) + xrange(1);
        thirdBoard.imagePoints(:,2) = board.imagePoints(:,2) + yrange(1);
        thirdBoard.worldPoints = board.worldPoints;
        thirdBoard.threePoints(:,1) = board.threePoints(:,1)...
                                         + xrange(1);
        thirdBoard.threePoints(:,2) = board.threePoints(:,2)...
                                         + yrange(1);
       else
        thirdBoard.imagePoints = board.imagePoints;
        thirdBoard.worldPoints = board.worldPoints;
       end
      else
        thirdBoard = getBoardObject(temp_data, squareSize);
        if isequal(firstBoard.colour,blackCboard) == 0 && ...
                      isequal(secondBoard.colour, blackCboard) == 0
          thirdBoard.colour = blackCboard;
        end
      end 
      
      if thirdBoard.imagePoints(1,1) > -1
         shapeInserter = vision.ShapeInserter('Shape','Circles','BorderColor','Custom',...
      'CustomBorderColor',thirdBoard.colour);
       circle = int32([thirdBoard.imagePoints(1,1) thirdBoard.imagePoints(1,2) 40; 0 0 0]);
       data = step(shapeInserter, data, circle);   
      end   
       
     end

    
    if firstBoard.colour(3) == 255 && firstBoard.imagePoints(1,1)>-1
        p0(k,:) = firstBoard.threePoints(1,:);
        p1(k,:) = firstBoard.threePoints(2,:);
        p2(k,:) = firstBoard.threePoints(3,:);
        [rot, trans] = extrinsics(firstBoard.imagePoints,...
            firstBoard.worldPoints, cameraParams);
        x(k,:) = [rotm2eul(rot.','ZYX') trans];
    elseif secondBoard.colour(3) == 255 && secondBoard.imagePoints(1,1)>-1
        p0(k,:) = secondBoard.threePoints(1,:);
        p1(k,:) = secondBoard.threePoints(2,:);
        p2(k,:) = secondBoard.threePoints(3,:);
        [rot, trans] = extrinsics(secondBoard.imagePoints,...
            secondBoard.worldPoints, cameraParams);
        x(k,:) = [rotm2eul(rot.','ZYX') trans];
    elseif thirdBoard.colour(3) == 255 && thirdBoard.imagePoints(1,1)>-1
        p0(k,:) = thirdBoard.threePoints(1,:);
        p1(k,:) = thirdBoard.threePoints(2,:);
        p2(k,:) = thirdBoard.threePoints(3,:);
        [rot, trans] = extrinsics(thirdBoard.imagePoints,...
            thirdBoard.worldPoints, cameraParams);
        x(k,:) = [rotm2eul(rot.','ZYX') trans];
    end
    rot1(:,:,k) = rot.';
    else
      display('no checkerboards found')
    end

     
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %%%%%%%% VALIDATION %%%%%%%%
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % Get the R and t of the World with respect to the black checkerboard: 
    if (isempty(P)) &&  isequal(firstBoard.colour, [0 0 0]) && firstBoard.imagePoints(1,1) > 0
           [R,t] = extrinsics(firstBoard.imagePoints, ...
                    firstBoard.worldPoints, cameraParams);
      P = cameraParams.IntrinsicMatrix * [R t'];
    elseif isempty(P) &&  isequal(secondBoard.colour, [0 0 0]) && secondBoard.imagePoints(1,1) > 0
      [R,t] = extrinsics(secondBoard.imagePoints, ...
                    secondBoard.worldPoints, cameraParams);
      P = cameraParams.IntrinsicMatrix * [R t'];
    elseif isempty(P) &&  isequal(thirdBoard.colour, [0 0 0]) && thirdBoard.imagePoints(1,1) > 0
      [R,t] = extrinsics(thirdBoard.imagePoints, ...
                    thirdBoard.worldPoints, cameraParams);
      P = cameraParams.IntrinsicMatrix * [R t'];
    end
    auroraFrame = floor(1.4 *  (timeOffset + k)) + auroraStartOffset;
    toc
    
    
    
    if isempty(P) == 0 && auroraFrame <= length( M.Ty1 )

      record = [M.Tx1(auroraFrame), M.Ty1(auroraFrame), M.Tz1(auroraFrame), M.Q01(auroraFrame), M.Qx1(auroraFrame), ...
                    M.Qy1(auroraFrame), M.Qz1(auroraFrame)];
      tic
      % Get the position of the tool sensor in Aurora frame
      [campoint1, cameurler, camrotation] = getAuroraTranslation(record, R, t);
      isBadfit=M.State1(auroraFrame);
    if isBadfit(1)=='B'
        campoint1=campoint11(end,:);
        camorientation1=camorientation11(end,:);
    end  
      campoint11 = [campoint11; campoint1];
      camorientation11 = [camorientation11; camrotation];
%       camorientation11 = [camorientation11; camorientation1];
      %[focal length in mm]*[resolution]/[sensor size in mm]
      K = cameraParams.IntrinsicMatrix;
      % Transform into image point:
      impoint = campoint1 * K;
      % This rescales for Z
      impoint = impoint / impoint(3);
    auroravec=camrotation*eye(3,3);
      auroravec=auroravec*K;
      auroraimpts(:,1)=auroravec(:,1)/auroravec(3,1);
      auroraimpts(:,2)=auroravec(:,2)/auroravec(3,2);
      auroraimpts(:,3)=auroravec(:,3)/auroravec(3,3);
     shapeInserter = vision.ShapeInserter('Shape','Lines','BorderColor','Custom',...
    'CustomBorderColor',[165 42 42],'LineWidth',1);
% shapeInserter=vision.ShapeInserter('Shape','Lines')
     lxsize = pdist([impoint(1) impoint(2); impoint(1)+auroraimpts(1,1) impoint(2)+auroraimpts(2,1)]);
     lineScaleFactor = 1/lxsize * 50;
     linex = int32([impoint(1) impoint(2) impoint(1)+lineScaleFactor*auroraimpts(1,1) impoint(2)+lineScaleFactor*auroraimpts(2,1)]);
     data = step(shapeInserter, data, linex); 
     
     lysize = pdist([impoint(1) impoint(2); impoint(1)+auroraimpts(1,2) impoint(2)+auroraimpts(2,2)]);
     lineScaleFactor = 1/lysize * 50;
     liney = int32([impoint(1) impoint(2) impoint(1)+lineScaleFactor*auroraimpts(1,2) impoint(2)+lineScaleFactor*auroraimpts(2,2)]);     
     data = step(shapeInserter, data, liney); 
     
     lzsize = pdist([impoint(1) impoint(2); impoint(1)+auroraimpts(1,3) impoint(2)+auroraimpts(2,3)]);
     lineScaleFactor = 1/lzsize * 50;
     linez = int32([impoint(1) impoint(2) impoint(1)+10*auroraimpts(1,3) impoint(2)+10*auroraimpts(2,3)]);
     data = step(shapeInserter, data, linez); 
      % BTW camera position C in world frame is:
      % C = -R'*t
     toc
     
    end
    
    if isfield(M, 'Ty2') && isempty(P) == 0 && auroraFrame <= length( M.Ty2 )

      record = [M.Tx2(auroraFrame), M.Ty2(auroraFrame), M.Tz2(auroraFrame), M.Q02(auroraFrame), M.Qx2(auroraFrame), ...
                    M.Qy2(auroraFrame), M.Qz2(auroraFrame)];
%       tic
      % Get the position of the tool sensor in Aurora frame
      [campoint, cameuler, camrotation] = getAuroraTranslation(record, R, t);
      %Ignore Bad Fits

%         isBadfit=M.State1(auroraFrame);
%         if isBadfit(1)=='B'
%             campoint2=campoint11(end,:);
%             camorientation1=camorientation11(end,:);
%         end 
% 
%       campoint12 = [campoint12; campoint2];
%       camorientation12 = [camorientation12; camorientation12];
      %[focal length in mm]*[resolution]/[sensor size in mm]
      K = cameraParams.IntrinsicMatrix;
      % Transform into image point:
      impoint = campoint * K;
      % This rescales for Z
      impoint = impoint / impoint(3);
%      shapeInserter = vision.ShapeInserter('Shape','Circles','BorderColor','Custom',...
%     'CustomBorderColor',[0 255 0]);
%      circle = int32([impoint(1) impoint(2) 10; 0 0 0]);
%      data = step(shapeInserter, data, circle); 
      % BTW camera position C in world frame is:
      % C = -R'*t
      
      auroravec=camrotation*eye(3,3);
      auroravec=auroravec*K;
      auroraimpts(:,1)=auroravec(:,1)/auroravec(3,1);
      auroraimpts(:,2)=auroravec(:,2)/auroravec(3,2);
      auroraimpts(:,3)=auroravec(:,3)/auroravec(3,3);
     shapeInserter = vision.ShapeInserter('Shape','Lines','BorderColor','Custom',...
    'CustomBorderColor',[0 255 0],'LineWidth',1);
% shapeInserter=vision.ShapeInserter('Shape','Lines')
     lxsize = pdist([impoint(1) impoint(2); impoint(1)+auroraimpts(1,1) impoint(2)+auroraimpts(2,1)]);
     lineScaleFactor = 1/lxsize * 50;
     linex = int32([impoint(1) impoint(2) impoint(1)+lineScaleFactor*auroraimpts(1,1) impoint(2)+lineScaleFactor*auroraimpts(2,1)]);
     data = step(shapeInserter, data, linex); 
     
     lysize = pdist([impoint(1) impoint(2); impoint(1)+auroraimpts(1,2) impoint(2)+auroraimpts(2,2)]);
     lineScaleFactor = 1/lysize * 50;
     liney = int32([impoint(1) impoint(2) impoint(1)+lineScaleFactor*auroraimpts(1,2) impoint(2)+lineScaleFactor*auroraimpts(2,2)]);     
     data = step(shapeInserter, data, liney); 
     
     lzsize = pdist([impoint(1) impoint(2); impoint(1)+auroraimpts(1,3) impoint(2)+auroraimpts(2,3)]);
     lineScaleFactor = 1/lzsize * 50;
     linez = int32([impoint(1) impoint(2) impoint(1)+10*auroraimpts(1,3) impoint(2)+10*auroraimpts(2,3)]);
     data = step(shapeInserter, data, linez); 
     toc
     
    end
    
    
    
        
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %%%%%%%%%%%% GET MARKER POSITIONS: %%%%%%%%%%%%
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    tic
    % Red and Yellow in tool 1, Green and Blue in tool 2
% % % % %      [red yellow green blue] = getMarkerPos(data);
% % % % %      position = [50 50];
% % % % %      txt = strcat('Red: ', num2str(red(1,1)), ', ', num2str(red(1,2)));
% % % % %      txt = strcat(txt, ';  Yellow: ', num2str(yellow(1,1)), ...
% % % % %                 ', ', num2str(yellow(1,2)), ...
% % % % %                 ',  aurora frame number: ', num2str(x), ...
% % % % %                 ' at time ', num2str(obj.CurrentTime));
% % % % %      data = insertText(data, position, txt, 'FontSize',18,'BoxColor',...
% % % % %      [0 0 255],'BoxOpacity',0.4,'TextColor','white');
% % % % %     toc
% % % % %     
% % % % %     
% % % % %     
    if k == 1
      % crop the images interactively around the markers
        % HIDE CHECKERBOARD!!!
        % Red marker
        tinyRed = temp_data;
        [red, redArea] = getRedPos(tinyRed);
        if( red(1) ~=  0 || red(2) ~= 0)
                % reset the k to 0 because a marker was detected
                staticRedCounter = 0;
        else
                display('No red marker detected');
        end
        
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
      % RED MARKER
      % Square centered on the red marker with an area 5 times the marker
      % area
      width = sqrt(redArea * 20);
      % if the area of the marker is too small, give a min width
      if width < 50
          width = 50;
      end

      % do the rectangle
      [rect, xrect, yrect] = doSquare(red(1), red(2), width, vidWidth, vidHeight);

      % crop the image around the marker
      tinyRed = imcrop(data,rect);

      % if a marker was detected in the last frame
      if staticRedCounter == 0
          % get the new position of the red marker
          lastRed = red;
          [red, redArea] = getRedPos(tinyRed);
          if( red(1) ~=  0 || red(2) ~= 0)
              red(1) = red(1) + xrect;
              red(2) = red(2) + yrect;
              % reset the k to 0 because a marker was detected
              staticRedCounter = 0;
          else
              red = lastRed;
              staticRedCounter = staticRedCounter + 1;
          end
          % if no marker is detected in 3 consecutive frames use a bigger
          % image
      else
          % Use the entire image to look for the maker
          tinyRed = data;
          % get the new position of the red marker
          lastRed = red;
          [red, redArea] = getRedPos(tinyRed);
          if( red(1) ~=  0 || red(2) ~= 0)
              % reset the k to 0 because a marker was detected
              staticRedCounter = 0;
          else
              red = lastRed;
              staticRedCounter = staticRedCounter + 1;
          end
      end
    
      
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
      
       m0(k,:) = red;
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
           %Plot the yellow marker
       shapeInserter = vision.ShapeInserter('Shape','Circles','BorderColor','Custom',...
          'CustomBorderColor',[0 0 255]);
       circle = int32([ blue(1) blue(2) 20; 0 0 0]);
       data = step(shapeInserter, data, circle);
    end
     
    mov(k).cdata = data;
    k = k+1;
    
    imshow(data)
end %hasFrame

%% Variables Definition
%load('MUpad') %load the variables generated in mupad

%Hand Dimentions
tr = 0;%mm
a = 80*pi/180;

%% Observer
squareSize = 5.4; %size of the scheckerboard squares in mm

%% Data

dt = 1/obj.FrameRate;%0.01;
T = dt*(k-1);
t = dt : dt : T;

P0 = [t', p0(:,4:5), zeros(length(t),1)];%checkerboard reference (local)
P1 = [t', p1(:,4:5), zeros(length(t),1)];
P2 = [t', p2(:,4:5), zeros(length(t),1)];

Y = [t', p0(:,1:2), p1(:,1:2), p2(:,1:2)];%measure (camera frame)
X = [t' x];

x1 = [zeros(1, size(x,2)); x(2:end, :)];
X1 = [t' x1];
X10 = [x(1,1) zeros(1,2) x(1,2) zeros(1,2) x(1,3) zeros(1,2) x(1,4) ...
    zeros(1,2) x(1,5) zeros(1,2) x(1,6) zeros(1,2)];
% Y = minimum_jerk(Y);
% X = minimum_jerk(X);

M0 = [t', m0(:,3:5)];%tool reference (local)
M1 = [t', m1(:,3:5)];

Y1 = [t', m0(:,1:2), m1(:,1:2)];%measure (camer frame)

% Y1 = minimum_jerk(Y1);

%% Checkerboard 1 State Evolution
% %F = double(F); %state evolution
% F = [zeros(6,6), eye(6), zeros(6,6), zeros(6,6);
%     zeros(6,12), eye(6), zeros(6,6);
%     zeros(6,18), eye(6);
%     zeros(6,24)];
% 
% B = [zeros(18,6); eye(6)]; %observer linear input
% 
% C = [eye(6), zeros(6,18)];
s = tf('s');

Gol1 = 1/s^4*eye(6);
Gol2 = 1/s^2*eye(4);

[F, B, C, D] = ssdata(Gol1);
z0c = [p0(1,1:2), p1(1,1:2), p2(1,1:2), zeros(1,18)];%zeros(1,24);%[[0, 0, 2000, 380, 2000, 380], zeros(1,18)];


%% Marker 1 State Evolution
% F1 = [zeros(4,4), eye(4);
%     zeros(4,8)];
% 
% B1 = [zeros(4,4); eye(4)]; %observer linear input
% 
% C1 = [eye(4), zeros(4,4)];
[F1, B1, C1, D1] = ssdata(Gol2);
z0m = zeros(1,8);%[m0(1,1:2), m1(1,1:2), zeros(1,4)];

%% Gain
load('K')
%Ksys = ss(K);
[Ak, Bk, Ck, Dk] = ssdata(K1);
[Ak_1, Bk_1, Ck_1, Dk_1] = ssdata(K2);%ssdata(K_1);

%% Minimu Jerk Filter
Dd = 0.05*T;

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
    60/(Dd^3)];

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
% figure(1) %Measure Plot
% subplot(3,2,1)
% plot(t, Y(:,2), t, hatY.data(2:end,1), '--')%, t, y0(1,:),'.')
% %ylim([0,1e3])
% subplot(3,2,2)
% plot(t, Y(:,3), t, hatY.data(2:end,2), '--')%, t, y0(2,:),'.')
% %ylim([0,1e3])
% subplot(3,2,3)
% plot(t, Y(:,4), t, hatY.data(2:end,3), '--')%, t, y1(1,:),'.')
% %ylim([0,1e3])
% subplot(3,2,4)
% plot(t, Y(:,5), t, hatY.data(2:end,4), '--')%, t, y1(2,:),'.')
% %ylim([0,1e3])
% subplot(3,2,5)
% plot(t, Y(:,6), t, hatY.data(2:end,5), '--')%, t, y2(1,:),'.')
% %ylim([0,1e3])
% subplot(3,2,6)
% plot(t, Y(:,7), t, hatY.data(2:end,6), '--')%, t, y2(2,:),'.')
% %ylim([0,1e3])
% 
% 
% yAbsErr = abs(Y(:,2:end) - hatY.data(2:end,:));
% 
% figure(2) %Measure Absolute Error Plot
% subplot(3,2,1)
% plot(t, yAbsErr(:,1))
% %ylim([0,1e3])
% subplot(3,2,2)
% plot(t, yAbsErr(:,2))
% %ylim([0,1e3])
% subplot(3,2,3)
% plot(t, yAbsErr(:,3))
% %ylim([0,1e3])
% subplot(3,2,4)
% plot(t, yAbsErr(:,4))
% %ylim([0,1e3])
% subplot(3,2,5)
% plot(t, yAbsErr(:,5))
% %ylim([0,1e3])
% subplot(3,2,6)
% plot(t, yAbsErr(:,6))
% %ylim([0,1e3])
% 
% % figure(3) %State Plot
% % subplot(3,2,1)
% % plot(t, hatX.data(2:end,1), t, x(:,1), '--')
% % xlabel('time [s]')
% % ylabel('\theta [rad]')
% % grid on
% % subplot(3,2,2)
% % plot(t, hatX.data(2:end,2), t, x(:,2), '--')
% % xlabel('time [s]')
% % ylabel('\phi [rad]')
% % grid on
% % subplot(3,2,3)
% % plot(t, hatX.data(2:end,3), t, x(:,3), '--')
% % xlabel('time [s]')
% % ylabel('\psi [rad]')
% % grid on
% % subplot(3,2,4)
% % plot(t, hatX.data(2:end,7), t, x(:,4), '--')
% % xlabel('time [s]')
% % ylabel('x [mm]')
% % grid on
% % subplot(3,2,5)
% % plot(t, hatX.data(2:end,9), t, x(:,5), '--')
% % xlabel('time [s]')
% % ylabel('y [mm]')
% % grid on
% % subplot(3,2,6)
% % plot(t, hatX.data(2:end,11), t, x(:,6), '--')
% % xlabel('time [s]')
% % ylabel('z [mm]')
% % grid on
% figure(3) %State Plot
% subplot(3,2,1)
% plot(t, X(:,2))
% xlabel('time [s]')
% ylabel('\theta [rad]')
% grid on
% subplot(3,2,2)
% plot(t, X(:,3))
% xlabel('time [s]')
% ylabel('\phi [rad]')
% grid on
% subplot(3,2,3)
% plot(t, X(:,4))
% xlabel('time [s]')
% ylabel('\psi [rad]')
% grid on
% subplot(3,2,4)
% plot(t, X(:,5))
% xlabel('time [s]')
% ylabel('x [mm]')
% grid on
% subplot(3,2,5)
% plot(t, X(:,6))
% xlabel('time [s]')
% ylabel('y [mm]')
% grid on
% subplot(3,2,6)
% plot(t, X(:,7))
% xlabel('time [s]')
% ylabel('z [mm]')
% grid on
% 
% figure(4) %Measure Plot
% subplot(2,2,1)
% plot(t, Y1(:,2), t, hatY1.data(2:end,1), '--')
% %ylim([0,1e3])
% subplot(2,2,2)
% plot(t, Y1(:,3), t, hatY1.data(2:end,2), '--')
% %ylim([0,1e3])
% subplot(2,2,3)
% plot(t, Y1(:,4), t, hatY1.data(2:end,3), '--')
% %ylim([0,1e3])
% subplot(2,2,4)
% plot(t, Y1(:,5), t, hatY1.data(2:end,4), '--')
% %ylim([0,1e3])


% yAbsErr = abs(Y1(:,2:end) - hatY1.data(2:end,:));
% 
% figure(5) %Measure Absolute Error Plot
% subplot(2,2,1)
% plot(t, yAbsErr(:,1))
% %ylim([0,1e3])
% subplot(2,2,2)
% plot(t, yAbsErr(:,2))
% %ylim([0,1e3])
% subplot(2,2,3)
% plot(t, yAbsErr(:,3))
% %ylim([0,1e3])
% subplot(2,2,4)
% plot(t, yAbsErr(:,4))
% %ylim([0,1e3])
% 
% figure(6) %State Plot
% subplot(2,1,1)
% plot(t, -hatX1.data(2:end,1))
% xlabel('time [s]')
% ylabel('\alpha [rad]')
% grid on
% subplot(2,1,2)
% plot(t, -hatX1.data(2:end,3))
% xlabel('time [s]')
% ylabel('d [mm]')
% grid on


%% Results
l = [100; 50; 5];
%hatX1.data = zeros(size(hatX1.data));

worldPoints = zeros(4,length(t));
imagePoints = zeros(3,length(t));

worldTips = zeros(3,length(t));
%Position and Orientation of the Tool
for i = 1:length(t)%position
    [worldPoints(:,i), imagePoints(:,i)] = proj(a,l,hatX1.data(i,:),hatX2.data(i,:),cam);
end
%worldPoints = worldTips;
worldAngles = hatX2.data(2:end,1:3) + [zeros(length(t),2), hatX1.data(2:end,1) + a];


figure(1)
subplot(3,2,1)
plot(t(1:length(campoint11)), [worldPoints(1,1:length(campoint11)); campoint11(:,1)'])
grid on
xlabel('time [s]')
ylabel('x [mm]')
subplot(3,2,2)
plot(t(1:length(campoint11)), [worldPoints(2,1:length(campoint11)); campoint11(:,2)'])
grid on
xlabel('time [s]')
ylabel('y [mm]')
subplot(3,2,3)
plot(t(1:length(campoint11)), [worldPoints(3,1:length(campoint11)); campoint11(:,3)'])
grid on
xlabel('time [s]')
ylabel('z [mm]')
subplot(3,2,4)
% plot(t(1:length(campoint11)), [worldAngles(1:length(campoint11),1)'; camorientation11(:,1)'])
% grid on
% xlabel('time [s]')
% ylabel('\theta (z rot) [rad]')
% subplot(3,2,5)
% plot(t(1:length(campoint11)), [worldAngles(1:length(campoint11),2)'; camorientation11(:,2)'])
% grid on
% xlabel('time [s]')
% ylabel('\phi (y rot) [rad]')
% subplot(3,2,6)
% plot(t(1:length(campoint11)), [worldAngles(1:length(campoint11),3)';camorientation11(:,3)'])
% grid on
% xlabel('time [s]')
% ylabel('\psi (x rot) [rad]')
% 
% %Plot abs error
% Err_x=abs(worldPoints(1,1:length(campoint11))- camorientation11(:,1)');
% Err_y=abs(worldPoints(2,1:length(campoint11))- camorientation11(:,2)');
% Err_z=abs(worldPoints(3,1:length(campoint11))- camorientation11(:,3)');
% Err_ax=abs(worldAngles(1:length(campoint11),1)'- camorientation11(:,1)');
% Err_ay=abs(worldAngles(1:length(campoint11),2)'- camorientation11(:,2)');
% Err_az=abs(worldAngles(1:length(campoint11),3)'- camorientation11(:,3)');
% figure(2)
% subplot(3,2,1)
% plot(t(1:length(campoint11)), Err_x)
% grid on
% xlabel('time [s]')
% ylabel('abs error x [mm]')
% subplot(3,2,2)
% plot(t(1:length(campoint11)), Err_y)
% grid on
% xlabel('time [s]')
% ylabel('abs error y [mm]')
% subplot(3,2,3)
% plot(t(1:length(campoint11)), Err_z)
% grid on
% xlabel('time [s]')
% ylabel('abs error z [mm]')
% subplot(3,2,4)
% plot(t(1:length(campoint11)), Err_ax)
% grid on
% xlabel('time [s]')
% ylabel('\theta (z rot) [rad]')
% subplot(3,2,5)
% plot(t(1:length(campoint11)), Err_ay)
% grid on
% xlabel('time [s]')
% ylabel('\phi (y rot) [rad]')
% subplot(3,2,6)
% plot(t(1:length(campoint11)), Err_az)
% grid on
% xlabel('time [s]')
% ylabel('\psi (x rot) [rad]')
% % % % %% Plot Frame on Video
% % % % obj1 = VideoReader('IMG_6156.MOV');
% % % % vidWidth = obj1.Width;
% % % % vidHeight = obj1.Height;
% % % % mov1 = struct('cdata',zeros(vidHeight,vidWidth,3,'uint8'), 'colormap',[]);
% % % % 
% % % % 
% % % % secondColour = [155 200 255];
% % % % shapeInserter = vision.ShapeInserter('Shape','Circles','BorderColor','Custom',...
% % % %                   'CustomBorderColor',secondColour);
% % % % for j= 1:length(t)
% % % %   data1 = readFrame(obj1);
% % % %   circle = int32([imagePoints(1,j) imagePoints(2,j) 2; 0 0 0]); %2 is the size
% % % %   %refFrame = quiver3(zeros(3,1),zeros(3,1),zeros(3,1),[1;0;0],[0;1;0],[0;0;1]);
% % % %   mov1(j).cdata = step(shapeInserter, data1, circle);
% % % %   %mov1(j).cdata = step(shapeInserter, data1, refFrame);
% % % % end 

%Output the results to video:
v1 = VideoWriter('C:\Dev\gio\IMG_5956_Res');
open(v1)
writeVideo(v1,mov)
close(v1)
% %end %main