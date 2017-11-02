function [ a p ] = LAMBERT( type,TOF,r1,r2,c,TA,mu,tol)
%LAMBERT This function calculates the a of a transfer arc

s=0.5*(r1+r2+c);
LEFT=sqrt(mu)*TOF;


if(type(2)~= 3)
    amin=s/2;
    astep=amin;
    direction=1;
    %First Pass
    a=amin+astep*direction;
    alpha = 2*pi-(2*pi)^(2-type(2))-1*((-1)^type(2))*2*asin(sqrt(s/(2*a)));
    beta = -1*((-1)^type(1))*2*asin(sqrt((s-c)/(2*a)));
    PASS=(a^1.5)*(alpha-beta-(sin(alpha)-sin(beta)));
    %Iterating
    while(abs(LEFT-PASS)>tol)
        if(PASS<LEFT && direction==1)
            direction=-1;
            astep=astep/10;
        elseif(PASS>LEFT && direction==-1)
            direction=1;
            astep=astep/10;
        end
        a=a+direction*astep;
     
        alpha = 2*pi-(2*pi)^(2-type(2))-1*((-1)^type(2))*2*asin(sqrt(s/(2*a)));
        beta = -1*((-1)^type(1))*2*asin(sqrt((s-c)/(2*a)));
        PASS=(a^1.5)*(alpha-beta-(sin(alpha)-sin(beta)));
    end
    %Calculate p to return
    p_1 = 4*a*(s-r1)*(s-r2)*(sin((alpha+beta)/2)^2)/(c^2);
    p_2 = 4*a*(s-r1)*(s-r2)*(sin((alpha-beta)/2)^2)/(c^2);
    if(type(1)==1)
        p=max(p_1,p_2);
    else
        p=min(p_1,p_2);
    end
else
    amin=s/2;
    astep=amin;
    direction=1;
    %First Pass
    a=amin+astep*direction;
    alpha = 2*asinh(sqrt(s/(2*a)));
    beta = 2*asinh(sqrt((s-c)/(2*a)));
    PASS=(a^1.5)*((sinh(alpha)-alpha)-(sinh(beta)-beta));
    
    %Iterating
    if(type(1)==1)
        while(abs(LEFT-PASS)>tol);
            if(PASS<LEFT && direction==-1)
                direction=1;
                astep=astep/10;
            elseif(PASS>LEFT && direction==1)
                direction=-1;
                astep=astep/10;
            end
            a=a+direction*astep;
            
            alpha = 2*asinh(sqrt(s/(2*a)));
            beta = 2*asinh(sqrt((s-c)/(2*a)));
            PASS=(a^1.5)*((sinh(alpha)-alpha)-(sinh(beta)-beta));
        end
    else
        while(abs(LEFT-PASS)>tol)
            if(PASS>LEFT && direction==-1)
                direction=-1;
                astep=astep/10;
            elseif(PASS<LEFT && direction==1)
                direction=1;
                astep=astep/10;
            end
            a=a+direction*astep;
            
            a=0.5*(amax+amin);
            alpha = 2*asinh(sqrt(s/(2*a)));
            beta = 2*asinh(sqrt((s-c)/(2*a)));
            PASS=(a^1.5)*((sinh(alpha)-alpha)+(sinh(beta)-beta));
        end
    end
    p_1 = 4*a*(s-r1)*(s-r2)*(sinh((alpha+beta)/2)^2)/(c^2);
    p_2 = 4*a*(s-r1)*(s-r2)*(sinh((alpha-beta)/2)^2)/(c^2);
    if(type(1)==1)
        p=max(p_1,p_2);
    else
        p=min(p_1,p_2);
    end
end

end

