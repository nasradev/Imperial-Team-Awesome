%main code
%function main()
clear
clc
close all 
warning off
%%Definitions
%Set the video file and define output video object
obj = VideoReader('IMG_5949-hd.MOV');
vidWidth = obj.Width;
vidHeight = obj.Height;
mov = struct('cdata',zeros(vidHeight,vidWidth,3,'uint8'), 'colormap',[]);


%Framerate Iphon
%dt = 1/30;

%Framerate Webcam
%dt = 1/25;

%Size of checkerboard squares
squareSize = 5.4;

%Load up the camera parameters:
load('iphoneCam1080.mat') %or whatever
k = [cameraParams1080.IntrinsicMatrix', [0; 0; 1]];

%Define Data
firstBoard.colour = zeros(1,3);
secondBoard.colour = zeros(1,3);
thirdBoard.colour = zeros(1,3);

obj.CurrentTime = 1;
counter = 0;
% Go through the video frames
while hasFrame(obj);  
    counter = counter + 1;
    data = readFrame(obj);
    % Get the first checkerboard:
    firstBoard = getBoardObject(data, squareSize);
    
    
    % Get the marker positions:
    %tic
    [red, yellow, green, blue] = getMarkerPos(data);
    m0(counter,:) = red;
    m1(counter,:) = yellow;
%     if mean(red(1:2)) == 0 && counter > 1
%         m0(counter,:) = m0(counter-1,:);
%     end
%     if mean(yellow(1:2)) == 0 && counter > 1
%         m1(counter,:) = m1(counter-1,:);
%     end
    %toc
    
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

     % Red and Yellow in tool 1, Green and Blue in tool 2
    else
        %display('no checkerboards found')
    end
    
    p0(counter,:) = zeros(5,1);%first step
    p1(counter,:) = zeros(5,1);
    p2(counter,:) = zeros(5,1);
    
         
    if counter > 1 %next steps
        p0(counter,:) = p0(counter-1,:);
        p1(counter,:) = p1(counter-1,:);
        p2(counter,:) = p2(counter-1,:);
    end
    
    if firstBoard.colour(3) == 255
        p0(counter,:) = firstBoard.threePoints(1,:);
        p1(counter,:) = firstBoard.threePoints(2,:);
        p2(counter,:) = firstBoard.threePoints(3,:);
        [rot, trans] = extrinsics(firstBoard.imagePoints,...
            firstBoard.worldPoints, cameraParams1080);
        x(counter,:) = [rotm2eul(rot,'ZYX') trans];
    elseif secondBoard.colour(3) == 255
        p0(counter,:) = firstBoard.threePoints(1,:);
        p1(counter,:) = firstBoard.threePoints(2,:);
        p2(counter,:) = firstBoard.threePoints(3,:);
        [rot, trans] = extrinsics(secondBoard.imagePoints,...
            secondBoard.worldPoints, cameraParams1080);
        x(counter,:) = [rotm2eul(rot,'ZYX') trans];
    elseif thirdBoard.colour(3) == 255
        p0(counter,:) = firstBoard.threePoints(1,:);
        p1(counter,:) = firstBoard.threePoints(2,:);
        p2(counter,:) = firstBoard.threePoints(3,:);
        [rot, trans] = extrinsics(thirdBoard.imagePoints,...
            thirdBoard.worldPoints, cameraParams1080);
        x(counter,:) = [rotm2eul(rot,'ZYX') trans];
    end
end %hasFrame

%% Variables Definition
%load('MUpad') %load the variables generated in mupad

%Hand Dimentions
tr = 100;%mm
a = 15/180*pi;

%% Observer
squareSize = 5.4; %size of the scheckerboard squares in mm

%% Data

dt = 1/obj.FrameRate;%0.01;
T = dt*counter;
t = dt : dt : T;

P0 = [t', p0(:,4:5), zeros(length(t),1)];%checkerboard reference (local)
P1 = [t', p1(:,4:5), zeros(length(t),1)];
P2 = [t', p2(:,4:5), zeros(length(t),1)];

Y = [t', p0(:,1:2), p1(:,1:2), p2(:,1:2)];%measure (camera frame)
X = [t' x];

M0 = [t', m0(:,3:5)];%tool reference (local)
M1 = [t', m1(:,3:5)];

Y1 = [t', m0(:,1:2), m1(:,1:2)];%measure (camer frame)

%% Checkerboard 1 State Evolution
% %F = double(F); %state evolution
% F = [zeros(6,6), eye(6), zeros(6,6), zeros(6,6);
%     zeros(6,12), eye(6), zeros(6,6);
%     zeros(6,18), eye(6);
%     zeros(6,24)];
% 
% B = [zeros(18,6); eye(6)]; %observer linear input
% 
% C = [eye(6), zeros(6,18)];
s = tf('s');

Gol1 = 1/s^4*eye(6);
Gol2 = 1/s^2*eye(4);

[F, B, C, D] = ssdata(Gol1);
z0c = [p0(1,1:2), p1(1,1:2), p2(1,1:2), zeros(1,18)];%zeros(1,24);%[[0, 0, 2000, 380, 2000, 380], zeros(1,18)];


%% Marker 1 State Evolution
% F1 = [zeros(4,4), eye(4);
%     zeros(4,8)];
% 
% B1 = [zeros(4,4); eye(4)]; %observer linear input
% 
% C1 = [eye(4), zeros(4,4)];
[F1, B1, C1, D1] = ssdata(Gol2);
z0m = [m0(1:1:2), m0(2,1:2), zeros(1,4)];

%% Gain
load('K')
%Ksys = ss(K);
[Ak, Bk, Ck, Dk] = ssdata(K1);
[Ak_1, Bk_1, Ck_1, Dk_1] = ssdata(K2);%ssdata(K_1);


%% Simulation
sim('trackingSim')

%% Projection to Camera Frame

% P01 = P0(:,2:4)';
% P11 = P1(:,2:4)';
% P21 = P2(:,2:4)';
% 
% for i = 1:length(t)
%     Rx = [1, 0, 0;
%         0, cos(hatX.data(i,1)), -sin(hatX.data(i,1));
%     0, sin(hatX.data(i,1)), cos(hatX.data(i,1))];
%     Ry = [cos(hatX.data(i,2)), 0, sin(hatX.data(i,2));
%         0, 1, 0;
%         -sin(hatX.data(i,2)), 0, cos(hatX.data(i,2))];
%     Rz = [cos(hatX.data(i,1)), -sin(hatX.data(i,1)), 0;
%     sin(hatX.data(i,1)), cos(hatX.data(i,1)), 0;
%     0, 0, 1];
%     R = Rx*Ry*Rz;
%     tran = [hatX.data(i,7); hatX.data(i,9); hatX.data(i,11)];
%     y0(:,i) = k(1:3,1:3)*(R*P01(:,i) + tran);
%     y1(:,i) = k(1:3,1:3)*(R*P11(:,i) + tran);
%     y2(:,i) = k(1:3,1:3)*(R*P21(:,i) + tran);
% end
% 

%% Data Analysis
figure(1) %Measure Plot
subplot(3,2,1)
plot(t, Y(:,2), t, hatY.data(2:end,1), '--')%, t, y0(1,:),'.')
%ylim([0,1e3])
subplot(3,2,2)
plot(t, Y(:,3), t, hatY.data(2:end,2), '--')%, t, y0(2,:),'.')
%ylim([0,1e3])
subplot(3,2,3)
plot(t, Y(:,4), t, hatY.data(2:end,3), '--')%, t, y1(1,:),'.')
%ylim([0,1e3])
subplot(3,2,4)
plot(t, Y(:,5), t, hatY.data(2:end,4), '--')%, t, y1(2,:),'.')
%ylim([0,1e3])
subplot(3,2,5)
plot(t, Y(:,6), t, hatY.data(2:end,5), '--')%, t, y2(1,:),'.')
%ylim([0,1e3])
subplot(3,2,6)
plot(t, Y(:,7), t, hatY.data(2:end,6), '--')%, t, y2(2,:),'.')
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

% figure(3) %State Plot
% subplot(3,2,1)
% plot(t, hatX.data(2:end,1), t, x(:,1), '--')
% xlabel('time [s]')
% ylabel('\theta [degree]')
% grid on
% subplot(3,2,2)
% plot(t, hatX.data(2:end,2), t, x(:,2), '--')
% xlabel('time [s]')
% ylabel('\phi [degree]')
% grid on
% subplot(3,2,3)
% plot(t, hatX.data(2:end,3), t, x(:,3), '--')
% xlabel('time [s]')
% ylabel('\psi [degree]')
% grid on
% subplot(3,2,4)
% plot(t, hatX.data(2:end,7), t, x(:,4), '--')
% xlabel('time [s]')
% ylabel('x [mm]')
% grid on
% subplot(3,2,5)
% plot(t, hatX.data(2:end,9), t, x(:,5), '--')
% xlabel('time [s]')
% ylabel('y [mm]')
% grid on
% subplot(3,2,6)
% plot(t, hatX.data(2:end,11), t, x(:,6), '--')
% xlabel('time [s]')
% ylabel('z [mm]')
% grid on
figure(3) %State Plot
subplot(3,2,1)
plot(t, x(:,1))
xlabel('time [s]')
ylabel('\theta [degree]')
grid on
subplot(3,2,2)
plot(t, x(:,2))
xlabel('time [s]')
ylabel('\phi [degree]')
grid on
subplot(3,2,3)
plot(t, x(:,3))
xlabel('time [s]')
ylabel('\psi [degree]')
grid on
subplot(3,2,4)
plot(t, x(:,4))
xlabel('time [s]')
ylabel('x [mm]')
grid on
subplot(3,2,5)
plot(t, x(:,5))
xlabel('time [s]')
ylabel('y [mm]')
grid on
subplot(3,2,6)
plot(t, x(:,6))
xlabel('time [s]')
ylabel('z [mm]')
grid on

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
subplot(2,1,1)
plot(t, hatX1.data(2:end,1))
xlabel('time [s]')
ylabel('\alpha [degree]')
grid on
subplot(2,1,2)
plot(t, hatX1.data(2:end,3))
xlabel('time [s]')
ylabel('d [mm]')
grid on

%% Plot Frame on Video
obj1 = VideoReader('IMG_5947.MOV');
vidWidth = obj1.Width;
vidHeight = obj1.Height;
mov1 = struct('cdata',zeros(vidHeight,vidWidth,3,'uint8'), 'colormap',[]);


secondColour = [155 200 255];
shapeInserter = vision.ShapeInserter('Shape','Circles','BorderColor','Custom',...
                  'CustomBorderColor',secondColour);
for j= 2:length(hatY.data(:,1))
  data1 = readFrame(obj1);
  circle = int32([hatY.data(j,1) hatY.data(j,2) 2; 0 0 0]); %2 is the size
  %refFrame = quiver3(zeros(3,1),zeros(3,1),zeros(3,1),[1;0;0],[0;1;0],[0;0;1]);
  mov1(j).cdata = step(shapeInserter, data1, circle);
  %mov1(j).cdata = step(shapeInserter, data1, refFrame);
end 

%Output the results to video:
v1 = VideoWriter('resultVideos\IMG_5947_Res');
open(v1)
writeVideo(v1,mov1)
close(v1)
%end %main