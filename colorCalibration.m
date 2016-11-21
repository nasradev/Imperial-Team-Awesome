function [correctionFactorR, correctionFactorG, correctionFactorB] = colorCalibration(Image, rectangle)

rgbImage = imread(Image);
imshow(rgbImage);
fontSize = 15;
title('Double-click inside box to finish box', 'FontSize', 15);
% Enlarge figure to full screen.
set(gcf, 'units','normalized','outerposition', [0 0 1 1]);
% Have user specify the area they want to define as neutral colored (white  or gray).
promptMessage = sprintf('Drag out a box over the ROI you want to be neutral colored.\nDouble-click inside of it to finish it.');
titleBarCaption = 'Continue?';
button = questdlg(promptMessage, titleBarCaption, 'Draw', 'Cancel', 'Draw');
if strcmpi(button, 'Cancel')
	return;
end
hBox = imrect;
roiPosition = wait(hBox);	% Wait for user to double-click
roiPosition % Display in command window.
% Get box coordinates so we can crop a portion out of the full sized image.
xCoords = [roiPosition(1), roiPosition(1)+roiPosition(3), roiPosition(1)+roiPosition(3), roiPosition(1), roiPosition(1)];
yCoords = [roiPosition(2), roiPosition(2), roiPosition(2)+roiPosition(4), roiPosition(2)+roiPosition(4), roiPosition(2)];
croppingRectangle = roiPosition;
% Display (shrink) the original color image in the upper left.
subplot(2, 4, 1);
imshow(rgbImage);
title('Original Color Image', 'FontSize', 15);
% Crop out the ROI.
whitePortion = imcrop(rgbImage, croppingRectangle);
subplot(2, 4, 5);
imshow(whitePortion);
caption = sprintf('ROI.\nWe will Define this to be "White"');
title(caption, 'FontSize', 15);
% Extract the individual red, green, and blue color channels.
redChannel = whitePortion(:, :, 1);
greenChannel = whitePortion(:, :, 2);
blueChannel = whitePortion(:, :, 3);
% Display the color channels.
subplot(2, 4, 2);
imshow(redChannel);
title('Red Channel ROI', 'FontSize', 15);
subplot(2, 4, 3);
imshow(greenChannel);
title('Green Channel ROI', 'FontSize', 15);
subplot(2, 4, 4);
imshow(blueChannel);
title('Blue Channel ROI', 'FontSize', 15);
% Get the means of each color channel
meanR = mean2(redChannel);
meanG = mean2(greenChannel);
meanB = mean2(blueChannel);
% Let's compute and display the histograms.
[pixelCount grayLevels] = imhist(redChannel);
subplot(2, 4, 6); 
bar(pixelCount);
grid on;
caption = sprintf('Histogram of original Red ROI.\nMean Red = %.1f', meanR);
title(caption, 'FontSize', 15);
xlim([0 grayLevels(end)]); % Scale x axis manually.
% Let's compute and display the histograms.
[pixelCount grayLevels] = imhist(greenChannel);
subplot(2, 4, 7); 
bar(pixelCount);
grid on;
caption = sprintf('Histogram of original Green ROI.\nMean Green = %.1f', meanR);
title(caption, 'FontSize', 15);
xlim([0 grayLevels(end)]); % Scale x axis manually.
% Let's compute and display the histograms.
[pixelCount grayLevels] = imhist(blueChannel);
subplot(2, 4, 8); 
bar(pixelCount);
grid on;
caption = sprintf('Histogram of original Blue ROI.\nMean Blue = %.1f', meanR);
title(caption, 'FontSize', 15);
xlim([0 grayLevels(end)]); % Scale x axis manually.
% specify the desired mean.
desiredMean = mean([meanR, meanG, meanB])
message = sprintf('Red mean = %.1f\nGreen mean = %.1f\nBlue mean = %.1f\nWe will make all of these means %.1f',...
	meanR, meanG, meanB, desiredMean);
