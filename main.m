%main code
%function main()
clear
clc
close all 
%%Definitions

%Size of checkerboard squares
squareSize = 5.4;

%Load up the camera parameters:
load('naskosCameraParamsLaptop.mat') %or whatever

%Set the video file and define output video object
obj = VideoReader('IMG_5947.MOV');
vidWidth = obj.Width;
vidHeight = obj.Height;
mov = struct('cdata',zeros(vidHeight,vidWidth,3,'uint8'), 'colormap',[]);

%Define Data
firstBoard.colour = zeros(1,3);
secondBoard.colour = zeros(1,3);
thirdBoard.colour = zeros(1,3);

counter = 0;
% Go through the video frames
while hasFrame(obj);  
    counter = counter + 1;
    data = readFrame(obj);
    % Get the first checkerboard:
    firstBoard = getBoardObject(data, squareSize);
    
    
    % Get the marker positions:
    tic
    [red, yellow, green, blue] = getMarkerPos(data);
    m0(counter,:) = red;
    m1(counter,:) = yellow;
    if mean(red(1:2)) == 0 && counter > 1
        m0(counter,:) = m0(counter-1,:);
    end
    if mean(yellow(1:2)) == 0 && counter > 1
        m1(counter,:) = m1(counter-1,:);
    end
    toc
    
    if firstBoard.imagePoints(1,1) > -1
    
     % Draw mask on the first cboard and find the next one
     temp_data = hideCheckerboard(data,...
         [firstBoard.imagePoints(1,:);firstBoard.imagePoints(end,:)]);
     
     %Plot the points (TODO remove)
     image(data);
     hold on
     scatter(firstBoard.imagePoints(:,1),firstBoard.imagePoints(:,2));
     
     % Find the second board
     secondBoard = getBoardObject(temp_data, squareSize);
     
     if secondBoard.imagePoints(1,1) > -1
      
      scatter(secondBoard.imagePoints(:,1),secondBoard.imagePoints(:,2));
      
      % Draw mask on the second cboard and find the next one
      temp_data = hideCheckerboard(temp_data,...
         [secondBoard.imagePoints(1,:);secondBoard.imagePoints(end,:)]);
      % Find the third board (we expect 2 hands and a base):
      thirdBoard = getBoardObject(temp_data, squareSize);
      if thirdBoard.imagePoints(1,1) > -1
       scatter(thirdBoard.imagePoints(:,1),thirdBoard.imagePoints(:,2));
      end
     end
     %hold off;
%      
%      if counter > 1 %next steps
%         p0(counter,:) = p0(counter-1,:);
%         p1(counter,:) = p1(counter-1,:);
%         p2(counter,:) = p2(counter-1,:);
%      end
     % Red and Yellow in tool 1, Green and Blue in tool 2
    else
        display('no checkerboards found')
    end
    
    p0(counter,:) = zeros(5,1);%first step
    p1(counter,:) = zeros(5,1);
    p2(counter,:) = zeros(5,1);
    
    if firstBoard.colour(3) == 255
        p0(counter,:) = firstBoard.threePoints(1,:);
        p1(counter,:) = firstBoard.threePoints(2,:);
        p2(counter,:) = firstBoard.threePoints(3,:);
    elseif secondBoard.colour(3) == 255
        p0(counter,:) = firstBoard.threePoints(1,:);
        p1(counter,:) = firstBoard.threePoints(2,:);
        p2(counter,:) = firstBoard.threePoints(3,:);
    elseif thirdBoard.colour(3) == 255
        p0(counter,:) = firstBoard.threePoints(1,:);
        p1(counter,:) = firstBoard.threePoints(2,:);
        p2(counter,:) = firstBoard.threePoints(3,:);
    end
end %hasFrame

%Output the results to video:
%v = VideoWriter('C:\Group Project\Videos\output2');
%open(v)
%writeVideo(v,mov)
%close(v)

%% Variables Definition
%load('MUpad') %load the variables generated in mupad

%Hand Dimentions
tr = 100;%mm
a = 15/180*pi;


%% Video
% vid = VideoReader('video_13s.mp4');
% vidWidth = vid.Width;
% vidHeight = vid.Height;
%based on calibration parameters for Focal Length and Principal Points
k = [0.70775, 0, 3.2946, 0; 0, 0.7041571, 2.273255, 0; 0, 0, 1, 0;...
    0, 0, 0, 0];
% mov = struct('cdata',zeros(vidHeight,vidWidth,3,'uint8'),...
%     'colormap',[]);
% 
% yellow = uint8([255 255 0]);

%load('giovsCameraParamsLaptop')

squareSize = 5.4; %size of the scheckerboard squares in mm

% [time, p0, p1, p2] = TrackTwoCheckerboardsLive( cameraParams, squareSize );



%% Data

dt = 0.01;%mean(time);
T = dt*counter;
t = dt : dt : T;

