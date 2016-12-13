function[dist]=skill_assessment(points)
close all,
% load('3d_loop_points.mat')
% Total distance traveled
dist=0.0;
for i=1:length(points)-1
dd(i,:)= dist_traveled(points(i,:),points(i+1,:));
dist=dist + dd(i,:);
end
display(dist,'Total length of path taken');

% Plot 3D trajectory
figure, plot_traj(points), grid on;

% Calculate and plot velocity
figure, get_vel(1:length(points)-1,1/30,dd(1:length(points)-1,:));
% end

% % Points is no_points X3 matrix
% % Angle between line segment joing 2 points (on the trajectory) and each of
% % x,y and z axis
% function [angles, angle]=find_angles(points)
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
         slope(pt,i) = delta_z/delta_xy;
         angles(pt,i)=acosd(delta_z/hypo);
     end

%      slope(pt,1) = delta_z/delta_xy;
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
display(angle,'Angle between ascending and descending segments of the loop [degrees]');
figure,plot(angles(:,1))
hold on, plot(angles(:,2))
hold on, plot(angles(:,3))
xlabel('frame number')
ylabel('angle with frame axis[degrees]')
legend('x-axis','y-axis','z-axis')

% For the fake input plotting z is best to detect ascedning, decending and
% stationary parts of the trajectory
% figure, plot(slope(:,1))
% xlabel('frame number')
% ylabel('slope')
% figure, plot(slope(:,2))
% xlabel('frame number')
% ylabel('slope')
figure, plot(slope(:,3))
xlabel('frame number')
ylabel('slope')
 end

