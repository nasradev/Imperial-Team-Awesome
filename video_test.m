% Load the video
close all;
clear;
video = VideoReader('IMG_6152.MOV');
% video.CurrentTime = 2.00;
while hasFrame(video)
    % Get a single framec
    imagen = readFrame(video);
    [red yellow bla blah] = getMarkerPos(imagen);
pause(0.5)
end