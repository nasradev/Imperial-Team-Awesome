% Load the video
close all;
clear;
video = VideoReader('video_webcam1.mp4');
% video.CurrentTime = 2.00;
while hasFrame(video)
    % Get a single framec
    imagen = readFrame(video);
    [red yellow bla blah] = getMarkerPos(imagen);

end