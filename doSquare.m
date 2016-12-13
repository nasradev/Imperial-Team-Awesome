% Function to do a rectangle with a specified width. x and y are the
% coordinates of the top left corner.

function [rect, xrect, yrect] = doSquare(x, y, width, vidWidth, vidHeight)

xrect = x - width/2;
yrect = y - width/2;
height = width;

if (xrect < 0)
    xrect = 0;
elseif xrect+width > vidWidth
    width = vidWidth-x ;
end
if (yrect < 0)
    yrect = 0;
elseif yrect+width > vidHeight
    height = vidHeight-y;
end

% Compute the rectangle
rect = [xrect yrect width height];
end