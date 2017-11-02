function [ flag ] = CheckShadow( sun_vec,sat_vec,rad,umbra_angle )
%CheckShadow Checks if satellite in Earth shadow
%   Checks if the satellite has gone into either the umbra
%   or penumbra of the Earth, returning a 1 for penumbra and
%   2 for umbra. If in neither the flag will be zero

sat_vec;
hold=dot(sun_vec,sat_vec)./(norm(sun_vec).*norm(sat_vec));
theta=acos(hold);

if(theta<pi/2)
   if(norm(sat_vec).*sin(theta)<(rad-norm(sat_vec).*sin(umbra_angle)))
       flag=2;%satellite is in the umbra
   elseif(norm(sat_vec).*sin(theta)<(rad+norm(sat_vec).*sin(umbra_angle)))
       flag=1;%Satellite is in the penumbra    
   else
       flag=0;
   end
else
    flag=0;
end

end

