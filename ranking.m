function [avScore]=ranking(mu,sigma,points)
[~,velocity,~,dist]=skill_assessment(points,1);
time=1*length(points);
x=[velocity; dist;time];
score(1)  = (1/sqrt((2*pi))./sigma(1))*exp(-0.5*((x(1)-mu(1)).^2)/(sigma(1).^2));
score(2)  = (1/sqrt((2*pi))./sigma(2))*exp(-0.5*((x(2)-mu(2)).^2)/(sigma(2).^2));
score(3)  = (1/sqrt((2*pi))./sigma(3))*exp(-0.5*((x(3)-mu(3)).^2)/(sigma(3).^2));
avScore=mean(score);
end