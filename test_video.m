% Load the video
close all;
clear;
video = VideoReader('1.MOV');
%video = VideoReader('new_markers.mp4');
 video.CurrentTime = 1.00;
while hasFrame(video)
    % Get a single framec
    imagen = readFrame(video);
    [m1, m2, m3, m4] = getMarkerPos(imagen);
    % pause(0.5)
end
