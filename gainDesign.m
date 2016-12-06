%% System Definition
close all
s = tf('s');

Gol1 = 1/s^3;
Gol2 = 1/s^2;

K1 = (s + 5e-1)^2/(s + 5e0)^2;
K2 = (s + 5e-1)^1/(s + 5e0)^1;

figure(1)
subplot(2,1,1)
rlocus(K1*Gol1)
subplot(2,1,2)
rlocus(K2*Gol2)

K1 = 3e1*K1;
K2 = 9e1*K2;

Gcl1 = feedback(K1*Gol1, 1);
Gcl2 = feedback(K1*Gol2, 1);

figure(2)
subplot(2,1,1)
step(Gcl1)
subplot(2,1,2)
step(Gcl2)

K1 = K1*eye(6);
K2 = K2*eye(4);
save('K', 'K1', 'K2');