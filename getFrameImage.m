function [origin, x, y, z] = getFrameImage(R, t, K)
    % vectors in local frame
    E = eye(3);
    
    % Vectors in camera frame
    Ec = E * R + t;
    
    origin = (t * K);
    
    % Vectors in image frame
    Ei = (Ec * K); % / t(3);
    if origin(3) ~= 0
        Ei(1,:) = Ei(1,:) / Ei(1,3);
        Ei(2,:) = Ei(2,:) / Ei(2,3);
        Ei(3,:) = Ei(3,:) / Ei(3,3);
    end
    % Points to plot
    %origin = (t * K);
    if origin(3) ~= 0
        origin = origin / origin(3);
    end
    x = Ei(1,:);
    y = Ei(2,:);
    z = Ei(3,:);
end