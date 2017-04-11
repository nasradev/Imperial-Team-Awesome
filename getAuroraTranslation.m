function [campoint, cameuler, camrotation] = getAuroraTranslation(record, Rcb, tcb, squareSize)

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


aurorapoint = T(1:3,4);
Rx = [0 1 0; -1 0 0; 0 0 1];
%Rz = [0 1 0; -1 0 0; 0 0 1];
% This is the rotation matrix for Aurora to Cboard
%       Raugcb = Rx * Rz;
Raugcb = Rx;
% Sample Taugcb translation (in aurora frame):
taugcb = [-5 * squareSize -8 * squareSize 0];
% Transform the Aurora point to Cboard frame
cbpoint = (aurorapoint.' + taugcb) * Raugcb.';

% Transform to camera frame now:
%TODO: Pass this to Gigi
campoint = cbpoint * Rcb - tcb;
camrotation = T(1:3,1:3) * Raugcb' * Rcb;
cameuler = rotm2eul(camrotation);
end