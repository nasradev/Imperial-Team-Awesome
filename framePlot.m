xworld = [1 0 0];
% [R,t] = extrinsics(secondBoard.imagePoints, ...
%                     secondBoard.worldPoints, cameraParams);
%e.g.
R = [
    0.0812    0.6005   -0.7955
   -0.9935   -0.0151   -0.1128
   -0.0798    0.7995    0.5954];
t = [ -216.4329 -123.8350  692.0699];

xcamera = xworld * R + t;
% define K = intrinsic params
% K = cameraParams.IntrinsicMatrix
ximage = xcamera*K;

% scaling for Z
ximage = ximage / ximage(3);

plot(ximage(1),ximage(2),'ro')
plot(secondBoard.imagePoints(1,1),secondBoard.imagePoints(1,2),'ro')



