video = 'IMG_6157.MOV';
obj = VideoReader(video);
vidWidth = obj.Width;
vidHeight = obj.Height;

%% this should be in the main

% Outside the loop -----------------------------------------

% initialise the counters
counter = 0;
staticRedCounter = 0;
staticYellowCounter = 0;
% staticGreenCounter = 0;
% staticBlueCounter = 0;

% IN "while hasFrame(obj);" --------------------------------
while hasFrame(obj);
    data = readFrame(obj);
    counter = counter + 1;

    % For the first frame ask for manual rectangles------------------------
    % order is: red - yellow - green - blue
    if counter == 1
        % crop the images interactively around the markers
        % HIDE CHECKERBOARD!!!
        % Red marker
        tinyRed = data;
        [red, redArea] = getRedPos(tinyRed);
        if( red(1) ~=  0 || red(2) ~= 0)
                % reset the counter to 0 because a marker was detected
                staticRedCounter = 0;
        else
                display('No red marker detected');
        end
        
        % Yellow Marker
        tinyYellow = data;
        [yellow, yellowArea] = getYellowPos(tinyYellow);
        if( yellow(1) ~=  0 || yellow(2) ~= 0)
                % reset the counter to 0 because a marker was detected
                staticRedCounter = 0;
        else
                display('No yellow marker detected');
        end
                
%         % Green marker
%         [tinyGreen, rect] = imcrop(data);
%         [green, greenArea] = getGreenPos(tinyGreen);
%         if( green(1) ~=  0 || green(2) ~= 0)
%                 green(1) = green(1) + rect(1);
%                 green(2) = green(2) + rect(2);
%                 % reset the counter to 0 because a marker was detected
%                 staticRedCounter = 0;
%         else
%                 display('No blue marker detected');
%         end
        
%         % Blue marker
%         tinyBlue = data;
%         [blue, blueArea] = getBluePos(tinyBlue);
%         if( blue(1) ~=  0 || blue(2) ~= 0)
%                 % reset the counter to 0 because a marker was detected
%                 staticRedCounter = 0;
%         else
%                 display('No blue marker detected');
%         end

    % For the rest of the video--------------------------------------------
    else
        % then, the markers are computed using tiny images around the last
        % maker pos
        
        imshow(data);
        hold on;
        
        % RED MARKER
        % Square centered on the red marker with an area 5 times the marker
        % area
        width = sqrt(redArea * 20);
        % if the area of the marker is too small, give a min width
        if width < 50
            width = 50;
        end
        
        % do the rectangle
        [rect, xrect, yrect] = doSquare(red(1), red(2), width, vidWidth, vidHeight);
        
        % crop the image around the marker
        tinyRed = imcrop(data,rect);
        
        % if a marker was detected in the last frame
        if staticRedCounter == 0
            % get the new position of the red marker
            lastRed = red;
            [red, redArea] = getRedPos(tinyRed);
            if( red(1) ~=  0 || red(2) ~= 0)
                red(1) = red(1) + xrect;
                red(2) = red(2) + yrect;
                % reset the counter to 0 because a marker was detected
                staticRedCounter = 0;
            else
                red = lastRed;
                staticRedCounter = staticRedCounter + 1;
            end
            % if no marker is detected in 3 consecutive frames use a bigger
            % image
        else
            % Use the entire image to look for the maker
            tinyRed = data;
            % get the new position of the red marker
            lastRed = red;
            [red, redArea] = getRedPos(tinyRed);
            if( red(1) ~=  0 || red(2) ~= 0)
                % reset the counter to 0 because a marker was detected
                staticRedCounter = 0;
            else
                red = lastRed;
                staticRedCounter = staticRedCounter + 1;
            end
        end
        
        plot(red(1), red(2), '*r');
        hold on;
        
        % YELLOW MARKER
        % Square centered on the red marker with an area 5 times the marker
        % area
        width = sqrt(redArea * 20);
        % if the area of the marker is too small, give a min width
        if width < 50
            width = 50;
        end
        
        % do a rectangle
        [rect, xrect, yrect] = doSquare(yellow(1), yellow(2), width, vidWidth, vidHeight);
        
        % crop the image around the marker
        tinyYellow = imcrop(data,rect);
        
        % if a marker was detected in the last frame
        if staticYellowCounter == 0
            % get the new position of the red marker
            lastYellow = yellow;
            [yellow, yellowArea] = getYellowPos(tinyYellow);
            if( yellow(1) ~=  0 || yellow(2) ~= 0)
                yellow(1) = yellow(1) + xrect;
                yellow(2) = yellow(2) + yrect;
                % reset the counter to 0 because a marker was detected
                staticYellowCounter = 0;
            else
                yellow = lastYellow;
                staticYellowCounter = staticYellowCounter + 1;
            end
            % if no marker is detected in 3 consecutive frames use a bigger
            % image
        else
            % Use the entire image to look for the maker
            tinyYellow = data;
            % get the new position of the red marker
            lastYellow = yellow;
            [yellow, yellowArea] = getYellowPos(tinyYellow);
            if( yellow(1) ~=  0 || yellow(2) ~= 0)
                % reset the counter to 0 because a marker was detected
                staticYellowCounter = 0;
            else
                yellow = lastYellow;
                staticYellowCounter = staticYellowCounter + 1;
            end
        end

        plot(yellow(1), yellow(2), '*y');
        hold on;
        
