function [T] = getAuroraTranslation(record)

% M = tdfread('take1_001.csv',',');
% M = tdfread(fileID,',');

% sampleRate = 40;

toolQuat = zeros(1, 4);
toolTrans = zeros(3, 1);

% tool checkerboard quaternions and translations
toolTrans(1) = record(1); % Tx
toolTrans(2) = record(2); % Ty
toolTrans(3) = record(3); % Tz

toolQuat(1) = record(4); % Q0
toolQuat(2) = record(5); % Qx
toolQuat(3) = record(6); % Qy
toolQuat(4) = record(7); % Qz

% quaternions to rotation matrix
R = quat2rotm(toolQuat);

% build transformation matrix for each capture
T = [R toolTrans];
T = [T; [0 0 0 1]];

end