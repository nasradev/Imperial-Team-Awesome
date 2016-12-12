video = 'IMG_5947.MOV';
obj = VideoReader(video);
vidWidth = obj.Width;
vidHeight = obj.Height;

%% this should be in the main

% Outside the loop -----------------------------------------
% first, you get the initial good markers position in the video
% you can go to an specific time
iniTime = 0.0;
[initialMarkers, initialAreas, currentTime] = getInitialGuess(video, iniTime);
redArea     = initialAreas(1,2);
yellowArea  = initialAreas(1,2);
greenArea   = initialAreas(1,3);
blueArea    = initialAreas(1,4);

counter = 0;
staticRedCounter = 0;
staticYellowCounter = 0;

% IN "while hasFrame(obj);" --------------------------------
while hasFrame(obj);
    data = readFrame(obj);
    counter = counter + 1;
    % give zeros from the markers positions until the initial frame
    if obj.currentTime < currentTime
        red     = [0 0 0 0 105];
        yellow  = [0 0 0 0 25];
        green   = [0 0 0 0 130];
        blue    = [0 0 0 0 30];
    elseif obj.currentTime == currentTime
        % initialize variables
        red     = [initialMarkers(1,1), initialMarkers(1,2)];
        yellow  = [initialMarkers(2,1), initialMarkers(2,2)];
        green   = [initialMarkers(3,1), initialMarkers(3,2)];
        blue    = [initialMarkers(4,1), initialMarkers(4,2)];
        lastRed = red;
        lastYellow = yellow;
    else
        % then, the markers are computed using tiny images around the last
        % maker pos
        
%         imshow(data);
%         hold on;
        
        % RED MARKER
        % Square centered on the red marker with an area 5 times the marker
        % area
        width = sqrt(redArea * 20);
        % if the area of the marker is too small, give a min width
        if width < 50
            width = 50;
        end
        
        % Compute the rectangle
        xrect = red(1) - width/2;
        yrect = red(2) - width/2;
        
        rect = [xrect yrect width width];
        if (xrect < 0)
            rect = [0 yrect width width];
        elseif xrect+width > vidWidth
            rect = [0 yrect vidWidth-red(1) width];
        end
        if (yrect < 0)
            rect = [xrect 0 width width];
        elseif yrect+width > vidHeight
            rect = [xrect yrect width vidHeight-red(2)];
        end
        
        % crop the image around the marker
        tinyRed = imcrop(data,rect);
        % if no mrker is detected in 3 consecutive frames use a bigger
        % image
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
        
%         plot(red(1), red(2), '*r');
%         hold on;
        
        % YELLOW MARKER
        % Square centered on the red marker with an area 5 times the marker
        % area
        width = sqrt(redArea * 20);
        % if the area of the marker is too small, give a min width
        if width < 50
            width = 50;
        end
        
        xrect = yellow(1) - width/2;
        yrect = yellow(2) - width/2;
        
        rect = [xrect yrect width width];
        if (xrect < 0)
            rect = [0 yrect width width];
        elseif xrect+width > vidWidth
            rect = [0 yrect vidWidth-yellow(1) width];
        end
        if (yrect < 0)
            rect = [xrect 0 width width];
        elseif yrect+width > vidHeight
            rect = [xrect yrect width vidHeight-yellow(2)];
        end
        % crop the image around the marker
        % crop the image around the marker
        tinyYellow = imcrop(data,rect);
        % if no mrker is detected in 3 consecutive frames use a bigger
        % image
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
        
%         plot(yellow(1), yellow(2), '*y');
%         hold off;
%         pause(0.5);
        
        %     % GREEN MARKER
        %     % Square centered on the red marker with an area 5 times the marker
        %     % area
        %     width = sqrt(greenArea * 10);
        %     xrect = green(1) - width/2;
        %     yrect = green(2) - width/2;
        %
        %     rect = [xrect yrect width width];
        %     if (xrect < 0)
        %         rect = [0 yrect width width];
        %     elseif xrect+width > vidWidth
        %         rect = [0 yrect vidWidth-green(1) width];
        %     end
        %     if (yrect < 0)
        %         rect = [xrect 0 width width];
        %     elseif yrect+width > vidHeight
        %         rect = [xrect yrect width vidHeight-green(2)];
        %     end
        %     % crop the image around the marker
        %     tinyGreen = imcrop(data,rect);
        %     [green, greenArea] = getGreenPos(tinyGreen);
        %     green(1) = green(1) + xrect;
        %     green(2) = green(2) + yrect;
        %
        %     % BLUE MARKER
        %     % Square centered on the red marker with an area 5 times the marker
        %     % area
        %     width = sqrt(blueArea * 10);
        %     xrect = blue(1) - width/2;
        %     yrect = blue(2) - width/2;
        %
        %     rect = [xrect yrect width width];
        %     if (xrect < 0)
        %         rect = [0 yrect width width];
        %     elseif xrect+width > vidWidth
        %         rect = [0 yrect vidWidth-blue(1) width];
        %     end
        %     if (yrect < 0)
        %         rect = [xrect 0 width width];
        %     elseif yrect+width > vidHeight
        %         rect = [xrect yrect width vidHeight-blue(2)];
        %     end
        %     % crop the image around the marker
        %     tinyBlue = imcrop(data,rect);
        %     [blue, blueArea] = getBluePos(tinyBlue);
        %     blue(1) = blue(1) + xrect;
        %     blue(2) = blue(2) + yrect;
    end
end