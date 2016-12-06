function [T] = getAuroraTranslation(record)

% M = tdfread('take1_001.csv',',');
% M = tdfread(fileID,',');

% sampleRate = 40;

toolQuat = zeros(4);
toolTrans = zeros(3);

% tool checkerboard quaternions and translations
toolTrans(1) = record(1); % Tx
toolTrans(2) = record(2); % Ty
toolTrans(3) = record(3); % Tz

toolQuat(1) = record(4); % Q0
toolQuat(2) = record(5); % Qx
toolQuat(3) = record(6); % Qy
toolQuat(4) = record(7); % Qz

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