function [temp_data] = hideCheckerboard(data, worldPoints, cameraParams, R, t)
%Returns a part of an image with a black rectangle drawn from point 1 to
%pt2 
%     shapeInserter = vision.ShapeInserter('Fill', true,'Opacity',1);
     padding = 8;
%     %rectW = abs(imagePoints(1,1) -  imagePoints(2,1)) + padding;
%     %rectL = abs(imagePoints(1,2) -  imagePoints(2,2)) + padding;
%     rectW = abs(min(imagePoints(:,1)) - max(imagePoints(:,1))) + padding;
%     rectL = abs(min(imagePoints(:,2)) - max(imagePoints(:,2))) + padding;
%     startX = min(imagePoints(:,1)) - padding;
%     startY = min(imagePoints(:,2)) - padding;
%     rectangle = int32([startX startY rectW rectL]);
%     temp_data = step(shapeInserter, data, rectangle);

    corner1Index = 1;   % CB origin
    corner2Index = find(worldPoints(:,1) == worldPoints(end,1) & worldPoints(:,2) == worldPoints(1,2));
    corner3Index = length(worldPoints);     % corner opposite to the origin
    corner4Index = find(worldPoints(:,1)==worldPoints(1,1) & worldPoints(:,2) == worldPoints(end,2));

    % In checkerboard ref frame
    corner(1, :) = worldPoints(corner1Index, :) + [-padding, -padding];
    corner(2, :) = worldPoints(corner2Index, :) + [padding, -padding];
    corner(3, :) = worldPoints(corner3Index, :) + [padding, padding];
    corner(4, :) = worldPoints(corner4Index, :) + [-padding, padding];
    
    % In image
    corner = [corner zeros(4,1)];   % add the Z dimension
    corner = worldToImage(cameraParams,R,t,corner);

    corners = [corner(1,:) corner(2,:) corner(3,:) corner(4,:)];
    temp_data = insertShape(data, 'FilledPolygon', corners, 'Color', 'black', ...
        'Opacity',1);
end

