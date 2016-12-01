%main code
function main()

%%Definitions

%Size of checkerboard squares
squareSize = 5.4;

%Load up the camera parameters:
load('naskosCameraParamsLaptop.mat') %or whatever

%Set the video file and define output video object
obj = VideoReader('C:\Users\anr16\SharePoint\Gonzalez Bueno, Juana\Group project\Aurora videos\6.MOV');
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
    
     % Find the second board
     secondBoard = getBoardObject(temp_data, squareSize);
     
    % Draw mask on the second cboard and find the next one
     temp_data = hideCheckerboard(data,...
         [secondBoard.imagePoints(1,:);secondBoard.imagePoints(end,:)]);
     
     % Find the third board (we expect 2 hands and a base):
     thirdBoard = getBoardObject(temp_data, squareSize);
    
     % Get the marker positions:
     %markersPos = getMarkersPos(data);
     % Red and Yellow in tool 1, Green and Blue in tool 2
    else
        display('no checkerboards found')
    end
    
end %hasFrame

%Output the results to video:
v = VideoWriter('C:\Group Project\Videos\output2');
open(v)
writeVideo(v,mov)
close(v)

end %main