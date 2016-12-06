M = tdfread('take1_001.csv',',');

sampleRate = 40;

toolQuat = zeros(420,4);
toolTrans = zeros(420,3);

% tool checkerboard quaternions and translations
toolTrans(:,1) = M.Tx1; % Tx
toolTrans(:,2) = M.Ty1; % Ty
toolTrans(:,3) = M.Tz1; % Tz

toolQuat(:,1) = M.Q01; % Q0
toolQuat(:,2) = M.Qx1; % Qx
toolQuat(:,3) = M.Qy1; % Qy
toolQuat(:,4) = M.Qz1; % Qz

% quaternions to euler angles (ZYX)
toolEul = quat2eul(toolQuat);

% build transformation matrix for each capture
T = zeros(4, 4, 420);
T (4,4,:) = 1;
for i = 1:420
    T (1:3,4,i) = toolTrans(i,:);
    T (1,1,i) = toolEul(i,3);
    T (2,2,i) = toolEul(i,2);
    T (3,3,i) = toolEul(i,1);
end
%% Transformation part
% k is 3 by 4 homogeneous
load('iphoneCam.mat');

% Extrinsic
for img=1:length(cameraParams.TranslationVectors)
    r(:,:,img)=cameraParams.RotationMatrices(:,:,img); %3,3
    t(img,:)=cameraParams.TranslationVectors(img,:); %1,3->3,1
    rt=[r(:,:,img) t(img,:)];
    %P(:,:,img)=K*rt(:,:,img);
end

