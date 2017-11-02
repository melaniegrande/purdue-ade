function [ flag ] = CheckContact( sat_pos,station_pos,station_param )
%CheckContact Check if in range of tracking station
%   Returns true if the satellite is within transmission range as well as
%   within view of a tracking station

diffVec=[sat_pos(1)-station_pos(1),sat_pos(2)-station_pos(2),sat_pos(3)-station_pos(3)];

D=sqrt((diffVec(1))^2+(diffVec(2))^2+(diffVec(3))^2);

if(D<station_param(1))
    theta=acos(dot(diffVec,station_pos)./(norm(diffVec).*norm(station_pos)));
    if(theta<station_param(2)/2)
        flag=1;
    else
        flag=0;
    end
else
    flag=0;
end

end

