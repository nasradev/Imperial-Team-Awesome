function [temp_data] = hideCheckerboardTemp(data, imagePoints)
%Returns a part of an image with a black rectangle drawn from point 1 to
%pt2 
    shapeInserter = vision.ShapeInserter('Fill', true,'Opacity',1);
    padding = 10;
    %rectW = abs(imagePoints(1,1) -  imagePoints(2,1)) + padding;
    %rectL = abs(imagePoints(1,2) -  imagePoints(2,2)) + padding;
    rectW = abs(min(imagePoints(:,1)) - max(imagePoints(:,1)));
    rectL = abs(min(imagePoints(:,2)) - max(imagePoints(:,2)));
    startX = min(imagePoints(:,1));
    startY = min(imagePoints(:,2));
    rectangle = int32([startX startY rectW rectL]);
    temp_data = step(shapeInserter, data, rectangle);

end