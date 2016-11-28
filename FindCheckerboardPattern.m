function [imagePoints, worldPoints, colour, threePoints] = ...
                        FindCheckerboardPattern( data, squareSize )

    blue = uint8([0 0 255]);
    red = uint8([255 0 0]);
    
    % Get the checkerboard points in the frame
    [imagePoints, boardSize] = detectCheckerboardPoints(data);
    worldPoints = generateCheckerboardPoints(boardSize, squareSize);
    % Ignore any patterns with fewer than 6 imagePoints as they
    % are likely to be artefacts
    if length(imagePoints) > 6

        % Set default colours to the first and second patterns detected.
        colour = blue;

        % Find the the colour of the detected checkerboard
        pointX = round(imagePoints(1,1) + (imagePoints(boardSize(1),1) - imagePoints(1,1)) / 2);
        pointY = round(imagePoints(boardSize(1),2) + (imagePoints(boardSize(1),2) - imagePoints(1,2)) / 2);           
        rgb = impixel(data,pointX,pointY);
        if (rgb(3) > (rgb(2) + 10)) && (rgb(3) > (rgb(1) + 40))
           colour = blue;
        elseif (rgb(1) > (rgb(2) - 20)) && (rgb(1) > (rgb(3) - 40))
           colour = red; %can also check for another colour here
        elseif (rgb(1) > 110) && (rgb(2) > 110) && (rgb(3) > 110)
           %handle white
        end
        
        xBasePoint = floor(boardSize(1) / 2);
        yPoint = floor(boardSize(2) / 2) * (boardSize(1) - 1) + xBasePoint;
        threePoints = ...
           [imagePoints(xBasePoint, 1) imagePoints(xBasePoint, 2) 0 worldPoints(xBasePoint,1) worldPoints(xBasePoint,2)
            imagePoints(xBasePoint+1, 1) imagePoints(xBasePoint+1, 2) 0 worldPoints(xBasePoint+1,1) worldPoints(xBasePoint+1,2)
            imagePoints(yPoint,1) imagePoints(yPoint,2) 0 worldPoints(yPoint,1) worldPoints(yPoint,2)]
    end
end