P0 = [t', p0(:,3:5)];%checkerboard reference (local)
P1 = [t', p1(:,3:5)];
P2 = [t', p2(:,3:5)];

Y = [t', p0(:,1:2), p1(:,1:2),p2(:,1:2)];%measure (camera frame)


M0 = [t', m0(:,3:5)];%tool reference (local)
M1 = [t', m1(:,3:5)];

Y1 = [t', m0(:,1:2), m1(:,1:2)];%measure (camer frame)

%% Checkerboard 1 State Evolution
%F = double(F); %state evolution
F = [zeros(6,6), eye(6), zeros(6,6), zeros(6,6);
    zeros(6,12), eye(6), zeros(6,6);
    zeros(6,18), eye(6);
    zeros(6,24)];

B = [zeros(18,6); eye(6)]; %observer linear input

C = [eye(6), zeros(6,18)];


%% Marker 1 State Evolution
F1 = [zeros(4,4), eye(4);
    zeros(4,8)];

B1 = [zeros(4,4); eye(4)]; %observer linear input

C1 = [eye(4), zeros(4,4)];



%% Gain
load('K')
%Ksys = ss(K);
[Ak, Bk, Ck, Dk] = ssdata(K1);
[Ak_1, Bk_1, Ck_1, Dk_1] = ssdata(K2);%ssdata(K_1);


%% Simulation
sim('trackingSim')

%% Data Analysis
figure(1) %Measure Plot
subplot(3,2,1)
plot(t, Y(:,2), t, hatY.data(2:end,1), '--')
%ylim([0,1e3])
subplot(3,2,2)
plot(t, Y(:,3), t, hatY.data(2:end,2), '--')
%ylim([0,1e3])
subplot(3,2,3)
plot(t, Y(:,4), t, hatY.data(2:end,3), '--')
%ylim([0,1e3])
subplot(3,2,4)
plot(t, Y(:,5), t, hatY.data(2:end,4), '--')
%ylim([0,1e3])
subplot(3,2,5)
plot(t, Y(:,6), t, hatY.data(2:end,5), '--')
%ylim([0,1e3])
subplot(3,2,6)
plot(t, Y(:,7), t, hatY.data(2:end,6), '--')
%ylim([0,1e3])


yAbsErr = abs(Y(:,2:end) - hatY.data(2:end,:));

figure(2) %Measure Absolute Error Plot
subplot(3,2,1)
plot(t, yAbsErr(:,1))
%ylim([0,1e3])
subplot(3,2,2)
plot(t, yAbsErr(:,2))
%ylim([0,1e3])
subplot(3,2,3)
plot(t, yAbsErr(:,3))
%ylim([0,1e3])
subplot(3,2,4)
plot(t, yAbsErr(:,4))
%ylim([0,1e3])
subplot(3,2,5)
plot(t, yAbsErr(:,5))
%ylim([0,1e3])
subplot(3,2,6)
plot(t, yAbsErr(:,6))
%ylim([0,1e3])

figure(3) %State Plot
subplot(3,2,1)
plot(t, hatX.data(2:end,1))
%ylim([0,1e3])
subplot(3,2,2)
plot(t, hatX.data(2:end,2))
%ylim([0,1e3])
subplot(3,2,3)
plot(t, hatX.data(2:end,3))
%ylim([0,1e3])
subplot(3,2,4)
plot(t, hatX.data(2:end,4))
%ylim([0,1e3])
subplot(3,2,5)
plot(t, hatX.data(2:end,5))
%ylim([0,1e3])
subplot(3,2,6)
plot(t, hatX.data(2:end,6))
%ylim([0,1e3])

figure(4) %Measure Plot
subplot(2,2,1)
plot(t, Y1(:,2), t, hatY1.data(2:end,1), '--')
%ylim([0,1e3])
subplot(2,2,2)
plot(t, Y1(:,3), t, hatY1.data(2:end,2), '--')
%ylim([0,1e3])
subplot(2,2,3)
plot(t, Y1(:,4), t, hatY1.data(2:end,3), '--')
%ylim([0,1e3])
subplot(2,2,4)
plot(t, Y1(:,5), t, hatY1.data(2:end,4), '--')
%ylim([0,1e3])


yAbsErr = abs(Y1(:,2:end) - hatY1.data(2:end,:));

figure(5) %Measure Absolute Error Plot
subplot(2,2,1)
plot(t, yAbsErr(:,1))
%ylim([0,1e3])
subplot(2,2,2)
plot(t, yAbsErr(:,2))
%ylim([0,1e3])
subplot(2,2,3)
plot(t, yAbsErr(:,3))
%ylim([0,1e3])
subplot(2,2,4)
plot(t, yAbsErr(:,4))
%ylim([0,1e3])

figure(6) %State Plot
subplot(2,2,1)
plot(t, hatX1.data(2:end,1))
%ylim([0,1e3])
subplot(2,2,2)
plot(t, hatX1.data(2:end,2))
%ylim([0,1e3])
subplot(2,2,3)
plot(t, hatX1.data(2:end,3))
%ylim([0,1e3])
subplot(2,2,4)
plot(t, hatX1.data(2:end,4))
%ylim([0,1e3])

%end %main