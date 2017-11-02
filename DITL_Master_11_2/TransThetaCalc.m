function [ theta_d theta_a ] = TransOrientCalc( )
%TransThetaCalc This function calculates the true anomalies at r1 & r2

theta1_1=acos((p/rd-1)/e);
theta1_2=-1*theta1_1;
theta2_1=acos((p/ra-1)/e);
theta2_2=-1*theta2_1;

if(theta1_2<0)
    theta1_2=theta1_2+2*pi;
end
if(theta2_2<0)
    theta2_2=theta2_2+2*pi;
end

if(abs(theta2_1-theta1_1)==TA)
    theta_d=theta1_1;
    theta_a=theta2_1;
elseif(abs(theta2_2-theta1_1)==TA)
    theta_d=theta1_1;
    theta_a=theta2_2;
elseif(abs(theta2_1-theta1_2)==TA)
    theta_d=theta1_1;
    theta_a=theta2_1;
else
    theta_d=theta1_2;
    theta_a=theta2_2;
end

end

