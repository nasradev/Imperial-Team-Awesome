function [] = assessment2tools(points1, points2, time)
% points1 is a row vector with the 3D positions of tool 1
% points2 is a row vector with the 3D positions of tool 2

close all,
expertDist = 23000; %[mm]
expertTime = 30; %[s]

%%%%%%%%%%
% Tool 1 %
%%%%%%%%%%
dist1 = 0.0;
for i = 1:length(points1)-1
    dd1(i,:) = dist_traveled(points1(i,:),points1(i+1,:));
    dist1 = dist1 + dd1(i,:);
end
display(dist1,'Total length of path taken');

markDist1 = expertDist * 100/dist1;

% Compute the expertise
mark1 = round(markDist1);

%%%%%%%%%%
% Tool 2 %
%%%%%%%%%%
dist2 = 0.0;
for i = 1:length(points2)-1
    dd2(i,:) = dist_traveled(points2(i,:), points2(i+1,:));
    dist2 = dist2 + dd2(i,:);
end
markDist1 = expertDist * 100/dist1;

% Compute the expertise
mark1 = round(markDist1);

%%%%%%%%%%%%%
% Give result
%%%%%%%%%%%%%
success = 0;

mark = (mark1 + mark2)/2;
if mark > 50
    success = 1;
end

[cdata,map] = imread('success.png');
if success
    h = msgbox({sprintf('Your mark is: %d /100',mark) ...
        sprintf('Time required: %f',time)}, ...
        'Congratulations','custom',cdata,map);
end

[cdata2,map2] = imread('fail.png');
if ~success
    h = msgbox({sprintf('Your mark is: %d /100',mark) ...
        sprintf('Time required: %f seconds',time)}, ...
        'Congratulations','custom',cdata2,map2);
end
end
