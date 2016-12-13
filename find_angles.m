%function [angles, angle]=find_angles(points)
load('3d_loop_points')
pt=1;
asc_slope=0.0;
desc_slope=0.0;
asc_count=0;
desc_count=0;
while pt<=length(points)-1
    p1=points(pt,:);
    p2=points(pt+1,:);
    hypo = dist_traveled(p1,p2);
    
    for i =1:3 %x->1 y->2 z->3
        delta_z = p2(:,i)-p1(:,i);
        delta_xy = sqrt((hypo^2) - (delta_z^2));
        slope(:,i) = delta_z/delta_xy;
        angles(pt,i)=acosd(delta_z/hypo);
    end
    
    slope(pt,1) = delta_z/delta_xy;
    if floor(slope(pt,1))>0
        %label(pt,1)=1; %it is ascending
        asc_count=asc_count+1;
        asc_slope=slope(pt,1)+asc_slope;
    elseif ceil(slope(pt,1))<0
        %label(pt,1)=3; %it is descending
        desc_count=desc_count+1;
        desc_slope=slope(pt,1)+desc_slope;
    else
        %label(pt,1)=2; %it is stationary
    end
    pt=pt+1;
end
% calculate angle between asecnding and descending segment of the loop
asc_slope=asc_slope/asc_count;
desc_slope=desc_slope/desc_count;
angle=abs(atand((asc_slope-desc_slope)/(1+(asc_slope*desc_slope))));
%end

