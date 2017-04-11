% cam2aurora function
% Takes a 3D position in the camera frame as an input and gives the
% corresponding 3D position in the aurora frame as an output.

% Campoints is a 3x1 matrix, the same as auroraPoints
% R and t are the camera extrinsic parameters. R is 3x3 and t is 1x3

function [auroraPoints] = cam2aurora(camPoints, R, t, squares)
    
    % Camera position C in world frame is:
    %cam2refCB = t * -R';?? 
    % Estimated points in the reference checkerboard frame
    refCBpoints = (camPoints - t) * R.'; % idem as (camPoints - t') * inv(R)
    
    % The refCB frame is so that:.
    %   x long side of CB and y short side of CB, and z
    %   down (right handed)
    refCB2auroraRot = [0 0 1; -1 0 0; 1 0 0].';
    refCB2auroraTrans = [8 * squares, 5 * squares, 0];
    % Estimated points in the reference checkerboard frame
    auroraPoints = (refCBpoints + [8*squares, -5*squares, 0])...
        * refCB2auroraRot + refCB2auroraTrans;
    auroraPoints = auroraPoints';
end