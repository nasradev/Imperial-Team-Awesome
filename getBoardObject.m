function [ board ] = getBoardObject( data, squareSize )
% returns an object holding properties of a detected checkerboard
    [imagePoints, worldPoints, colour, threePoints] = ...
        FindCheckerboardPattern( data, squareSize );
     board.imagePoints = imagePoints;
     board.worldPoints = worldPoints;
     board.colour = colour;
     board.threePoints = threePoints;

end