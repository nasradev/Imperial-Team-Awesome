function [Cam2RefCb] = Cam2RefCbTansformation(Rcb, tcb)
    % Cam2RefCb is a matrix that takes from the camera frame to the
    % checkerboard reference frame
    Cam2RefCb = -tcb * Rcb';
end