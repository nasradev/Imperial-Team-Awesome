
% p1 and p2 are row vectors x,y,z
function dist=dist_traveled(p1,p2)
dist=sqrt( ((p2(:,1)-p1(:,1)).^2) + ((p2(:,2)-p1(:,2)).^2) + ((p2(:,3)-p1(:,3)).^2) );
end