%         % GREEN MARKER
%         % Square centered on the red marker with an area 5 times the marker
%         % area
%         width = sqrt(greenArea * 20);
%         if width < 50
%             width = 50;
%         end
%         % do a rectangle
%         [rect, xrect, yrect] = doSquare(green(1), green(2), width, vidWidth, vidHeight);
%         % crop the image around the marker
%         tinyGreen = imcrop(data,rect);
%         % if no mrker is detected in 3 consecutive frames use a bigger
%         % image
%         if staticGreenCounter == 0
%             % get the new position of the red marker
%             lastGreen = green;
%             [green, greenArea] = getGreenPos(tinyGreen);
%             if( green(1) ~=  0 || green(2) ~= 0)
%                 green(1) = green(1) + xrect;
%                 green(2) = green(2) + yrect;
%                 % reset the counter to 0 because a marker was detected
%                 staticGreenCounter = 0;
%             else
%                 green = lastGreen;
%                 staticGreenCounter = staticGreenCounter + 1;
%             end
%         else
%             % Use the entire image to look for the maker
%             tinyGreen = data;
%             % get the new position of the red marker
%             lastGreen = green;
%             [green, greenArea] = getGreenPos(tinyGreen);
%             if( green(1) ~=  0 || green(2) ~= 0)
%                 % reset the counter to 0 because a marker was detected
%                 staticGreenCounter = 0;
%             else
%                 green = lastGreen;
%                 statiGreenCounter = staticGreenCounter + 1;
%             end
%         end
%         plot(green(1), green(2), '*g');
%         hold on;
        
%         % BLUE MARKER
%         % Square centered on the red marker with an area 20 times the marker
%         % area
%         width = sqrt(blueArea * 20);
%         % if the area of the marker is too small, give a min width
%         if width < 50
%             width = 50;
%         end
%         
%         % do a rectangle
%         [rect, xrect, yrect] = doSquare(blue(1), blue(2), width, vidWidth, vidHeight);
%         % crop the image around the marker
%         tinyBlue = imcrop(data,rect);
%         % if no mrker is detected in 3 consecutive frames use a bigger
%         % image
%         if staticBlueCounter == 0
%             % get the new position of the red marker
%             lastBlue = blue;
%             [blue, blueArea] = getBluePos(tinyBlue);
%             if( blue(1) ~=  0 || blue(2) ~= 0)
%                 blue(1) = blue(1) + xrect;
%                 blue(2) = blue(2) + yrect;
%                 % reset the counter to 0 because a marker was detected
%                 staticBlueCounter = 0;
%             else
%                 blue = lastBlue;
%                 staticBlueCounter = staticBlueCounter + 1;
%             end
%         else
%             % Use the entire image to look for the maker
%             tinyBlue = data;
%             % get the new position of the red marker
%             lastBlue = blue;
%             [blue, blueArea] = getBluePos(tinyBlue);
%             if( blue(1) ~=  0 || blue(2) ~= 0)
%                 % reset the counter to 0 because a marker was detected
%                 staticBlueCounter = 0;
%             else
%                 blue = lastBlue;
%                 statiBlueCounter = staticBlueCounter + 1;
%             end
%         end
%         plot(blue(1), blue(2), '*b');
        hold off;
        pause(0.1);
    end
end