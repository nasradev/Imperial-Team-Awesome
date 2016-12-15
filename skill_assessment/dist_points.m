function [dist]= dist_points(p1,p2)
x1=p1(1,1);
y1=p1(1,2);
x2=p2(1,1);
y2=p2(1,2);
dist=sqrt((x1-x2).^2+(y1-y2).^2);
end