% Load the video
close all;
clear;
video = VideoReader('video_webcam4.mp4');
video.CurrentTime = 3.00;
while hasFrame(video)
    % Get a single frame
    imagen = readFrame(video);
    makersPos = getMarkersPos2(imagen);
    pause(0.5)
end