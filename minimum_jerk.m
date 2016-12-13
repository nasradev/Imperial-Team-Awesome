% clear all,
% close all,
% load('minimumJerkData.mat');
% % if time is not given % t = st:1/fs:tf;
% % test occlusion
% % insert zeros at 22 and 42
% Y1(22,2:3)=0.0;
% Y1(42,2:3)=0.0;
% Y1(43,2:3)=0.0;
% Y1(44,2:3)=0.0;
% Y1(46,2:3)=0.0;
% Y1(52,2:3)=0.0;
% Plot input with occlussion
function out=minimum_jerk(input)
out = input;
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
                input(startI:i+1,var)=out;
            end
        end
    end
end
end