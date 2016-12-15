%function [angles, angle]=find_angles(points)
% load('3d_loop_points')
pt = 1;
asc_slope = 0.0;
desc_slope = 0.0;
asc_count = 0;
desc_count = 0;
slope = zeros(length(points)-1,1);
angles = zeros(length(points)-1,1);
while pt<=length(points)-1
    p1 = points(pt,:);
    p2 = points(pt+1,:);
    hypo = dist_traveled(p1,p2);
    
    delta_y = p2(:,2)-p1(:,2);
    delta_xz = sqrt((hypo^2) - (delta_y^2));
    slope(pt) = delta_y/delta_xz;
    angles(pt) = acosd(delta_y/hypo);
    
    slope(pt) = delta_y/delta_xz;
    if floor(slope(pt))>0
        %label(pt,1)=1; %it is ascending
        asc_count=asc_count+1;
        asc_slope=slope(pt,1)+asc_slope;
    elseif ceil(slope(pt))<0
        %label(pt,1)=3; %it is descending
        desc_count=desc_count+1;
        desc_slope=slope(pt)+desc_slope;
    else
        %label(pt,1)=2; %it is stationary
    end
    pt = pt+1;
end
% calculate angle between asecnding and descending segment of the loop
asc_slope = asc_slope/asc_count;
desc_slope = desc_slope/desc_count;
angle = abs(atand((asc_slope-desc_slope)/(1+(asc_slope*desc_slope))));
%end