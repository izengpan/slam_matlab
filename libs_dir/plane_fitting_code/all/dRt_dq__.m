function dRt_dq = dRt_dq__(in1,in2)
%DRT_DQ__
%    DRT_DQ = DRT_DQ__(IN1,IN2)

%    This function was generated by the Symbolic Math Toolbox version 5.8.
%    06-Aug-2012 02:32:17

T1 = in2(1,:);
T2 = in2(2,:);
T3 = in2(3,:);
q1 = in1(1,:);
q2 = in1(2,:);
q3 = in1(3,:);
q4 = in1(4,:);
t2 = T3.*q2.*2.0;
t3 = T2.*q2.*2.0;
t4 = T3.*q1.*2.0;
t5 = T1.*q2.*2.0;
t6 = T2.*q3.*2.0;
t7 = T3.*q4.*2.0;
t8 = t5+t6+t7;
t9 = T1.*q1.*2.0;
t10 = T3.*q3.*2.0;
t16 = T2.*q4.*2.0;
t11 = t9+t10-t16;
t12 = T1.*q3.*2.0;
t13 = T2.*q1.*2.0;
t14 = T1.*q4.*2.0;
t15 = -t2+t13+t14;
dRt_dq = reshape([t11,t15,t3+t4-t12,t8,-t3-t4+t12,t15,t3+t4-T1.*q3.*2.0,t8,-t9-t10+t16,t2-T2.*q1.*2.0-T1.*q4.*2.0,t11,t8],[3, 4]);