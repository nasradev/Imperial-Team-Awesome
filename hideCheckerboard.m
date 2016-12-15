function [ temp_data ] = hideCheckerboard( data, imagePoints )
%Returns a part of an image with a black rectangle drawn from point 1 to
%pt2 
    shapeInserter = vision.ShapeInserter('Fill', true,'Opacity',1);
    padding = 30;
    %rectW = abs(imagePoints(1,1) -  imagePoints(2,1)) + padding;
    %rectL = abs(imagePoints(1,2) -  imagePoints(2,2)) + padding;
    rectW = abs(min(imagePoints(:,1)) - max(imagePoints(:,1)))+2*padding;
    rectL = abs(min(imagePoints(:,2)) - max(imagePoints(:,2))) + 2*padding;
    startX = min(imagePoints(:,1))-padding;
    startY = min(imagePoints(:,2))-padding;
    rectangle = int32([startX startY rectW rectL]);
    temp_data = step(shapeInserter, data, rectangle);
end

