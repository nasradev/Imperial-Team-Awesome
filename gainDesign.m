%% System Definition
close all
s = tf('s');

Gol = 1/s^3;
K1 = (s + 5e-1)^2/(s + 5e0)^2;

figure(1)
rlocus(K1*Gol)

K2 = 3e1*K1;
K = K2*eye(6);
K_1 = K2*eye(4);

Gcl = feedback(K2*Gol, 1);

figure(2)
step(Gcl)

save('K', 'K', 'K_1');