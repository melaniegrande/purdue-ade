function [ P ] = TransPeriod( type,a,mu )
%TransPeriod Calculates the period of the transfer orbit if possible

if(type(2) ~= 3)
    P=2*pi*sqrt((a^3)/mu);
else
    P=-1;
end

end

