%main code
function main()

%%Definitions

%Size of checkerboard squares
squareSize = 5.4;

%Load up the camera parameters:
load('naskosCameraParamsLaptop.mat') %or whatever

%Set the video file and define output video object
obj = VideoReader('C:\Group Project\Videos\Take 2\IMG_5949.MOV');
vidWidth = obj.Width;
vidHeight = obj.Height;
mov = struct('cdata',zeros(vidHeight,vidWidth,3,'uint8'), 'colormap',[]);
k = 1;

% Go through the video frames
while hasFrame(obj);  
    data = readFrame(obj);
    % Get the first checkerboard:
    firstBoard = getBoardObject(data, squareSize);
    
    if firstBoard.imagePoints(1,1) > -1
    
     % Draw mask on the first cboard and find the next one
     temp_data = hideCheckerboard(data,...
         [firstBoard.imagePoints(1,:);firstBoard.imagePoints(end,:)]);
     
     %Plot the points (TODO remove)
     image(data);
     hold on
     scatter(firstBoard.imagePoints(:,1),firstBoard.imagePoints(:,2));
     
     % Find the second board
     secondBoard = getBoardObject(temp_data, squareSize);
     
     if secondBoard.imagePoints(1,1) > -1
      
      scatter(secondBoard.imagePoints(:,1),secondBoard.imagePoints(:,2));
      
      % Draw mask on the second cboard and find the next one
      temp_data = hideCheckerboard(temp_data,...
         [secondBoard.imagePoints(1,:);secondBoard.imagePoints(end,:)]);
      % Find the third board (we expect 2 hands and a base):
      thirdBoard = getBoardObject(temp_data, squareSize);
      if thirdBoard.imagePoints(1,1) > -1
       scatter(thirdBoard.imagePoints(:,1),thirdBoard.imagePoints(:,2));
      end
     end
     hold off;
     % Get the marker positions:
     tic
     [red yellow green blue] = getMarkerPos(data);
     position = [50 50];
     txt = strcat('Red: ', num2str(red(1,1)), ',', num2str(red(1,2)));
     txt = strcat(txt, ' Yellow: ', num2str(yellow(1,1)), ',', num2str(yellow(1,2)));
     data = insertText(data, position, txt, 'FontSize',18,'BoxColor',...
     [0 0 255],'BoxOpacity',0.4,'TextColor','white');
     toc
     % Red and Yellow in tool 1, Green and Blue in tool 2
    else
        display('no checkerboards found')
    end
    mov(k).cdata = data;
    k = k+1;
end %hasFrame

%Output the results to video:
v = VideoWriter('C:\Group Project\Videos\output4');
open(v)
writeVideo(v,mov)
close(v)

end %main