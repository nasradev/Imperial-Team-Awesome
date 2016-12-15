% plot the trajectory in 3D 
% p is a no_points X 3 matrix-> x,y,z coord of each point
function plot_traj(p)
plot3(p(:,1),p(:,2),p(:,3));
title('Trajectory in 3D')
xlabel('X')
ylabel('Y')
zlabel('Z')
end