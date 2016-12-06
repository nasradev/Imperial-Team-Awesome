%main code
%TODO: Move all drawing etc. to Nas branch
function main()

%%Definitions

%Size of checkerboard squares
squareSize = 5.4;

%Load up the camera parameters:
load('naskosCameraParamsLaptop.mat') %or whatever

%Set the video file and define output video object
obj = VideoReader('C:\Group Project\Videos\Take 2\IMG_5949-hd.MOV');
vidWidth = obj.Width;
vidHeight = obj.Height;
mov = struct('cdata',zeros(vidHeight,vidWidth,3,'uint8'), 'colormap',[]);
k = 1;

firstBoard.colour = zeros(1,3);
secondBoard.colour = zeros(1,3);
thirdBoard.colour = zeros(1,3);


% Go through the video frames
obj.CurrentTime = 1;
while hasFrame(obj);  
    data = readFrame(obj);
    
     % Get the marker positions:
     tic
     [red yellow green blue] = getMarkerPos(data);
     position = [50 50];
     txt = strcat('Red: ', num2str(red(1,1)), ',', num2str(red(1,2)));
     txt = strcat(txt, ' Yellow: ', num2str(yellow(1,1)), ',', num2str(yellow(1,2)));
     data = insertText(data, position, txt, 'FontSize',18,'BoxColor',...
     [0 0 255],'BoxOpacity',0.4,'TextColor','white');
     toc
     
     
    % Get the first checkerboard:
    firstBoard = getBoardObject(data, squareSize);
    
    if firstBoard.imagePoints(1,1) > -1
    
     % Draw mask on the first cboard and find the next one
     temp_data = hideCheckerboard(data,...
         [firstBoard.imagePoints(1,:);firstBoard.imagePoints(end,:)]);
     
     %Plot the points (TODO remove)
     shapeInserter = vision.ShapeInserter('Shape','Circles','BorderColor','Custom',...
    'CustomBorderColor',firstBoard.colour);
     circle = int32([firstBoard.imagePoints(1,1) firstBoard.imagePoints(1,2) 40; 0 0 0]);
     data = step(shapeInserter, data, circle);
     firstBoard.colour
     
     % Find the second board
     secondBoard = getBoardObject(temp_data, squareSize);
     
     if secondBoard.imagePoints(1,1) > -1
      
       shapeInserter = vision.ShapeInserter('Shape','Circles','BorderColor','Custom',...
    'CustomBorderColor',secondBoard.colour);
     circle = int32([secondBoard.imagePoints(1,1) secondBoard.imagePoints(1,2) 40; 0 0 0]);
     data = step(shapeInserter, data, circle); 
     secondBoard.colour
      % Draw mask on the second cboard and find the next one
      temp_data = hideCheckerboard(temp_data,...
         [secondBoard.imagePoints(1,:);secondBoard.imagePoints(end,:)]);
      % Find the third board (we expect 2 hands and a base):
      thirdBoard = getBoardObject(temp_data, squareSize);
      if thirdBoard.imagePoints(1,1) > -1
        shapeInserter = vision.ShapeInserter('Shape','Circles','BorderColor','Custom',...
    'CustomBorderColor',thirdBoard.colour);
       circle = int32([thirdBoard.imagePoints(1,1) thirdBoard.imagePoints(1,2) 40; 0 0 0]);
       data = step(shapeInserter, data, circle); 

      end
     end
 
     % Red and Yellow in tool 1, Green and Blue in tool 2
    else
        display('no checkerboards found')
    end
    mov(k).cdata = data;
    k = k+1;
end %hasFrame

%Output the results to video:
v = VideoWriter('C:\Group Project\Videos\output8');
open(v)
writeVideo(v,mov)
close(v)

end %main