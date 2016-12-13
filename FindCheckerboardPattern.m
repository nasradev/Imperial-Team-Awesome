function [imagePoints, worldPoints, colour, threePoints] = ...
                        FindCheckerboardPattern( data, squareSize )

    blue = uint8([0 0 255]);
    red = uint8([255 0 0]);
    black = uint8([0 0 0]);
    
    % Get the checkerboard points in the frame
    [imagePoints, boardSize] = detectCheckerboardPoints(data);
    % Ignore any patterns with fewer than 6 imagePoints as they
    % are likely to be artefacts
    sz = size(data);
    sf = (720*1280) / (sz(1)*sz(2)); %for image subsets
    if (length(imagePoints) > 6) && (boardSize(1) > 0) && ...
        (abs(min(imagePoints(:,1)) - max(imagePoints(:,1))) * ...
        abs(min(imagePoints(:,2)) - max(imagePoints(:,2))) > (2000/sf) )
        worldPoints = generateCheckerboardPoints(boardSize, squareSize);

        % Set default colours to the first and second patterns detected.
        colour = black;

        % Find the the colour of the detected checkerboard
%         pointX = round(imagePoints(1,1) + (imagePoints(boardSize(1),1) - imagePoints(1,1)) / 2);
%         pointY = round(imagePoints(boardSize(1),2) + (imagePoints(boardSize(1),2) - imagePoints(1,2)) / 2);           
%         rgb = impixel(data,pointX,pointY);

        pointX = round(imagePoints(1,1));
        pointY = round(imagePoints(1,2));
        pointX2 = round(imagePoints(12,1));
        pointY2 = round(imagePoints(12,2));
        
        xrange = [min(pointX,pointX2):max(pointX,pointX2)];
        yrange = [min(pointY,pointY2):max(pointY,pointY2)];
        rgb(1) = max(min(data(yrange,xrange,1)));
        rgb(2) = max(min(data(yrange,xrange,2)));
        rgb(3) = max(min(data(yrange,xrange,3)));
        
        if (rgb(1) < 100) && (rgb(2) < 100) && (rgb(3) < 100) && ...
          rgb(3) < rgb(1) + 40
           colour = black;
        elseif (rgb(3) > (rgb(2) - 30)) && (rgb(3) > (rgb(1) - 15))
           colour = blue;
        elseif (rgb(1) > (rgb(2) - 20)) && (rgb(1) > (rgb(3)+20))
           colour = red; 
        end
        
        xBasePoint = floor(boardSize(1) / 2);
        yPoint = floor(boardSize(2) / 2) * (boardSize(1) - 1) + xBasePoint;
        threePoints = ...
           [imagePoints(xBasePoint, 1) imagePoints(xBasePoint, 2) 0 worldPoints(xBasePoint,1) worldPoints(xBasePoint,2)
            imagePoints(xBasePoint+1, 1) imagePoints(xBasePoint+1, 2) 0 worldPoints(xBasePoint+1,1) worldPoints(xBasePoint+1,2)
            imagePoints(yPoint,1) imagePoints(yPoint,2) 0 worldPoints(yPoint,1) worldPoints(yPoint,2)];
    else
        imagePoints = [-1 -1]; 
        worldPoints = [-1 -1];
        colour = [-1 -1 -1];
        threePoints = [-1 -1 -1 -1 -1; -1 -1 -1 -1 -1; -1 -1 -1 -1 -1];
    end
end