uiwait(helpdlg(message));
% Linearly scale the image in the cropped ROI.
correctionFactorR = desiredMean / meanR;
correctionFactorG = desiredMean / meanG;
correctionFactorB = desiredMean / meanB;
redChannel = uint8(single(redChannel) * correctionFactorR);
greenChannel = uint8(single(greenChannel) * correctionFactorG);
blueChannel = uint8(single(blueChannel) * correctionFactorB);
% Recombine into an RGB image
% Recombine separate color channels into a single, true color RGB image.
correctedRgbImage = cat(3, redChannel, greenChannel, blueChannel);
figure;
% Display the original color image.
subplot(2, 4, 5);
imshow(correctedRgbImage);
title('Color-Corrected ROI', 'FontSize', 15);
% Enlarge figure to full screen.
set(gcf, 'units','normalized','outerposition',[0 0 1 1]);
% Display the color channels.
subplot(2, 4, 2);
imshow(redChannel);
title('Corrected Red Channel ROI', 'FontSize', 15);
subplot(2, 4, 3);
imshow(greenChannel);
title('Corrected Green Channel ROI', 'FontSize', fontSize);
subplot(2, 4, 4);
imshow(blueChannel);
title('Corrected Blue Channel ROI', 'FontSize', fontSize);
% Let's compute and display the histograms of the corrected image.
[pixelCount grayLevels] = imhist(redChannel);
subplot(2, 4, 6); 
bar(pixelCount);
grid on;
caption = sprintf('Histogram of Corrected Red ROI.\nMean Red = %.1f', meanR);
title(caption, 'FontSize', fontSize);
xlim([0 grayLevels(end)]); % Scale x axis manually.
% Let's compute and display the histograms.
[pixelCount grayLevels] = imhist(greenChannel);
subplot(2, 4, 7); 
bar(pixelCount);
grid on;
caption = sprintf('Histogram of Corrected Green ROI.\nMean Green = %.1f', meanR);
title(caption, 'FontSize', fontSize);
xlim([0 grayLevels(end)]); % Scale x axis manually.
% Let's compute and display the histograms.
[pixelCount grayLevels] = imhist(blueChannel);
subplot(2, 4, 8); 
bar(pixelCount);
grid on;
caption = sprintf('Histogram of Corrected Blue ROI.\nMean Blue = %.1f', meanR);
title(caption, 'FontSize', fontSize);
xlim([0 grayLevels(end)]); % Scale x axis manually.
% Get the means of the corrected ROI for each color channel.
meanR = mean2(redChannel);
meanG = mean2(greenChannel);
meanB = mean2(blueChannel);
correctedMean = mean([meanR, meanG, meanB])
message = sprintf('Now, the\nCorrected Red mean = %.1f\nCorrected Green mean = %.1f\nCorrected Blue mean = %.1f\n(Differences are due to clipping.)\nWe now apply it to the whole image',...
	meanR, meanG, meanB);
uiwait(helpdlg(message));
% Now correct the original image.
% Extract the individual red, green, and blue color channels.
redChannel = rgbImage(:, :, 1);
greenChannel = rgbImage(:, :, 2);
blueChannel = rgbImage(:, :, 3);
% Linearly scale the full-sized color channel images
redChannelC = uint8(single(redChannel) * correctionFactorR);
greenChannelC = uint8(single(greenChannel) * correctionFactorG);
blueChannelC = uint8(single(blueChannel) * correctionFactorB);
% Recombine separate color channels into a single, true color RGB image.
correctedRGBImage = cat(3, redChannelC, greenChannelC, blueChannelC);
subplot(2, 4, 1);
imshow(correctedRGBImage);
title('Corrected Full-size Image', 'FontSize', fontSize);
message = sprintf('Done with the demo.\nPlease flicker between the two figures');
uiwait(helpdlg(message));