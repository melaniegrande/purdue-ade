function [ EcA ] = TrueToEccen( e,TrA )
%TrueToEccen Converts from true to eccentric anomoly

%Calculate Eccentric Anomaly

TrA=mod(TrA,2*pi);

if(TrA<0);
    TrA=TrA+2*pi;
end

EcA=atan(sqrt((1-e)/(1+e))*tan(TrA/2));

%Quadrant Check

if(TrA/2<pi && EcA <0)
    EcA=pi+EcA;
elseif(TrA/2<pi && EcA>0)
    EcA=EcA;
elseif(TrA/2>pi && EcA<0)
    EcA=2*pi+EcA;
elseif(TrA/2>pi && EcA>0)
    EcA=pi+EcA;
else
    EcA=pi;
end

EcA=2*EcA;
end

