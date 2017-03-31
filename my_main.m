%% Variables Definition
load('MUpad') %load the variables generated in mupad

%Hand Dimentions
tr = 1;
a = 0;


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

load('giovsCameraParamsLaptop')

squareSize = 4; %size of the scheckerboard squares in mm

[time, p0, p1, p2] = TrackTwoCheckerboardsLive( cameraParams, squareSize );



%% Data

dt = mean(time);
T = dt*length(p0);
t = dt : dt : T;

P0 = [t', p0(3:5,:)'];
P1 = [t', p1(3:5,:)'];
P2 = [t', p2(3:5,:)'];

Y = [t', p0(1:2,:)', p1(1:2,:)', p2(1:2,:)'];

%%%%%Trial%%%%%
m0 = zeros(5, length(p0));
m1 = m0;
%%%%%%%%%%%%%%%
M0 = [t', m0(3:5,:)'];
M1 = [t', m1(3:5,:)'];

Y1 = [t', m0(1:2,:)', m1(1:2,:)'];

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
[Ak, Bk, Ck, Dk] = ssdata(K);
[Ak_1, Bk_1, Ck_1, Dk_1] = ssdata(K_1);


%% Simulation
sim('trackingSim')

%% Data Analysis
figure(1) %Measure Plot
subplot(3,2,1)
plot(t, Y(:,1), t, hatY.data(2:end,1), '--')
%ylim([0,1e3])
subplot(3,2,2)
plot(t, Y(:,2), t, hatY.data(2:end,2), '--')
%ylim([0,1e3])
subplot(3,2,3)
plot(t, Y(:,3), t, hatY.data(2:end,3), '--')
%ylim([0,1e3])
subplot(3,2,4)
plot(t, Y(:,4), t, hatY.data(2:end,4), '--')
%ylim([0,1e3])
subplot(3,2,5)
plot(t, Y(:,5), t, hatY.data(2:end,5), '--')
%ylim([0,1e3])
subplot(3,2,6)
plot(t, Y(:,6), t, hatY.data(2:end,6), '--')
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
plot(t, Y1(:,1), t, hatY1.data(2:end,1), '--')
%ylim([0,1e3])
subplot(2,2,2)
plot(t, Y1(:,2), t, hatY1.data(2:end,2), '--')
%ylim([0,1e3])
subplot(2,2,3)
plot(t, Y1(:,3), t, hatY1.data(2:end,3), '--')
%ylim([0,1e3])
subplot(2,2,4)
plot(t, Y1(:,4), t, hatY1.data(2:end,4), '--')
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