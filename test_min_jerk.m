clear all,
close all,
load('minimumJerkData.mat');
% if time is not given % t = st:1/fs:tf;
% test occlusion
% insert zeros at 22 and 42
Y1(22,2:3)=0.0;
Y1(42,2:3)=0.0;
Y1(43,2:3)=0.0;
Y1(44,2:3)=0.0;
Y1(46,2:3)=0.0;
Y1(52,2:3)=0.0;
% Plot input with occlussion
figure,
subplot(2,1,1);
plot(Y1(:,1), Y1(:,2));
xlabel('time[seconds]');
ylabel('x');

subplot(2,1,2);
plot(Y1(:,1), Y1(:,3));
xlabel('time [seconds]');
ylabel('y');

% Find occlusion
count=0;
for i=2:size(Y1,1)
    if Y1(i,2)==0 && Y1(i,3)==0
        count=count+1;
        if count==1            
            sp=[Y1(i-1,2:3)];
            startI=i-1; 
        else
            count=0;
            while Y1(i+1,2)==0 && Y1(i+1,3)==0
                i=i+1;
            end
            fp=[Y1(i+1,2:3)];
            t=Y1(startI:i+1,1);
            out = min_jerk(sp, fp, t);
            Y1(startI:i+1,2:3)=out(:,1:2);
        end
    end  
end
% Plot after minimum jerk
figure,
subplot(2,1,1);
plot(Y1(:,1), Y1(:,2));
xlabel('time[seconds]');
ylabel('x');

subplot(2,1,2);
plot(Y1(:,1), Y1(:,3));
xlabel('time[seconds]');
ylabel('y');