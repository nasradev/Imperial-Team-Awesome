% Load the video
close all;
clear;
video = VideoReader('IMG_5949.MOV');
video.CurrentTime = 1.00;
while hasFrame(video)
    % Get a single framec
    imagen = readFrame(video);
    makersPos = getMarkerPos(imagen);
    pause(0.5)
end