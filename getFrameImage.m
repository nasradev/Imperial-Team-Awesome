function [origin, x, y, z] = getFrameImage(R, t, K)
    % vectors in local frame
    E = eye(3);
    
    % Vectors in camera frame
    Ec = E * R + t;
    
    % Vectors in image frame
    Ei = (Ec * K) / t(3);
    
    % Points to plot
    origin = (t * K) / t(3);
    x = Ei(1,:);
    y = Ei(2,:);
    z = Ei(3,:);
end