function [imagePoints, worldPoints, colour, threePoints] = ...
       FindCheckerboardPatternAlternative( data, squareSize, cameraParams )

    blue = uint8([0 0 255]);
    red = uint8([255 0 0]);
    black = uint8([0 0 0]);
    
    % Get the checkerboard points in the frame
    [imagePoints, boardSize] = detectCheckerboardPoints(data);
    % Ignore any patterns with fewer than 6 imagePoints as they
    % are likely to be artefacts
    if (length(imagePoints) > 6) && (boardSize(1) > 0) && ...
        (abs(imagePoints(1,1) - imagePoints(end,1)) * ...
        abs(imagePoints(1,2) - imagePoints(end,2)) > 50 )
        worldPoints = generateCheckerboardPoints(boardSize, squareSize);

        % Set default colours to the first and second patterns detected.
        colour = black;

        % Find the the colour of the detected checkerboard
%         pointX = round(imagePoints(1,1) + (imagePoints(boardSize(1),1) - imagePoints(1,1)) / 2);
%         pointY = round(imagePoints(boardSize(1),2) + (imagePoints(boardSize(1),2) - imagePoints(1,2)) / 2);           
%         rgb = impixel(data,pointX,pointY);

        pointX = round(imagePoints(1,1));
        pointY = round(imagePoints(1,2));
        pointX2 = round(imagePoints(5,1));
        pointY2 = round(imagePoints(5,2));
        
        xrange = [min(pointX,pointX2):max(pointX,pointX2)];
        yrange = [min(pointY,pointY2):max(pointY,pointY2)];
        rgb(1) = max(min(data(yrange,xrange,1)));
        rgb(2) = max(min(data(yrange,xrange,2)));
        rgb(3) = max(min(data(yrange,xrange,3)));
        
        if (rgb(3) > (rgb(2) + 10)) && (rgb(3) > (rgb(1) + 10))
           colour = blue;
        elseif (rgb(1) > (rgb(2) + 10)) && (rgb(1) > (rgb(3)+10))
           colour = red; %can also check for another colour here
        elseif (rgb(1) > 110) && (rgb(2) > 110) && (rgb(3) > 110)
           %handle white
        end
        
        xBasePoint = floor(boardSize(1) / 2);
        yPoint = floor(boardSize(2) / 2) * (boardSize(1) - 1) + xBasePoint;
        
        [R,t] = extrinsics(firstBoard.imagePoints, ...
                    firstBoard.worldPoints, cameraParams);
        K = cameraParams.IntrinsicMatrix;
        xp1 = [worldPoints(xBasePoint,:) 0]*R + t;
        xp1 = xp1*K;
        xp2 = [worldPoints(xBasePoint+1,:) 0]*R + t;
        xp2 = xp2*K;
        xp3 = [worldPoints(yPoint,:) 0]*R + t;
        xp3 = xp2*K;
        threePoints = ...
           [xp1(1) xp1(2) xp1(3) worldPoints(xBasePoint,1) worldPoints(xBasePoint,2)
            xp2(1) xp2(2) xp2(3) worldPoints(xBasePoint+1,1) worldPoints(xBasePoint+1,2)
            xp3(1) xp3(2) xp3(3) worldPoints(yPoint,1) worldPoints(yPoint,2)];
    
    else
        imagePoints = [-1 -1]; 
        worldPoints = [-1 -1];
        colour = [-1 -1 -1];
        threePoints = [-1 -1 -1 -1 -1; -1 -1 -1 -1 -1; -1 -1 -1 -1 -1];
    end
end