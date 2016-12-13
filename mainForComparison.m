%main code
%TODO: Move all drawing etc. to Nas branch
function main()

%%Definitions

%Size of checkerboard squares
squareSize = 5.4;

%Load up the camera parameters:
%load('iphoneCam1080.mat') 
%cameraParams = cameraParams1080;
load('iphoneCam.mat')

%M = tdfread('take1_003.csv',',');
M = tdfread('C:\Group Project\Videos\Take 3\take1_000.csv', ',');

%Set the video file and define output video object
obj = VideoReader('C:\Group Project\Videos\Take 3\IMG_6154.MOV');
%obj = VideoReader('C:\Group Project\Videos\Take 2\IMG_5950.MOV');
vidWidth = obj.Width;
vidHeight = obj.Height;
mov = struct('cdata',zeros(vidHeight,vidWidth,3,'uint8'), 'colormap',[]);


firstBoard.colour = zeros(1,3);
secondBoard.colour = zeros(1,3);
thirdBoard.colour = zeros(1,3);

P = [];
% Go through the video frames
obj.CurrentTime = 0;
timeOffset = round(obj.FrameRate) * (round(obj.CurrentTime));
k = 1;

% Contrived:
auroraStartOffset = 0;

imagePointsPadding = 40;
while hasFrame(obj);  
    data = readFrame(obj);
    tic
    % Get the first checkerboard:
    % If we already have the first checkerboard, try to find it again in
    % the nearby area:
    
    if isfield(firstBoard, 'imagePoints') == 1 && firstBoard.imagePoints(1,1) > -1
     xrange = round([min(firstBoard.imagePoints(:,1)) - imagePointsPadding...
                  :max(firstBoard.imagePoints(:,1)) + imagePointsPadding]);
    
     yrange = round([min(firstBoard.imagePoints(:,2)) - imagePointsPadding...
                  :max(firstBoard.imagePoints(:,2)) + imagePointsPadding]);
    
     
     board = getBoardObject(data(max(yrange(1),1):...
                                 min(yrange(end),length(data(:,1,1))),...
                                 max(xrange(1),1):...
                                 min(xrange(end),length(data(1,:,1))),:),...
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
     
    if isfield(secondBoard, 'imagePoints') == 1 && secondBoard.imagePoints(1,1) > -1
     xrange = round([min(secondBoard.imagePoints(:,1)) - imagePointsPadding...
                  :max(secondBoard.imagePoints(:,1)) + imagePointsPadding]);
    
     yrange = round([min(secondBoard.imagePoints(:,2)) - imagePointsPadding...
                  :max(secondBoard.imagePoints(:,2)) + imagePointsPadding]);
    
     
     board = getBoardObject(data(max(yrange(1),1):...
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
      secondBoard.imagePoints = board.imagePoints;
     end
    else
      secondBoard = getBoardObject(temp_data, squareSize);
    end
     
     
     
     
     if secondBoard.imagePoints(1,1) > -1
      
       shapeInserter = vision.ShapeInserter('Shape','Circles','BorderColor','Custom',...
    'CustomBorderColor',secondBoard.colour);
     circle = int32([secondBoard.imagePoints(1,1) secondBoard.imagePoints(1,2) 40; 0 0 0]);
     data = step(shapeInserter, data, circle); 
     
      % Draw mask on the second cboard and find the next one
      temp_data = hideCheckerboard(temp_data,...
         [secondBoard.imagePoints(1,:);secondBoard.imagePoints(end,:)]);
%       % Find the third board (we expect 2 hands and a base):
%       thirdBoard = getBoardObject(temp_data, squareSize);
%       if thirdBoard.imagePoints(1,1) > -1
%         shapeInserter = vision.ShapeInserter('Shape','Circles','BorderColor','Custom',...
%     'CustomBorderColor',thirdBoard.colour);
%        circle = int32([thirdBoard.imagePoints(1,1) thirdBoard.imagePoints(1,2) 40; 0 0 0]);
%        data = step(shapeInserter, data, circle); 
%       end
      
     end
 
    % Get the R and t of the World with respect to the black checkerboard: 
    if (isempty(P)) &&  isequal(firstBoard.colour, [0 0 0])
           [R,t] = extrinsics(firstBoard.imagePoints, ...
                    firstBoard.worldPoints, cameraParams);
      P = cameraParams.IntrinsicMatrix * [R t'];
    elseif isempty(P) &&  isequal(secondBoard.colour, [0 0 0])
      [R,t] = extrinsics(secondBoard.imagePoints, ...
                    secondBoard.worldPoints, cameraParams);
      P = cameraParams.IntrinsicMatrix * [R t'];
%     elseif isempty(P) &&  isequal(thirdBoard.colour, [0 0 0])
%       [R,t] = extrinsics(thirdBoard.imagePoints, ...
%                     thirdBoard.worldPoints, cameraParams);
%       P = cameraParams.IntrinsicMatrix * [R t'];
    end
    x = floor(1.4 *  (timeOffset + k)) + auroraStartOffset;
    toc
    
    tic
    
    %%%%% GET MARKER POS:
         % Red and Yellow in tool 1, Green and Blue in tool 2
     [red yellow green blue] = getMarkerPos(data);
     position = [50 50];
     txt = strcat('Red: ', num2str(red(1,1)), ', ', num2str(red(1,2)));
     txt = strcat(txt, ';  Yellow: ', num2str(yellow(1,1)), ...
                ', ', num2str(yellow(1,2)), ...
                ',  aurora frame number: ', num2str(x), ...
                ' at time ', num2str(obj.CurrentTime));
     data = insertText(data, position, txt, 'FontSize',18,'BoxColor',...
     [0 0 255],'BoxOpacity',0.4,'TextColor','white');
    toc
    
    
    
    if isempty(P) == 0 && x <= length( M.Ty1 )

      record = [M.Tx1(x), M.Ty1(x), M.Tz1(x), M.Q01(x), M.Qx1(x), ...
                    M.Qy1(x), M.Qz1(x)];
    tic
      % Get the position of the tool sensor in Aurora frame
      T = getAuroraTranslation(record);
      aurorapoint = T(1:3,4);
      Rx = [-1 0 0; 0 1 0;0 0 -1];
      %Rz = [0 1 0; -1 0 0; 0 0 1];
      % This is the rotation matrix for Aurora to Cboard
%       Raugcb = Rx * Rz;
      Raugcb = Rx;
      % Sample Taugcb translation:
      taugcb = [0 0 0];
      % Transform the Aurora point to Cboard frame
      cbpoint = aurorapoint' * Raugcb' + taugcb;
      % Transform to camera frame now:
      %TODO: Pass this to Gigi
      campoint = cbpoint * R + t;

  %     Pa = [R;t];

      %[focal length in mm]*[resolution]/[sensor size in mm]
      K = cameraParams.IntrinsicMatrix;
      % Transform into image point:
      impoint = campoint * K;
      % This rescales for Z
      impoint = impoint / impoint(3);
     shapeInserter = vision.ShapeInserter('Shape','Circles','BorderColor','Custom',...
    'CustomBorderColor',[255 0 0]);
     circle = int32([impoint(1) impoint(2) 10; 0 0 0]);
     data = step(shapeInserter, data, circle); 
      % BTW camera position C in world frame is:
      % C = -R'*t
     toc
     k
    end

    else
        display('no checkerboards found')
    end
    mov(k).cdata = data;
    k = k+1;
    

end %hasFrame

%Output the results to video:
v = VideoWriter('C:\Group Project\Videos\54withAurora');
open(v)
writeVideo(v,mov)
close(v)

end %main