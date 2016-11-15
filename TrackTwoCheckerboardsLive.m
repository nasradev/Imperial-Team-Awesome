function TrackTwoCheckerboardsLive( cameraParams )
%% Input:
%% 1. cameraParams object (from camera calibration) 

%Set some constants
yellow = uint8([255 255 0]);
red = uint8([255 0 0]);

obj = videoinput('winvideo',1,'MJPG_640x480');

try   
    %Initialize various parameters, and load in the template data
    set(obj,'framesperTrigger',10,'TriggerRepeat',Inf);
    start(obj);

    % h is a handle to the canvas
    h = imshow(zeros(480,640));
    hold on;

    figure(1);
    
    %Set the starting ground pattern X and Y
    prevGroundX = 0;
    prevGroundY = 0;
    
    %Read each frame of the input video:
    while islogging(obj);              
        data = getdata(obj,1);
        flushdata(obj);
        %Get the checkerboard points in the frame
        [imagePoints, boardSize] = detectCheckerboardPoints(data);
        
        %Ignore any patterns with fewer than 6 imagePoints as they
        %are likely to be artefacts
        if length(imagePoints) > 6
            
            %Set default colours to the first and second patterns detected.
            firstColour = yellow;
            secondColour = red;
            
            %Insert a black rectangle in order to hide the prev checkerboard
            %so we can find the next one in the same image
            shapeInserter = vision.ShapeInserter('Fill', true,'Opacity',1);
            padding = 10;
            rectW = min(imagePoints(:,1)) -  max(imagePoints(:,1)) + padding;
            rectL = min(imagePoints(:,2)) -  max(imagePoints(:,2)) + padding;
            startX = min(imagePoints(:,1));
            startY = min(imagePoints(:,2));
            rectangle = int32([startX startY abs(rectW) abs(rectL)]);
            
            %Can also use a temp data object if we do not wish to show the
            %black rectangle in the output image.
            %dataTemp = step(shapeInserter, data, rectangle);
            data = step(shapeInserter, data, rectangle);
            %[imagePoints2, boardSize2] = detectCheckerboardPoints(dataTemp);
            [imagePoints2, boardSize2] = detectCheckerboardPoints(data);
        
            %See if we did indeed find a second checkerboard
            if length(imagePoints2) > 6
              %Check if this new pattern is closer to the last frame's 
              %'ground' aka yellow aka first pattern. 
              %If it is then this is the new yellow, 
              %otherwise this is the second pattern in the image.
              if sqrt(power((startX - prevGroundX),2) + ...
                      power((startY - prevGroundY),2)) ...
                 < sqrt(power((min(imagePoints2(:,1)) - prevGroundX),2) + ...
                      power((min(imagePoints2(:,2)) - prevGroundY),2))
                 
                 prevGroundX = startX;
                 prevGroundY = startY;
              else
                  prevGroundX = min(imagePoints2(:,1));
                  prevGroundY = min(imagePoints2(:,2));
                  firstColour = red;
                  secondColour = yellow;
              end
              
              %Insert the circles outlining the second checkerboard
              shapeInserter = vision.ShapeInserter('Shape','Circles','BorderColor','Custom',...
    'CustomBorderColor',secondColour);

              %Only show the first circle to reduce computation time,
              %or replace the below with j= 1:length(imagePoints2(:,1))-1
              for j= 1:1
               circle = int32([imagePoints2(j,1) imagePoints2(j,2) 2; 0 0 0]);
               data = step(shapeInserter, data, circle);
              end
                       %Finally, calculate distance from second pattern:
                       squareSize = 5.4; % in millimeters
                       worldPoints2 = generateCheckerboardPoints(boardSize2, squareSize);
                       %Get the R matrix and t vector. The translation is
                       %with relation to the first imagePoint.
                       [R, t] = extrinsics(imagePoints2, worldPoints2, cameraParams);
                       % Compute the distance to the camera.   
                       distanceToCamera = norm(t);
                       position = [350 50];
                       %Add a label in the image that shows where we
                       %believe the second pattern is.
                       t = strcat('Distance mm: ', num2str(distanceToCamera));
                       text = [t];
                       data = insertText(data, position, text, 'FontSize',18,'BoxColor',...
                        secondColour,'BoxOpacity',0.4,'TextColor','white');

            end
            
            %Now continue processing the first pattern.
            %Insert the circle(s) outlining the first checkerboard.
            shapeInserter = vision.ShapeInserter('Shape','Circles','BorderColor','Custom',...
    'CustomBorderColor',firstColour);
            %for j= 1:length(imagePoints(:,1))-1
            for j= 1:1
               circle = int32([imagePoints(j,1) imagePoints(j,2) 2; 0 0 0]);
               data = step(shapeInserter, data, circle);
            end
            
           %Finally, calculate distance from first pattern:
           squareSize = 5.4; % in millimeters
           worldPoints = generateCheckerboardPoints(boardSize, squareSize);
           [R, t] = extrinsics(imagePoints, worldPoints, cameraParams);
           % Convert to world coordinates.
           cboard1_world  = pointsToWorld(cameraParams, R, t, imagePoints(1,:));

           % Compute the distance to the camera.   
           distanceToCamera = norm(t);
           position = [50 50];
           txt = strcat('Distance mm: ', num2str(distanceToCamera));
           text = [txt];
           data = insertText(data, position, text, 'FontSize',18,'BoxColor',...
            firstColour,'BoxOpacity',0.4,'TextColor','white');

        end


        %% This is what paints on the canvas
        %set(h,'Cdata',I);
        set(h,'Cdata',data);
        drawnow;
    end

catch err
    % This attempts to take care of things when the figure is closed
    stop(obj);
    imaqreset
    disp('Cleaned up')
    rethrow(err);
end    
end

