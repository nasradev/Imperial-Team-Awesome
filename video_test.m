% Load the video
close all;
clear;
video = VideoReader('video_webcam2.mp4');
video.CurrentTime = 3.00;
while hasFrame(video)
    % Get a single framec
    imagen = readFrame(video);
    makersPos = getMarkersPos2(imagen);
    pause(0.5)
end