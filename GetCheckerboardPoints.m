function [ returnPoints ] = GetCheckerboardPoints( data, squareSize )
    returnPoints = zeros(3,5);
    [imagePoints, boardSize] = detectCheckerboardPoints(data);
    if length(imagePoints) > 6
      worldPoints = generateCheckerboardPoints(boardSize, squareSize);
      returnPoints = [imagePoints(1,1) imagePoints(1,2) 0 worldPoints(1,1) worldPoints(1,2)
            imagePoints(boardSize(1)-1,1) imagePoints(boardSize(1)-1,2) 0 worldPoints(boardSize(1)-1,1) worldPoints(boardSize(1)-1,2)
            imagePoints(boardSize(2)-1,1) imagePoints(boardSize(2)-1,2) 0 worldPoints(boardSize(2)-1,1) worldPoints(boardSize(2)-1,2)];
    end
end

