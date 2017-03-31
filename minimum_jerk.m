% clear all,
% close all,
% load('minimumJerkData.mat');
% input=Y;
% % test occlusion
% Plot input with occlussion
function output=minimum_jerk(input)
output = input;
no_vars=size(input,2)-1;
for var=2:no_vars
    
    % Find occlusion
    count=0;
    for i=2:size(input,1)
        if input(i,var)==0 
            count=count+1;
            if count==1
                sp=input(i-1,var);
                startI=i-1;
            else
                count=0;
                while input(i+1,var)==0
                    i=i+1;
                end
                fp=input(i+1,var);
                t=input(startI:i+1,1);
                out = min_jerk(sp, fp, t);
                output(startI:i+1,var)=out;
            end
        end
    end
end
end