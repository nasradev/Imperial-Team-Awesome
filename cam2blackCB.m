% cam2aurora function
% Takes a 3D position in the camera frame as an input and gives the
% corresponding 3D position in the aurora frame as an output.

% Campoints is a 3x1 matrix, the same as auroraPoints
% R and t are the camera extrinsic parameters. R is 3x3 and t is 1x3

function [refCBpoints] = cam2blackCB(camPoints, R, t)
    
    % Camera position C in world frame is:
    % cam2refCB = t * -R';?? 
    % Estimated points in the reference checkerboard frame
    refCBpoints = (camPoints - t) * R.'; % idem as (camPoints - t') * inv(R)
end