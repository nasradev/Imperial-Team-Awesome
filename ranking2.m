function [avScore]=ranking2(mu,sigma,Rpoints,Lpoints)
[~,Rvelocity,~,Rdist]=skill_assessment(Rpoints,1);
[~,Lvelocity,~,Ldist]=skill_assessment(Lpoints,1);
Rtime=1*length(Rpoints);
x=[mean([Rvelocity, Lvelocity]);mean([ Rdist, Ldist]);mean(Rtime)];
score(1)  = (1/sqrt((2*pi))./sigma(1))*exp(-0.5*((x(1)-mu(1)).^2)/(sigma(1).^2));
score(2)  = (1/sqrt((2*pi))./sigma(2))*exp(-0.5*((x(2)-mu(2)).^2)/(sigma(2).^2));
score(3)  = (1/sqrt((2*pi))./sigma(3))*exp(-0.5*((x(3)-mu(3)).^2)/(sigma(3).^2));
avScore=mean(score);
end