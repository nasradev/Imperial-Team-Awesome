%main code
%function main()
clear
clc
close all 
warning off
%%Definitions
%Set the video file and define output video object
obj = VideoReader('C:\dev\Matlab\TeamProject\Videos\20170316_150223.mp4');
vidWidth = obj.Width;
vidHeight = obj.Height;
mov = struct('cdata',zeros(vidHeight,vidWidth,3,'uint8'), 'colormap',[]);

M = tdfread('C:\dev\Matlab\TeamProject\Videos\20170316_152250.csv', ',');


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

%%% TODO: SET THIS VARIABLE TO WHATEVER THE COLOUR OF THE 'GLOVE' BOARD IS
%%% Black is always 'Base' i.e. reference frame
gloveBoard = redCboard;
refBoard = blackCboard;
    
P = [];
% Go through the video frames
obj.CurrentTime = 0;
timeOffset = round(obj.FrameRate) * (round(obj.CurrentTime));
k = 1;

% initialise marker detection the counters
staticRedCounter = 0;
staticYellowCounter = 0;
staticGreenCounter = 0;
staticBlueCounter = 0;

%%%%%%%%%%% added by JUANA bitches.%%%%%%%%%%%%%%%%%%%
% Initialization of variables
NoFrames = round(obj.Duration*obj.frameRate);
x = zeros(NoFrames, 6);     % matrix for euler angles and tranlation
%x1 = zeros(NoFrames, 6);     % matrix for euler angles and tranlation
m0 = zeros(NoFrames, 5);    % points of the markers
m1 = zeros(NoFrames, 5);
% m2 = zeros(NoFrames, 5);    % points of the markers
% m3 = zeros(NoFrames, 5);
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


% Contrived:
auroraStartOffset = 0;

imagePointsPadding = 40;

campoint11 = [];
camorientation11 = [];
campoint12 = [];
camorientation12 = [];
% Go through the video frames
while hasFrame(obj) 
    data = readFrame(obj);

