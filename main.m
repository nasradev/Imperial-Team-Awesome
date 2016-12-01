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
    % Get the checkerboards:
    [imagePoints, worldPoints, colour, threePoints] = ...
        FindCheckerboardPattern( data, squareSize );
    
    % Get the marker positions:
    [redM, yellowM, greenM, blueM] = getMarkerPos(obj);
    % Red and Yellow in tool 1, Green and Blue in tool 2
    
end %hasFrame

%Output the results to video:
v = VideoWriter('C:\Group Project\Videos\output2');
open(v)
writeVideo(v,mov)
close(v)

end %main