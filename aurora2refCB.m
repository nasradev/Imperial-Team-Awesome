function [refCBpoints] = aurora2refCB(auroraPoints, squares) 
    % The refCB frame is so that:.
    %   x goes left and y towards the camera along the long side, and z
    %   down
    aurora2refCBRot = [0 -1 0; 1 0 0; 0 0 -1];
    refCB2auroraTrans = [-5 * squares, 8 * squares, 0];
    % Estimated points in the reference checkerboard frame
    refCBpoints = (auroraPoints - refCB2auroraTrans) * aurora2refCBRot;
end