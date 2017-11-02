function [ Type ] = TypeFind( TA,r1,r2,c,TOF,mu)
%TypeFind Calculates the transfer type
%A=1,B=2,H=3
s=0.5*(r1+r2+c);

if(TA<pi)
    Num=1;
    %Calculate against TOF Parabolic
    TOFpara=(1/3)*sqrt(2/mu)*(s^1.5-(s-c)^1.5);
else
    Num=2;
    %Calculate against TOF Parabolic
    TOFpara=(1/3)*sqrt(2/mu)*(s^1.5+(s-c)^1.5);
end

if(TOF<TOFpara)
    Let=3;
else
    %Need to calculate TOFamin
    amin=s/2;
    alpha=pi;
    beta=2*asin(sqrt((s-c)/(2*amin)));
    TOFamin=sqrt((amin^3)/mu)*(alpha-beta-(sin(alpha)-sin(beta)));
    
    if(TOF<TOFamin)
        Let=1;
    else
        Let=2;
    end
end

Type=[Num Let];

end

