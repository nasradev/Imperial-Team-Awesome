% Calc and plot velocity of motion
% dt=1/fps, dd is distance between 2 points
function v=get_vel(frameInd,dt,dd)
    v=dd/dt;
    plot(frameInd*dt,v,'o'), grid on;
end