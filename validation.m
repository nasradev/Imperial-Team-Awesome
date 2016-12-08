function [T] = getAuroraTranslation(M)

% M = tdfread('take1_001.csv',',');
% M = tdfread(fileID,',');

% sampleRate = 40;

toolQuat = zeros(4);
toolTrans = zeros(3);

% tool checkerboard quaternions and translations
toolTrans(1) = M.Tx1; % Tx
toolTrans(2) = M.Ty1; % Ty
toolTrans(3) = M.Tz1; % Tz

toolQuat(1) = M.Q01; % Q0
toolQuat(2) = M.Qx1; % Qx
toolQuat(3) = M.Qy1; % Qy
toolQuat(4) = M.Qz1; % Qz

% quaternions to euler angles (ZYX)
toolEul = quat2eul(toolQuat);

% build transformation matrix for each capture
T = zeros(4, 4);
T (4,4) = 1;

T (1:3,4) = toolTrans(:);
T (1,1) = toolEul(3);
T (2,2) = toolEul(2);
T (3,3) = toolEul(1);
end