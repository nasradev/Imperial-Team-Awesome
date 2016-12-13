clear all;
close all;
filename='new_markers.mp4';

%% Compute Optical Flow Using Lucas-Kanade derivative of Gaussian
 vidReader = VideoReader(filename);

% Create optical flow object.
opticFlow = opticalFlowLKDoG('NumFrames',3);

video=vidReader.read();

for f =1:40% number_of_frames
    %Get frame
    image = video(:,:,:,f);
    frameGray = rgb2gray(image);
    
    % Estimate the optical flow of the objects and display the flow vectors    
    flow = estimateFlow(opticFlow,frameGray);
    thresh=max(flow.Magnitude(:))/10;
    [x_loc, y_loc]=find(flow.Magnitude>thresh);
    locs=[x_loc y_loc];
    if f>2 %starting second frame
        
%% cluster given flow coordinates
        [idx, cen]=dbscan(locs,30,2);
        
        x_loc=locs(idx==1,2);
        y_loc=locs(idx==1,1);
        x2_loc=locs(idx==2,2);
        y2_loc=locs(idx==2,1);
        x3_loc=locs(idx==3,2);
        y3_loc=locs(idx==3,1);
        k1 = boundary(x_loc,y_loc,0.2); %higher shrink factor tighter region, deafult 0.5
        k2 = boundary(x2_loc,y2_loc,0.2);         
        k3 = boundary(x3_loc,y3_loc,0.2);
        
        
        x_loc1=x_loc(k1);
        y_loc1=y_loc(k1);
        
        x_loc2=x2_loc(k2);
        y_loc2=y2_loc(k2);
        
        x_loc3=x3_loc(k3);
        y_loc3=y3_loc(k3);
        
        poly1 = zeros(1,2*length(x_loc1));
        if (~isempty(k1))
            poly1(1,1) = x_loc1(1);
            poly1(1,2) = y_loc1(1);
            
            for j=1:length(x_loc1)-1
                poly1(1,2*j+1)= x_loc1(j+1);
                poly1(1,2*j+2)=y_loc1(j+1);
            end
        end
        
        poly2 = zeros(1,2*length(x_loc2));
        if (~isempty(k2))
            poly2(1,1) = x_loc2(1);
            poly2(1,2) = y_loc2(1);
            for j=1:length(x_loc2)-1
                poly2(1,2*j+1)= x_loc2(j+1);
                poly2(1,2*j+2)=y_loc2(j+1);
            end
        end
        
        poly3 = zeros(1,2*length(x_loc3));
        if (~isempty(k3))
            poly3(1,1) = x_loc3(1);
            poly3(1,2) = y_loc3(1);
            for j=1:length(x_loc3)-1
                poly3(1,2*j+1)= x_loc3(j+1);
                poly3(1,2*j+2)=y_loc3(j+1);
            end
        end        
        
        %% seed segmentation
        % find the average point
%         x = x_loc1(1);
%         y = y_loc1(1);
%         segmentedIm = seedSegment(frameGray,y, x);
%         imshow(segmentedIm);
        
%% Set clustered regions to white
    blackI = zeros(size(image));
    juanaMask=insertShape(blackI, 'FilledPolygon', poly1,'Color','White','Opacity',1);
    juanaMask=insertShape(juanaMask, 'FilledPolygon', poly2,'Color','White','Opacity',1);
    juanaMask=insertShape(juanaMask, 'FilledPolygon', poly3,'Color','White','Opacity',1);
    juanaMask = im2bw(juanaMask);
    
    juana(:,:,1) = image(:,:,1) .* uint8(juanaMask);
	juana(:,:,2) = image(:,:,2) .* uint8(juanaMask);
    juana(:,:,3) = image(:,:,3) .* uint8(juanaMask);

%     markersPos = getMarkersPos(juana);
        
         figure, 
         subplot(1,2,1), imshow(juana),
         subplot(1,2,2), imshow(image), hold on
%          plot(markersPos(1,1), markersPos(1,2), 'r*'), hold on,
%          plot(markersPos(2,1), markersPos(2,2), 'g*'), hold on,
%          plot(markersPos(3,1), markersPos(3,2), 'b*'), hold off

plot( x_loc,y_loc, 'o'), hold on,
plot( x2_loc,y2_loc, 'o'), hold on,
plot( x3_loc,y3_loc, 'o'), hold off

         pause(0.5)
%          figure, imshow(image)
%          hold on



    end       
end
