function [ x,y,z ] = Sphere_to_Cart( radius,phi,theta )
%Sphere_to_Cart Coordinate converter
%   Converts from spherical to cartesian coordinates

    theta1=double(theta);
    phi1=double(phi);

    x=radius*sin(theta1)*sin(phi1);
    y=radius*sin(theta1)*sin(phi1);
    z=radius*cos(theta1);

end

