function [ e ] = TransEccenCalc( type,a,p )
%EccenCalc Calculates Eccentricity for any trans orbit type

if(type(2)~=3)
    e=sqrt(1-p/a);
else
    e=sqrt(p/a+1);
end


end

