function [ ENom ] = KeplerSolver( Einit,M,e,tol )
%KeplerSolver Solves the position of a body based on mean anomoly and
%eccentricity

%First Pass
Eo=double(Einit-(Einit-e*sin(Einit)-M)/(1-e*cos(Einit)));
En=double(Eo-(Eo-e*sin(Eo)-M)/(1-e*cos(Eo)));

%Continues iterating until E does not vary significantly
while(abs(Eo-En)>tol)
    Eo=En;
    En=double(Eo-(Eo-e*sin(Eo)-M)/(1-e*cos(Eo)));
end
    
    ENom=En;
end

