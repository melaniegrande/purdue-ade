function [ v ] = HyperVelRTH( r,a,mu,p,TrA )
%HyperVelRTH Outputs velocity vector for a orbiting body in r, theta, h

vmag=sqrt(2)*sqrt(mu*(1/r+1/(2*a)));
gamma=abs(acos(sqrt(mu*p)/(r*vmag)));

hold=mod(TrA,2*pi);

if(hold<0)
    hold=hold+2*pi;
end

if(hold>pi)
    gamma=-1*gamma;
end

v=[vmag*sin(gamma) vmag*cos(gamma) 0];

end