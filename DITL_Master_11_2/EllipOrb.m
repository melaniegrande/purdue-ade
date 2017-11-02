function [ r ] = EllipOrb( p,e,TrA )
%EccenOrb Calculates radial distance from central body

r=p/(1+e*cos(TrA));

end

