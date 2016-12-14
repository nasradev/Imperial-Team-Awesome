%main code
%TODO: Move all drawing etc. to Nas branch
function main()

%%Definitions

%Size of checkerboard squares
squareSize = 5.4;

%Load up the camera parameters:
%load('iphoneCam1080.mat') 
%cameraParams = cameraParams1080;
load('iphoneCam.mat');

%M = tdfread('take1_003.csv',',');
M = tdfread('C:\Group Project\Videos\Take 3\take1_004.csv', ',');

%Set the video file and define output video object
obj = VideoReader('C:\Group Project\Videos\Take 3\IMG_6157.MOV');
%obj = VideoReader('C:\Group Project\Videos\Take 2\IMG_5950.MOV');
vidWidth = obj.Width;
vidHeight = obj.Height;
mov = struct('cdata',zeros(vidHeight,vidWidth,3,'uint8'), 'colormap',[]);


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

% Contrived:
auroraStartOffset = 0;

imagePointsPadding = 40;

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
     firstBoard.threePoints(:,1) = board.threePoints(:,1)...
                                        + xrange(1);
     firstBoard.threePoints(:,2) = board.threePoints(:,2)...
                                        + yrange(1);
    else
      firstBoard.imagePoints = board.imagePoints;
    end
    else
      firstBoard = getBoardObject(data, squareSize);
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
     toc
     tic
     
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
      secondBoard.threePoints(:,1) = board.threePoints(:,1)...
                                       + xrange(1);
      secondBoard.threePoints(:,2) = board.threePoints(:,2)...
                                       + yrange(1);
     else
      secondBoard.imagePoints = [];
      secondBoard.imagePoints = [-1 -1];
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
     toc
     display('3rd board')
     tic
      % Draw mask on the second cboard and find the next one
      %THIRD BOARD
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
        thirdBoard.threePoints(:,1) = board.threePoints(:,1)...
                                         + xrange(1);
        thirdBoard.threePoints(:,2) = board.threePoints(:,2)...
                                         + yrange(1);
       else
        thirdBoard.imagePoints = board.imagePoints;
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
    x = floor(1.4 *  (timeOffset + k)) + auroraStartOffset;
    toc
    
    
    
    if isempty(P) == 0 && x <= length( M.Ty1 )

      record = [M.Tx1(x), M.Ty1(x), M.Tz1(x), M.Q01(x), M.Qx1(x), ...
                    M.Qy1(x), M.Qz1(x)];
      tic
      % Get the position of the tool sensor in Aurora frame
      [campoint1, camrotation] = getAuroraTranslation(record, R, t);

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
      % BTW camera position C in world frame is:
      % C = -R'*t
     toc
     
    end
    
    if isfield(M, 'Ty2') && isempty(P) == 0 && x <= length( M.Ty2 )

      record = [M.Tx2(x), M.Ty2(x), M.Tz2(x), M.Q02(x), M.Qx2(x), ...
                    M.Qy2(x), M.Qz2(x)];
      tic
      % Get the position of the tool sensor in Aurora frame
      [campoint, camrotation] = getAuroraTranslation(record, R, t);
      %[focal length in mm]*[resolution]/[sensor size in mm]
      K = cameraParams.IntrinsicMatrix;
      % Transform into image point:
      impoint = campoint * K;
      % This rescales for Z
      impoint = impoint / impoint(3);
     shapeInserter = vision.ShapeInserter('Shape','Circles','BorderColor','Custom',...
    'CustomBorderColor',[0 255 0]);
     circle = int32([impoint(2) impoint(1) 10; 0 0 0]);
     data = step(shapeInserter, data, circle); 
      % BTW camera position C in world frame is:
      % C = -R'*t
     toc
     
    end
    
    k
    
        
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
                % reset the counter to 0 because a marker was detected
                staticRedCounter = 0;
        else
                display('No red marker detected');
        end
        
        % Yellow Marker
        tinyYellow = temp_data;
        [yellow, yellowArea] = getYellowPos(tinyYellow);
        if( yellow(1) ~=  0 || yellow(2) ~= 0)
                % reset the counter to 0 because a marker was detected
                staticRedCounter = 0;
        else
                display('No yellow marker detected');
        end
        
               
        % Blue marker
        tinyBlue = temp_data;
        [blue, blueArea] = getBluePos(tinyBlue);
        if( blue(1) ~=  0 || blue(2) ~= 0)
                % reset the counter to 0 because a marker was detected
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
              % reset the counter to 0 because a marker was detected
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
              % reset the counter to 0 because a marker was detected
              staticRedCounter = 0;
          else
              red = lastRed;
              staticRedCounter = staticRedCounter + 1;
          end
      end
     %Plot the red marker
     shapeInserter = vision.ShapeInserter('Shape','Circles','BorderColor','Custom',...
        'CustomBorderColor',[255 20 0]);
     circle = int32([ red(1) red(2) 20; 0 0 0]);
     data = step(shapeInserter, data, circle);
    
      
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
              % reset the counter to 0 because a marker was detected
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
              % reset the counter to 0 because a marker was detected
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
                % reset the counter to 0 because a marker was detected
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
                % reset the counter to 0 because a marker was detected
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

%Output the results to video:
v = VideoWriter('C:\Group Project\Videos\60withAurora');
open(v)
writeVideo(v,mov)
close(v)

end %main