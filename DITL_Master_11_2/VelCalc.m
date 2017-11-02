function [ v ] = VelCalc( type,r,a,mu,p,TrA )
%VelCalc Decides which velocity function to use then calculates

if(type(2)~=3)
    v=EllipVelRTH(r,a,mu,p,TrA);
else
    v=HyperVelRTH(r,a,mu,p,TrA);
end

end

