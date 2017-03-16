function J = Jac2(a,k,m0,m1,s,x)
%JAC2
%    J = JAC2(A,K11,K12,K13,K21,K22,K23,M0X,M1X,M0Y,M1Y,S1,S2,S3,S4,X1,X3,X5)

%    This function was generated by the Symbolic Math Toolbox version 7.0.
%    13-Dec-2016 20:34:46

x1 = x(1);
x3 = x(3);
x5 = x(5);

s1 = s(1);
s2 = s(2);
s3 = s(3);
s4 = s(4);

m0x = m0(1);
m1x = m1(1);
m0y = m0(2);
m1y = m1(2);

k11 = k(1,1);
k12 = k(1,2);
k13 = k(1,3);
k21 = k(2,1);
k22 = k(2,2);
k23 = k(2,3);

t2 = sin(s1);
t3 = cos(s1);
t4 = cos(a);
t5 = m0y.*t3;
t6 = m0x.*t2;
t19 = s3.*t3;
t7 = t5+t6-t19;
t8 = sin(a);
t9 = m0x.*t3;
t10 = s3.*t2;
t17 = m0y.*t2;
t11 = t9+t10-t17;
t12 = sin(x1);
t13 = sin(x5);
t14 = cos(x1);
t15 = cos(x5);
t16 = sin(x3);
t18 = t4.*t11;
t20 = t7.*t8;
t21 = t18+t20;
t22 = t4.*t7;
t24 = t8.*t11;
t23 = t22-t24;
t25 = cos(x3);
t26 = t2.*t8;
t27 = t3.*t4;
t28 = t26+t27;
t29 = t12.*t15;
t42 = t13.*t14.*t16;
t30 = t29-t42;
t31 = t2.*t4;
t39 = t3.*t8;
t32 = t31-t39;
t33 = t12.*t13;
t34 = t14.*t15.*t16;
t35 = t33+t34;
t36 = t14.*t15;
t37 = t12.*t13.*t16;
t38 = t36+t37;
t40 = t13.*t14;
t47 = t12.*t15.*t16;
t41 = t40-t47;
t43 = t21.*t30;
t44 = t23.*t35;
t45 = t43+t44;
t46 = t21.*t38;
t48 = t23.*t41;
t49 = t46+t48;
t50 = t13.*t21.*t25;
t51 = t13.*t25.*t28;
t71 = t15.*t25.*t32;
t52 = t51-t71;
t53 = t28.*t30;
t54 = t32.*t35;
t55 = t53+t54;
t56 = t28.*t38;
t57 = t32.*t41;
t58 = t56+t57;
t59 = m1y.*t3;
t60 = m1x.*t2;
t61 = -t19+t59+t60;
t62 = m1x.*t3;
t64 = m1y.*t2;
t63 = t10+t62-t64;
t65 = t4.*t63;
t66 = t8.*t61;
t67 = t65+t66;
t68 = t4.*t61;
t70 = t8.*t63;
t69 = t68-t70;
t72 = k11.*t55;
t96 = k13.*t52;
t97 = k12.*t58;
t73 = t72-t96-t97;
t74 = t30.*t67;
t75 = t35.*t69;
t76 = t74+t75;
t77 = t38.*t67;
t78 = t41.*t69;
t79 = t77+t78;
t80 = t13.*t25.*t67;
t81 = k21.*t55;
t112 = k23.*t52;
t113 = k22.*t58;
t82 = t81-t112-t113;
t83 = k12.*t49;
t108 = t15.*t23.*t25;
t84 = k13.*(t50-t108);
t85 = t83+t84-k11.*t45;
t86 = t15.*t25.*t28;
t87 = t13.*t25.*t32;
t88 = t86+t87;
t89 = t30.*t32;
t98 = t28.*t35;
t90 = t89-t98;
t91 = k11.*t90;
t92 = t28.*t41;
t99 = t32.*t38;
t93 = t92-t99;
t94 = k12.*t93;
t114 = k13.*t88;
t95 = t91+t94-t114;
t100 = t23.*t30;
t101 = t100-t21.*t35;
t102 = t23.*t38;
t103 = t15.*t21.*t25;
t104 = t13.*t23.*t25;
t105 = t103+t104;
t106 = t102-t21.*t41;
t107 = k22.*t49;
t109 = k21.*t90;
t110 = k22.*t93;
t118 = k23.*t88;
t111 = t109+t110-t118;
t115 = k12.*t79;
t127 = t15.*t25.*t69;
t116 = k13.*(t80-t127);
t117 = t115+t116-k11.*t76;
t119 = t30.*t69;
t120 = t119-t35.*t67;
t121 = t38.*t69;
t122 = t15.*t25.*t67;
t123 = t13.*t25.*t69;
t124 = t122+t123;
t125 = t121-t41.*t67;
t126 = k22.*t79;
J = reshape([t85,t107-k21.*t45+k23.*(t50-t15.*t23.*t25),t117,t126-k21.*t76+k23.*(t80-t15.*t25.*t69),-s4.*t95-s2.*(-k11.*t101+k12.*t106+k13.*t105),-s4.*t111-s2.*(-k21.*t101+k22.*t106+k23.*t105),-s4.*t95-s2.*(-k11.*t120+k12.*t125+k13.*t124),-s4.*t111-s2.*(-k21.*t120+k22.*t125+k23.*t124),0.0,0.0,0.0,0.0,t85,t107-k21.*t45+k23.*(t50-t108),t117,t126-k21.*t76+k23.*(t80-t127),t73,t82,t73,t82,-s2.*t95,-s2.*t111,-s2.*t95,-s2.*t111,0.0,0.0,0.0,0.0,t73,t82,t73,t82],[8,4]);
