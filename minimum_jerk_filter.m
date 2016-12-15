D = 1/30;

A = [0 1 0;
    0 0 1;
    -60/D^3 -36/D^2 -9/D];

B = [0;
    0;
    60/D^3];

C = [1 0 0];

sys = ss(A, B, C, []);

isstable(sys);

figure
bode(sys)