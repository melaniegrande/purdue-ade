function [ P ] = PeriodCalc(a,mu )
%PeriodCalc Calculates the period of the transfer orbit if possible

    P=2*pi*sqrt((a^3)/mu);

end

