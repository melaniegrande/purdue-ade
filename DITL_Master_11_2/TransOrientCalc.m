function [ i Om w theta_d theta_a ] = TransOrientCalc( TA,rd,ra,p,e,pos_1,pos_2,tol )
%TransThetaCalc This function calculates the values integrated into the DCM

%Calculating ture anomolies
theta1_1 = acos((p/rd-1)/e);
theta1_2 = -1*theta1_1;
theta2_1 = acos((p/ra-1)/e);
theta2_2 = 2*pi-1*theta2_1;

if(TA<pi)
    if(theta2_1>theta1_1)
        if(theta1_1<pi/2)%ERRORS IN THIS CASE
           if(theta2_1-theta1_2<pi)
               theta_a=theta2_1;
               if(abs((theta2_1-theta1_2)-TA)<tol)
                   theta_d=2*pi+theta1_2;
               else
                   theta_d=theta1_1;
               end
           else %theta2_1-theta1_2>=pi
               theta_d=theta1_1;
               if(abs((theta2_2-theta1_1)-TA)<tol)
                   theta_a=theta2_2;
               else
                   theta_a=theta2_1;
               end
           end
        else %theta1_1>=pi/2
            theta_d=theta1_1;
            if(abs((theta2_1-theta1_1)-TA)<tol)
                theta_a=theta2_1;
            else
                theta_a=theta2_2;
            end
        end
    else %theta2_1<=theta1_1
        if(theta1_1<pi/2)
            theta_d=2*pi+theta1_2;
            if(abs((theta2_1-theta1_2)-TA)<tol)
                theta_a=theta2_1;
            else
                theta_a=theta2_2;
            end
        else %theta1_1>=pi/2
            if(theta2_2-theta1_1<pi)
                theta_a=theta2_2;
                if(abs((theta2_2-theta1_1)-TA)<tol)
                    theta_d=theta1_1;
                else
                    theta_d=2*pi+theta1_2;
                end
            else %theta2_2-theta1_1>=pi
                theta_d=2*pi+theta1_2;
                if(abs((theta2_1+pi+theta1_2)-TA)<tol)
                    theta_a=theta2_1;
                else
                    theta_a=theta2_2;
                end
            end
        end
    end
else %TA>=pi
    if(theta1_1<pi/2)%COME BACK TO THESE CASES
        if(theta1_1<theta2_1)
            if(theta2_2-theta1_1<pi)
                theta_d=2*pi+theta1_2;
                if(abs((theta2_1-theta1_2)-TA)<tol)
                    theta_a=theta2_1;
                else
                    theta_a=theta2_2;
                end
            else %theta2_2-theta1_1>=pi
                theta_a=theta2_2;
                if(abs((theta2_2-theta1_1)-TA)<tol)
                    theta_d=theta1_1;
                else
                    theta_d=2*pi+theta1_2;
                end
            end
        else %theta1_1>=theta2_1
            theta_d=theta1_1;
            if(abs((theta2_2-theta1_1)-TA)<tol)
                theta_a=theta2_2;
            else
                theta_a=theta2_1;
            end
        end
    else %theta1_1>=pi/2
        if(theta1_1<theta2_1)
            theta_d=2*pi+theta1_2;
            if(abs((theta2_1+pi+theta1_2)-TA)<tol)
                theta_a=theta2_1;
            else
                theta_a=theta2_2;
            end
        else %theta1_1>=theta2_1
            theta_a=theta2_1;
            if(abs((2*pi+theta2_1-theta1_1)-TA)<tol)
                theta_d=theta1_1;
            else
                theta_d=2*pi+theta1_2;
            end
        end
    end
end

%Calculating DCM Parameters using r,h,omega vectors in x,y,z coordinates
%Using 3-1-3 Sequence
%Inclination first

h_hat=cross(pos_1,pos_2);
h_hat=h_hat/norm(h_hat);
i=acos(h_hat(3));

% Omega Next

r_hat=pos_1/norm(pos_1);
om_hat=cross(h_hat,r_hat);

Om1_1=asin(h_hat(1)/sin(i));
Om1_2=pi-Om1_1;
Om2_1=acos(-1*h_hat(2)/sin(i));
Om2_2=-1*Om2_1;

%Just need to compare all combinations to find the match
if(abs(Om1_1-Om2_1)<tol || abs(Om1_1-Om2_2)<tol)
    Om=Om1_1;
else
    Om=Om1_2;
end

%Finally find w using similar process to Omega

Theta1_1 = asin(r_hat(3)/sin(i));
Theta1_2 = pi-Theta1_1;
Theta2_1 = acos(om_hat(3)/sin(i));
Theta2_2 = -1*Theta2_1;

%Just need to compare all combinations to find the match
if(abs(Theta1_1-Theta2_1)<tol || abs(Theta1_1-Theta2_2)<tol)
    Theta=Theta1_1;
else
    Theta=Theta1_2;
end

w=Theta-theta_d;

end

