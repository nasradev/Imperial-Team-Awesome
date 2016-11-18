% Load the video
close all;
clear;
video = VideoReader('video_webcam6.mp4');
 video.CurrentTime = 1.00;
while hasFrame(video)
    % Get a single framec
    imagen = readFrame(video);
    makersPos = getMarkersPos(imagen);
    pause(0.5)
end