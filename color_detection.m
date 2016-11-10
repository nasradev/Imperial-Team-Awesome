clear;
close all;
FileName='osupervideo.MOV';
% Load the video
obj = VideoReader(FileName);
video = obj.read();
%Then, frame #K is
v = VideoWriter('supervideo_processed.avi');
open(v);
for k =1:3
image = video(:,:,:,k);

% figure, imshow(image);
% title('original');
% Load the image
%image = imread('IMG_5573.JPG');

% Separate in three RGB channels
im_r = image(:,:,1);
im_g = image(:,:,2);
im_b = image(:,:,3);

% Initialise
noBack_r = im_r;
noBack_g = im_g;
noBack_b = im_b;
for i = 1:length(image(:,1,1))
    for j = 1:length(image(1,:,1))
        if (im_r(i,j) > 150 && im_g(i,j) > 150 && im_b(i,j) > 150)
            noBack_r(i,j) = 0;
            noBack_g(i,j) = 0;
            noBack_b(i,j) = 0;
        end
    end
end

%% Thresholding

%Threshold red
levelR = graythresh(noBack_r);
redMask = im2bw(noBack_r, levelR);

%Threshold green
levelG = graythresh(noBack_g);
greenMask = im2bw(noBack_g, levelG);

%Threshold blue
levelB = graythresh(noBack_b);
blueMask = im2bw(noBack_b, levelB);

% Get rid of small objects.
% First an erosion, then only keep objects between 900 and 5000 px and
% finally a dilatation
redMask = imerode(redMask, strel('diamond', 2));
redMask = imdilate(redMask, strel('diamond', 3));
redMask = bwareafilt(redMask,[2000 200000]);

greenMask = imerode(greenMask , strel('diamond', 2));
greenMask = imdilate(greenMask , strel('diamond', 3));
greenMask = bwareafilt(greenMask ,[2000 200000]);

blueMask = imerode(blueMask , strel('diamond', 2));
blueMask = imdilate(blueMask , strel('diamond', 3));
blueMask = bwareafilt(blueMask ,[2000 200000]);


%% Reconstruction
% reconstruct an image with all the markers
allMask = (redMask | greenMask | blueMask);
all(:,:,1) = uint8(allMask) .* noBack_r;
all(:,:,2) = uint8(allMask) .* noBack_g;
all(:,:,3) = uint8(allMask) .* noBack_b;

% Get centroid of segmented regions and save frames(k)
%% Labeling and finding centroids

% label the image
[L,num] = bwlabel(allMask);

% get the centroids
s = regionprops(L,'centroid','BoundingBox','Area');
centroids = cat(1, s.Centroid);

% See the colors of the centroids
colors = impixel (all, centroids(:,1), centroids(:,2));

% go through all the centroids and check to what color they correspond
% create a matrix with
%   - as many rows as labels there are
%   - 4 columns (one for the label number, 2 for the centroid pos, 1 for the
%   color).
listIndex = zeros(num,4);
for i = 1:num
    % LABEL NAME
    listIndex (i,1) = i;
    % CENTROID POSITION
    listIndex (i,2) = centroids(i, 1);
    listIndex (i,3) = centroids(i, 2);
    % COLOR
    %     if not all 3 channels are 0 save otherwise delete region
    if (colors(i,1) ~= 0 || colors(i,2) ~= 0 || colors(i,3) ~= 0)
        [M,I] = max(colors(i,:));
        listIndex(i,4) = I;
    else         
%         ind=listIndex(i,1);
%         bb = s(ind).BoundingBox;
%         imshow(all);
%         rectangle('Position', bb, 'EdgeColor', 'red');
%         x=bb(1,1);
%         y=bb(1,2);
%         w=bb(1,3);
%         h=bb(1,4);
%         L(int16(y):int16(y+h),int16(x):int16(x+w),:)=0;
%         figure,imshow(L);
ind=listIndex(i,1);
for r=1:size(L,1)
    for c=1:size(L,2)
        if L(r,c)==ind
            L(r,c)=0;
        end
    end
end %setting pixels to zero
figure,imshow(L);
    end
end

figure, imshow(L);
frame=getframe
writeVideo(v,frame);
end
close(v)


%% Ploting
% figure, imshow (all);
% hold on
% for i = 1:length(listIndex)
%     if (listIndex(i,4)~= 0)
%         % plot red
%         if (listIndex(i,4) == 1)
%             plot (listIndex(i,2), listIndex(i,3),'r*')
%             hold on
%         end
%         % plot green
%         if (listIndex(i,4) == 2)
%             plot (listIndex(i,2), listIndex(i,3),'g*')
%             hold on
%         end
%         % plot blue
%         if (listIndex(i,4) == 3)
%             plot (listIndex(i,2), listIndex(i,3),'b*')
%             hold on
%         end
%     end
% end




%% Compute Optical Flow Using Lucas-Kanade derivative of Gaussian
vidReader = VideoReader('supervideo_processed.avi');
% Create optical flow object.
opticFlow = opticalFlowLKDoG('NumFrames',3);
% Estimate the optical flow of the objects and display the flow vectors.
   while hasFrame(vidReader)
     frameRGB = readFrame(vidReader);
     frameGray = rgb2gray(frameRGB);

     flow = estimateFlow(opticFlow,frameGray);
%      thresh=max(flow.Magnitude(:))/2;
%      [x_loc, y_loc]=find(flow.Magnitude>thresh);
     imshow(frameRGB);
     hold on;
     plot(flow,'DecimationFactor',[5 5],'ScaleFactor',25);
     hold off;
   end