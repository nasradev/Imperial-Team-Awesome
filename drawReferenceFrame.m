function [data] = drawReferenceFrame(data, origin, x, y, z)
    
    multiplyFactor = 10;
    x(1) = round(x(1) + (x(1) - origin(1)) * multiplyFactor);
    x(2) = round(x(2) + (x(2) - origin(2)) * multiplyFactor);
    y(1) = round(y(1) + (y(1) - origin(1)) * multiplyFactor);
    y(2) = round(y(2) + (y(2) - origin(2)) * multiplyFactor);
    z(1) = round(z(1) + (z(1) - origin(1)) * multiplyFactor);
    z(2) = round(z(2) + (z(2) - origin(2)) * multiplyFactor);
    origin = round(origin);
    
    shapeInserter = vision.ShapeInserter('Shape','Lines','BorderColor','Custom',...
        'CustomBorderColor',[255 0 0], 'LineWidth', 3);
    line = int32([origin(1), origin(2), x(1), x(2)]);
    data = step(shapeInserter, data, line);
    shapeInserter = vision.ShapeInserter('Shape','Lines','BorderColor','Custom',...
        'CustomBorderColor',[0 255 0], 'LineWidth', 3);
    line = int32([origin(1), origin(2), y(1), y(2)]);
    data = step(shapeInserter, data, line);
    shapeInserter = vision.ShapeInserter('Shape','Lines','BorderColor','Custom',...
        'CustomBorderColor',[0 0 255], 'LineWidth', 3);
    line = int32([origin(1), origin(2), z(1), z(2)]);
    data = step(shapeInserter, data, line);
end