%    USE THIS HACK IF IMAGE INTENSITY IS TOO HIGH       
%    data(:,:,1) = abs(data(:,:,1) - 40);

    
%     tic
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
         end % Now we have the second board (probably)
    
        % Now check again if the second board has been found as it may not have
        % despite running getBoardObject.
        if secondBoard.imagePoints(1,1) > -1
            % Now that we found 2 checkerboards, see which one looks more "black"
            cb1sum = firstBoard.colour(1) + firstBoard.colour(2) + firstBoard.colour(3);
            cb2sum = secondBoard.colour(1) + secondBoard.colour(2) + secondBoard.colour(3);        
            if cb1sum < cb2sum
                firstBoard.colour = refBoard;
                secondBoard.colour = gloveBoard;
            else
                firstBoard.colour = gloveBoard;
                secondBoard.colour = refBoard;
            end;
        
         % TODO: can comment out the next 6 commands to stop drawing a 
         % little circle where the checkerboards' tops is detected.
         shapeInserter = vision.ShapeInserter('Shape','Circles','BorderColor','Custom',...
        'CustomBorderColor',firstBoard.colour);
         circle = int32([firstBoard.imagePoints(1,1) firstBoard.imagePoints(1,2) 40; 0 0 0]);
         data = step(shapeInserter, data, circle);
         
         shapeInserter = vision.ShapeInserter('Shape','Circles','BorderColor','Custom',...
        'CustomBorderColor',secondBoard.colour);
         circle = int32([secondBoard.imagePoints(1,1) secondBoard.imagePoints(1,2) 40; 0 0 0]);
         data = step(shapeInserter, data, circle); 


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


        %Get Euler Angles and Translation Red Checkerboard
        if firstBoard.colour(1) == 255 && firstBoard.imagePoints(1,1)>-1
            [rot, trans] = extrinsics(firstBoard.imagePoints,...
                firstBoard.worldPoints, cameraParams);
            x(k,:) = [rotm2eul(rot.','ZYX') trans];
        elseif secondBoard.colour(1) == 255 && secondBoard.imagePoints(1,1)>-1
            [rot, trans] = extrinsics(secondBoard.imagePoints,...
                secondBoard.worldPoints, cameraParams);
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
    %% checkerboard once, save its position and then just look for the 
    %% RED/BLUE one in the next frames.

        
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %%%%%%%%%%%% GET MARKER POSITIONS: %%%%%%%%%%%%
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%     tic
    % Red and Yellow in tool 1, Green and Blue in tool 2
    

%% TODO: Decide on which markers to use if we only going to use 1 tool.
%% CURRENTLY it's set to just Yellow and Blue. (and red cboard).
%% PERHAPS: We put the BLUE and YELLOW markers on the single tool as they
%% are best detected.
    if k == 1
      % crop the images interactively around the markers
        % HIDE CHECKERBOARD!!!
        % Red marker
%         tinyRed = temp_data;
%         [red, redArea] = getRedPos(tinyRed);
%         if( red(1) ~=  0 || red(2) ~= 0)
%                 % reset the k to 0 because a marker was detected
%                 staticRedCounter = 0;
%         else
%                 display('No red marker detected');
%         end
%         
        % Yellow Marker
        tinyYellow = temp_data;
        [yellow, yellowArea] = getYellowPos(tinyYellow);
        if( yellow(1) ~=  0 || yellow(2) ~= 0)
                % reset the k to 0 because a marker was detected
                staticRedCounter = 0;
        else
                display('No yellow marker detected');
        end
        
%         % Green marker
%         tinyGreen = temp_data;
%         [green, greenArea] = getGreenPos(tinyGreen);
%         if( green(1) ~=  0 || green(2) ~= 0)
%                 % reset the counter to 0 because a marker was detected
%                 staticGreenCounter = 0;
%         else
%                 display('No green marker detected');
%         end
%         
               
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
%         
%       % RED MARKER
%       % Square centered on the red marker with an area 5 times the marker
%       % area
%       width = sqrt(redArea * 20);
%       % if the area of the marker is too small, give a min width
%       if width < 50
%           width = 50;
%       end
% 
%       % do the rectangle
%       [rect, xrect, yrect] = doSquare(red(1), red(2), width, vidWidth, vidHeight);
% 
%       % crop the image around the marker
%       tinyRed = imcrop(data,rect);
% 
%       % if a marker was detected in the last frame
%       if staticRedCounter == 0
%           % get the new position of the red marker
%           lastRed = red;
%           [red, redArea] = getRedPos(tinyRed);
%           if( red(1) ~=  0 || red(2) ~= 0)
%               red(1) = red(1) + xrect;
%               red(2) = red(2) + yrect;
%               % reset the k to 0 because a marker was detected
%               staticRedCounter = 0;
%           else
%               red = lastRed;
%               staticRedCounter = staticRedCounter + 1;
%           end
%           % if no marker is detected in 3 consecutive frames use a bigger
%           % image
%       else
%           % Use the entire image to look for the maker
%           tinyRed = data;
%           % get the new position of the red marker
%           lastRed = red;
%           [red, redArea] = getRedPos(tinyRed);
%           if( red(1) ~=  0 || red(2) ~= 0)
%               % reset the k to 0 because a marker was detected
%               staticRedCounter = 0;
%           else
%               red = lastRed;
%               staticRedCounter = staticRedCounter + 1;
%           end
%       end
    
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
      
       m0(k,:) = blue; %% TODO: Put the blue marker on top of the tool
       m1(k,:) = yellow;
       
       
%         % GREEN MARKER
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
 %   m2(k,:) = blue;
 %   m3(k,:) = green;
    
                %% TODO MOVE TO FUNCTION?
                %%%%%%%%%%%%%%%%%%%%%%%%%%%%
                %%%%%%%% VALIDATION %%%%%%%%
                %%%%%%%%%%%%%%%%%%%%%%%%%%%%
               
                %% Consider removing the part about Aurora from this portion of the code
                %% and just reading all the aurora entries in the end (outside the while loop).
                %% We currently have the aurora code here because we need to match the frames, but
                %% if we ignore the time vectors we don't need to do that (all the 1.4* logic)
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
            %     toc


                %%TODO: RENAME THE STUPID CAMPOINT/CAMEULER VARIABLES
                if isempty(P) == 0 && auroraFrame <= length( M.Ty1 )

                  record = [M.Tx1(auroraFrame), M.Ty1(auroraFrame), M.Tz1(auroraFrame), M.Q01(auroraFrame), M.Qx1(auroraFrame), ...
                                M.Qy1(auroraFrame), M.Qz1(auroraFrame)];
                  tic
                  % Get the position of the tool sensor in Aurora frame
                  [campoint1, cameuler, camrotation] = getAuroraTranslation(record, R, t);
                   %Ignore Bad Fits

                    isBadfit=M.State1(auroraFrame);
                    if isBadfit(1)=='B'
                        campoint2=campoint12(end,:);
                        cameuler=camorientation12(end,:);
                    end
                  campoint11 = [campoint11; campoint1];
                  camorientation11 = [camorientation11; cameuler];
                  %[focal length in mm]*[resolution]/[sensor size in mm]
                  K = cameraParams.IntrinsicMatrix;
                  % Transform into image point:
                  impoint = campoint1 * K;
                  % This rescales for Z
                  impoint = impoint / impoint(3);
                 shapeInserter = vision.ShapeInserter('Shape','Circles','BorderColor','Custom',...
                'CustomBorderColor',[255 0 0]);
                 circle = int32([impoint(1) impoint(2) 10; 0 0 0]);
                 data = step(shapeInserter, data, circle); 

                 %%TODO: SOMEBODY EXPLAIN THE BELOW CODE PLIS.
                  % BTW camera position C in world frame is:
                  % C = -R'*t
            %      toc
            %         auroravec=camrotation*eye(3,3);
            %       auroravec=auroravec*K;
            %       auroraimpts(:,1)=auroravec(:,1)/auroravec(3,1);
            %       auroraimpts(:,2)=auroravec(:,2)/auroravec(3,2);
            %       auroraimpts(:,3)=auroravec(:,3)/auroravec(3,3);
            %      shapeInserter = vision.ShapeInserter('Shape','Lines','BorderColor','Custom',...
            %     'CustomBorderColor',[255 0 0],'LineWidth',1);
            % % shapeInserter=vision.ShapeInserter('Shape','Lines')
            %      lxsize = pdist([impoint(1) impoint(2); impoint(1)+auroraimpts(1,1) impoint(2)+auroraimpts(2,1)]);
            %      lineScaleFactor = 1/lxsize * 50;
            %      linex = int32([impoint(1) impoint(2) impoint(1)+lineScaleFactor*auroraimpts(1,1) impoint(2)+lineScaleFactor*auroraimpts(2,1)]);
            %      data = step(shapeInserter, data, linex); 
            %      
            %      shapeInserter = vision.ShapeInserter('Shape','Lines','BorderColor','Custom',...
            %     'CustomBorderColor',[0 255 0],'LineWidth',1);
            %      
            %      lysize = pdist([impoint(1) impoint(2); impoint(1)+auroraimpts(1,2) impoint(2)+auroraimpts(2,2)]);
            %      lineScaleFactor = 1/lysize * 50;
            %      liney = int32([impoint(1) impoint(2) impoint(1)+lineScaleFactor*auroraimpts(1,2) impoint(2)+lineScaleFactor*auroraimpts(2,2)]);     
            %      data = step(shapeInserter, data, liney); 
            %      
            %      shapeInserter = vision.ShapeInserter('Shape','Lines','BorderColor','Custom',...
            %     'CustomBorderColor',[0 0 255],'LineWidth',1);
            %      
            %      lzsize = pdist([impoint(1) impoint(2); impoint(1)+auroraimpts(1,3) impoint(2)+auroraimpts(2,3)]);
            %      lineScaleFactor = 1/lzsize * 50;
            %      linez = int32([impoint(1) impoint(2) impoint(1)+10*auroraimpts(1,3) impoint(2)+10*auroraimpts(2,3)]);
            %      data = step(shapeInserter, data, linez); 

                end

                if isfield(M, 'Ty2') && isempty(P) == 0 && auroraFrame <= length( M.Ty2 )

                  record = [M.Tx2(auroraFrame), M.Ty2(auroraFrame), M.Tz2(auroraFrame), M.Q02(auroraFrame), M.Qx2(auroraFrame), ...
                                M.Qy2(auroraFrame), M.Qz2(auroraFrame)];
            %       tic
                  % Get the position of the tool sensor in Aurora frame
                  [campoint2, cameuler, camorientation2] = getAuroraTranslation(record, R, t);
                  %Ignore Bad Fits

                    isBadfit=M.State1(auroraFrame);
                    if isBadfit(1)=='B'
                        campoint2=campoint12(end,:);
                        cameuler=camorientation12(end,:);
                    end 

                  campoint12 = [campoint12; campoint2];
                  camorientation12 = [camorientation12; cameuler];
                  %[focal length in mm]*[resolution]/[sensor size in mm]
                  K = cameraParams.IntrinsicMatrix;
                  % Transform into image point:
                  impoint = campoint2 * K;
                  % This rescales for Z
                  impoint = impoint / impoint(3);
                 shapeInserter = vision.ShapeInserter('Shape','Circles','BorderColor','Custom',...
                'CustomBorderColor',[0 255 0]);
                 circle = int32([impoint(1) impoint(2) 10; 0 0 0]);
                 data = step(shapeInserter, data, circle); 
                  % BTW camera position C in world frame is:
                  % C = -R'*t
                 toc
                  %%TODO: SOMEBODY EXPLAIN THE BELOW CODE PLIS.
            %      auroravec=camorientation2*eye(3,3);
            %       auroravec=auroravec*K;
            %       auroraimpts(:,1)=auroravec(:,1)/auroravec(3,1);
            %       auroraimpts(:,2)=auroravec(:,2)/auroravec(3,2);
            %       auroraimpts(:,3)=auroravec(:,3)/auroravec(3,3);
            %      shapeInserter = vision.ShapeInserter('Shape','Lines','BorderColor','Custom',...
            %     'CustomBorderColor',[255 0 0],'LineWidth',1);
            % % shapeInserter=vision.ShapeInserter('Shape','Lines')
            %      lxsize = pdist([impoint(1) impoint(2); impoint(1)+auroraimpts(1,1) impoint(2)+auroraimpts(2,1)]);
            %      lineScaleFactor = 1/lxsize * 50;
            %      linex = int32([impoint(1) impoint(2) impoint(1)+lineScaleFactor*auroraimpts(1,1) impoint(2)+lineScaleFactor*auroraimpts(2,1)]);
            %      data = step(shapeInserter, data, linex); 
            %      
            %      shapeInserter = vision.ShapeInserter('Shape','Lines','BorderColor','Custom',...
            %     'CustomBorderColor',[0 255 0],'LineWidth',1);
            %      
            %      lysize = pdist([impoint(1) impoint(2); impoint(1)+auroraimpts(1,2) impoint(2)+auroraimpts(2,2)]);
            %      lineScaleFactor = 1/lysize * 50;
            %      liney = int32([impoint(1) impoint(2) impoint(1)+lineScaleFactor*auroraimpts(1,2) impoint(2)+lineScaleFactor*auroraimpts(2,2)]);     
            %      data = step(shapeInserter, data, liney); 
            %      
            %      shapeInserter = vision.ShapeInserter('Shape','Lines','BorderColor','Custom',...
            %     'CustomBorderColor',[0 0 255],'LineWidth',1);
            %      
            %      lzsize = pdist([impoint(1) impoint(2); impoint(1)+auroraimpts(1,3) impoint(2)+auroraimpts(2,3)]);
            %      lineScaleFactor = 1/lzsize * 50;
            %      linez = int32([impoint(1) impoint(2) impoint(1)+10*auroraimpts(1,3) impoint(2)+10*auroraimpts(2,3)]);
            %      data = step(shapeInserter, data, linez); 

                end

    mov(k).cdata = data;
    k = k + 1;
    imshow(data);
    
end %hasFrame

%% Variables Definition
%load('MUpad') %load the variables generated in mupad

%Hand Dimentions
tr = 0;%mm
a = 80*pi/180;

%% Observer
squareSize = 5.4; %size of the scheckerboard squares in mm

%% Data
%% DO. BETTER. WITH. VARIABLE. NAMES. please.
dt = 1/obj.FrameRate;%0.01;
T = dt*(k-1);
t = dt : dt : T;

X = [t' x];

%X1 = [t' x1];
X1 = X;
Xf0 = [x(1,1) zeros(1,2) x(1,2) zeros(1,2) x(1,3) zeros(1,2) x(1,4) ...
    zeros(1,2) x(1,5) zeros(1,2) x(1,6) zeros(1,2)];

M0 = [t', m0(:,3:5)];%tool reference (local)
M1 = [t', m1(:,3:5)];
% M2 = [t', m2(:,3:5)];%tool reference (local)
% M3 = [t', m3(:,3:5)];
M2 = M0;
M3 = M1;

Y = [t', m0(:,1:2), m1(:,1:2)];%measure (camer frame)
% Y1 = [t', m2(:,1:2), m3(:,1:2)];%measure (camer frame)
Y1 = Y;

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


%% TODO: ALL THESE PLOTS NEED TO DISAPPEAR INTO A DIFFERENT FILE.

%% Data Analysis
%First Tool(red-yellow)
yAbsErr = abs(Y(:,2:end) - hatY.data(2:end,:));

figure(1) %Measure Absolute Error Plot
title('Error on Mesures Tool 1')
subplot(2,2,1)
plot(t, yAbsErr(:,1))
xlabel('time [s]')
ylabel('$$|p_{1_x} - \hat{p}_{1_x}|$$ [pixels]' ,'Interpreter','Latex')
grid on
subplot(2,2,2)
plot(t, yAbsErr(:,2))
xlabel('time [s]')
ylabel('$$|p_{1_y} - \hat{p}_{1_y}|$$ [pixels]' ,'Interpreter','Latex')%ylim([0,1e3])
grid on
subplot(2,2,3)
plot(t, yAbsErr(:,3))
xlabel('time [s]')
ylabel('$$|p_{2_x} - \hat{p}_{2_x}|$$ [pixels]' ,'Interpreter','Latex')
grid on
subplot(2,2,4)
plot(t, yAbsErr(:,4))
xlabel('time [s]')
ylabel('$$|p_{2_y} - \hat{p}_{2_y}|$$ [pixels]' ,'Interpreter','Latex')
grid on

figure(2) %State Plot
title('Observer State Tool 1')
subplot(2,1,1)
plot(t, hatX.data(2:end,1))
xlabel('time [s]')
ylabel('$$\hat{\alpha}$$ [rad]' ,'Interpreter','Latex')
grid on
subplot(2,1,2)
plot(t, hatX.data(2:end,3))
xlabel('time [s]')
ylabel('$$\hat{d}$$ [mm]' ,'Interpreter','Latex')
grid on

%Second Tool(blue-green)
yAbsErr = abs(Y1(:,2:end) - hatY1.data(2:end,:));

figure(3) %Measure Absolute Error Plot
title('Error on Mesures Tool 1')
subplot(2,2,1)
plot(t, yAbsErr(:,1))
xlabel('time [s]')
ylabel('$$|p_{1_x} - \hat{p}_{1_x}|$$ [pixels]' ,'Interpreter','Latex')
grid on
subplot(2,2,2)
plot(t, yAbsErr(:,2))
xlabel('time [s]')
ylabel('$$|p_{1_y} - \hat{p}_{1_y}|$$ [pixels]' ,'Interpreter','Latex')%ylim([0,1e3])
grid on
subplot(2,2,3)
plot(t, yAbsErr(:,3))
xlabel('time [s]')
ylabel('$$|p_{2_x} - \hat{p}_{2_x}|$$ [pixels]' ,'Interpreter','Latex')
grid on
subplot(2,2,4)
plot(t, yAbsErr(:,4))
xlabel('time [s]')
ylabel('$$|p_{2_y} - \hat{p}_{2_y}|$$ [pixels]' ,'Interpreter','Latex')
grid on

figure(4) %State Plot
title('Observer State Tool 1')
subplot(2,1,1)
plot(t, hatX.data(2:end,1))
xlabel('time [s]')
ylabel('$$\hat{\alpha}$$ [rad]' ,'Interpreter','Latex')
grid on
subplot(2,1,2)
plot(t, hatX.data(2:end,3))
xlabel('time [s]')
ylabel('$$\hat{d}$$ [mm]' ,'Interpreter','Latex')
grid on



%% Results
%% First Tool(red-yellow)
l = [30; 20; 0];

worldPoints = zeros(4,length(t));
imagePoints = zeros(3,length(t));

worldTips = zeros(3,length(t));
%Position and Orientation of the Tool
for i = 1:length(t)%position
    [worldPoints(:,i), imagePoints(:,i)] = proj(a,l,-hatX.data(i,:),Xf.data(i,:),cam);
    [frameVect(:,:,i)] = frame_proj(a,l,-hatX.data(i,:),Xf.data(i,:),cam);
end
worldAngles = Xf.data(2:end,1:3) + [zeros(length(t),2), hatX.data(2:end,1) + a];

figure(5)
subplot(3,2,1)
plot(t(1:length(campoint11)), [worldPoints(1,1:length(campoint11)); campoint11(:,1)'])
grid on
xlabel('time [s]')
ylabel('$$P_x$$ [mm]' ,'Interpreter','Latex')
legend('Observed','Measured')
subplot(3,2,2)
plot(t(1:length(campoint11)), [worldPoints(2,1:length(campoint11)); campoint11(:,2)'])
grid on
xlabel('time [s]')
ylabel('$$P_y$$ [mm]' ,'Interpreter','Latex')
subplot(3,2,3)
plot(t(1:length(campoint11)), [worldPoints(3,1:length(campoint11)); campoint11(:,3)'])
grid on
xlabel('time [s]')
ylabel('$$P_z$$ [mm]' ,'Interpreter','Latex')
subplot(3,2,4)
plot(t(1:length(campoint11)), [worldAngles(1:length(campoint11),1)'; camorientation11(:,1)'])
grid on
xlabel('time [s]')
ylabel('$$\theta$$ (z rot) [rad]' ,'Interpreter','Latex')
subplot(3,2,5)
plot(t(1:length(campoint11)), [worldAngles(1:length(campoint11),2)'; camorientation11(:,2)'])
grid on
xlabel('time [s]')
ylabel('$$\phi (y rot)$$ [rad]' ,'Interpreter','Latex')
subplot(3,2,6)
plot(t(1:length(campoint11)), [worldAngles(1:length(campoint11),3)';camorientation11(:,3)'])
grid on
xlabel('time [s]')
ylabel('$$\psi (x rot)$$ [rad]' ,'Interpreter','Latex')

%Plot abs error
Err_x=abs(worldPoints(1,1:length(campoint11))- campoint11(:,1)');
Err_y=abs(worldPoints(2,1:length(campoint11))- campoint11(:,2)');
Err_z=abs(worldPoints(3,1:length(campoint11))- campoint11(:,3)');
Err_ax=abs(worldAngles(1:length(campoint11),1)'- camorientation11(:,1)');
Err_ay=abs(worldAngles(1:length(campoint11),2)'- camorientation11(:,2)');
Err_az=abs(worldAngles(1:length(campoint11),3)'- camorientation11(:,3)');
figure(6)
subplot(3,2,1)
plot(t(1:length(campoint11)), Err_x)
grid on
xlabel('time [s]')
ylabel('$$|P_x - \hat{P}_x|$$ [mm]' ,'Interpreter','Latex')
subplot(3,2,2)
plot(t(1:length(campoint11)), Err_y)
grid on
xlabel('time [s]')
ylabel('$$|P_y - \hat{P}_y|$$ [mm]' ,'Interpreter','Latex')
subplot(3,2,3)
plot(t(1:length(campoint11)), Err_z)
grid on
xlabel('time [s]')
ylabel('$$|P_z - \hat{P}_z|$$ [mm]' ,'Interpreter','Latex')
subplot(3,2,4)
plot(t(1:length(campoint11)), Err_ax)
grid on
xlabel('time [s]')
ylabel('$$|\theta - \hat{\theta}|$$(z rot) [rad]' ,'Interpreter','Latex')
subplot(3,2,5)
plot(t(1:length(campoint11)), Err_ay)
grid on
xlabel('time [s]')
ylabel('$$|\phi - \hat{\phi}|$$ (y rot) [rad]' ,'Interpreter','Latex')
subplot(3,2,6)
plot(t(1:length(campoint11)), Err_az)
grid on
xlabel('time [s]')
ylabel('$$|\psi - \hat{\psi}|$$ (x rot) [rad]' ,'Interpreter','Latex')

%% Second Tool(blue-green)
l1 = [100; -110; 0];

worldPoints1 = zeros(4,length(t));
imagePoints1 = zeros(3,length(t));

%Position and Orientation of the Tool
for i = 1:length(t)%position
    [worldPoints1(:,i), imagePoints1(:,i)] = proj(a,l1,-hatX1.data(i,:),Xf1.data(i,:),cam);
    [frameVect1(:,:,i)] = frame_proj(a,l1,-hatX1.data(i,:),Xf1.data(i,:),cam);
end
worldAngles1 = Xf1.data(2:end,1:3) + [zeros(length(t),2), hatX1.data(2:end,1) + a];
worldAngles1(:,1) = -worldAngles1(:,1);

figure(7)
subplot(3,2,1)
plot(t(1:length(campoint11)), [worldPoints1(1,1:length(campoint11)); campoint12(:,1)'])
grid on
xlabel('time [s]')
ylabel('$$P_x$$ [mm]' ,'Interpreter','Latex')
legend('Observed','Measured')
subplot(3,2,2)
plot(t(1:length(campoint11)), [worldPoints1(2,1:length(campoint11)); campoint12(:,2)'])
grid on
xlabel('time [s]')
ylabel('$$P_y$$ [mm]' ,'Interpreter','Latex')
subplot(3,2,3)
plot(t(1:length(campoint11)), [worldPoints1(3,1:length(campoint11)); campoint12(:,3)'])
grid on
xlabel('time [s]')
ylabel('$$P_z$$ [mm]' ,'Interpreter','Latex')
subplot(3,2,4)
plot(t(1:length(campoint11)), [worldAngles1(1:length(campoint11),1)'; camorientation12(:,1)'])
grid on
xlabel('time [s]')
ylabel('$$\theta$$ (z rot) [rad]' ,'Interpreter','Latex')
subplot(3,2,5)
plot(t(1:length(campoint11)), [worldAngles1(1:length(campoint11),2)'; camorientation12(:,2)'])
grid on
xlabel('time [s]')
ylabel('$$\phi (y rot)$$ [rad]' ,'Interpreter','Latex')
subplot(3,2,6)
plot(t(1:length(campoint11)), [worldAngles1(1:length(campoint11),3)';camorientation12(:,3)'])
grid on
xlabel('time [s]')
ylabel('$$\psi (x rot)$$ [rad]' ,'Interpreter','Latex')

%Plot abs error
Err_x=abs(worldPoints1(1,1:length(campoint11))- campoint12(:,1)');
Err_y=abs(worldPoints1(2,1:length(campoint11))- campoint12(:,2)');
Err_z=abs(worldPoints1(3,1:length(campoint11))- campoint12(:,3)');
Err_ax=abs(worldAngles1(1:length(campoint11),1)'- camorientation12(:,1)');
Err_ay=abs(worldAngles1(1:length(campoint11),2)'- camorientation12(:,2)');
Err_az=abs(worldAngles1(1:length(campoint11),3)'- camorientation12(:,3)');
figure(8)
subplot(3,2,1)
plot(t(1:length(campoint11)), Err_x)
grid on
xlabel('time [s]')
ylabel('$$|P_x - \hat{P}_x|$$ [mm]' ,'Interpreter','Latex')
subplot(3,2,2)
plot(t(1:length(campoint11)), Err_y)
grid on
xlabel('time [s]')
ylabel('$$|P_y - \hat{P}_y|$$ [mm]' ,'Interpreter','Latex')
subplot(3,2,3)
plot(t(1:length(campoint11)), Err_z)
grid on
xlabel('time [s]')
ylabel('$$|P_z - \hat{P}_z|$$ [mm]' ,'Interpreter','Latex')
subplot(3,2,4)
plot(t(1:length(campoint11)), Err_ax)
grid on
xlabel('time [s]')
ylabel('$$|\theta - \hat{\theta}|$$ [mm]' ,'Interpreter','Latex')
subplot(3,2,5)
plot(t(1:length(campoint11)), Err_ay)
grid on
xlabel('time [s]')
ylabel('$$|\phi - \hat{\phi}|$$ [mm]' ,'Interpreter','Latex')
subplot(3,2,6)
plot(t(1:length(campoint11)), Err_az)
grid on
xlabel('time [s]')
ylabel('$$|\psi - \hat{\psi}|$$ [mm]' ,'Interpreter','Latex')



%% Plot Frame on Video

% Plot first tool position
circleColour1 = [255 255 0];
shapeInserter1 = vision.ShapeInserter('Shape','Circles','BorderColor','Custom',...
                  'CustomBorderColor',circleColour1);

squareColour2 = [0 0 255];
shapeInserter2 = vision.ShapeInserter('Shape','Circles','BorderColor','Custom',...
                  'CustomBorderColor',squareColour2);

% Plot second tool position in image
figure(11)
for j = 1:length(mov)
    circle1 = int32([imagePoints(1,j) imagePoints(2,j) 10; 0 0 0]);
    square2 = int32([imagePoints1(1,j) imagePoints1(2,j) 10; 0 0 0]);
    mov(j).cdata = step(shapeInserter1, mov(j).cdata, circle1);
    mov(j).cdata = step(shapeInserter2, mov(j).cdata, square2);

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

%Output the results to video:
v1 = VideoWriter('C:\GroupProject\resultVideos\IMG_6159_Res');
open(v1)
writeVideo(v1,mov)
close(v1)
% %end %main