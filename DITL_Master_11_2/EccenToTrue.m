function [ TrA ] = EccenToTrue( e,EcA )
%EccenToTrue Converts from eccentric to true anomoly

%Calculate True Anomoly

EcA=double(mod(EcA,2*pi));

if(EcA<0);
    EcA=EcA+2*pi;
end

TrA=atan(sqrt((1+e)/(1-e))*tan(EcA/2));

%Quadrant Check

if(EcA/2<pi && TrA <0)
    TrA=pi+TrA;
elseif(EcA/2<pi && TrA>0)
    TrA=TrA;
elseif(EcA/2>pi && TrA<0)
    TrA=2*pi+TrA;
elseif(EcA/2>pi && TrA>0)
    TrA=pi+TrA;
else
    TrA=pi;
end

TrA=2*TrA;
    
end

