% Load the video
close all;
clear;
video = VideoReader('IMG_5947.MOV');
% video.CurrentTime = 2.00;
while hasFrame(video)
    % Get a single framec
    imagen = readFrame(video);
    [red yellow bla blah] = getMarkerPos(imagen);

end