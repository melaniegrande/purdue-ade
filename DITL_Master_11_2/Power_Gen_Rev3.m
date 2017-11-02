function [ powerOut ] = Power_Gen_Rev3( timestep , transparency , p0)
%Power_Gen_Rev3 
%Randomly Derives Power
%Using a random orientation, this function derives power given that the
%system is not in shadow

% Transparency = CP1 Material transparency
% p0 = Solar Panel Generation when sunlight vector is perpendicular

% Set Variables
%Boom Length
B = 800; %mm

%Angle where the sun is going through the sail
%Calculate angle where the sunlight will go through the drag sail
%And still hit the x or y side
B_ANG = degtorad(70); %Boom angle from z axis
z_sailc = B*cos(B_ANG); %Z dimension of sail in mm
y_sailc = B*sin(B_ANG); %Y dimension of sail in mm
sail_area = 2*(y_sailc^2); %Area of the sail mm^2
boom_area = 15*y_sailc*4; %Total Boom Area mm^2
SAIL_C_ANG = atan(y_sailc/(z_sailc + 7.07)); %Center to corner of sail
SAIL_E_ANG = degtorad(56.48);

%Boom to Sail Ratio
BSR = (sail_area - boom_area)/sail_area; %Ratio of sail area to boom area

%Angle where sun is going into the top or bottom of the craft (Z+ or Z-)
% CHECK THIS NO POWER ANGLE => Sunlight from anywhere
NOPOW_ANG = degtorad(90-47); %(Tangent to side Cone)

%Angle from center of cubesat to corner of cubesat
C_ANG = degtorad(54.735);

%Generate random sunlight vector
theta1=2*pi*rand();
theta2=2*pi*rand();
theta3=2*pi*rand();

xfin=cos(theta2)*cos(theta1);
yfin=sin(theta3)*sin(theta2)*cos(theta1)+cos(theta3)*sin(theta1);
zfin=sin(theta3)*sin(theta1)-cos(theta3)*sin(theta2)*cos(theta1);

% Angles to reference axes
ang_x=acos(xfin);
ang_y=acos(yfin);
ang_z=acos(zfin);

% Display angles in degrees
% x = radtodeg(ang_x)
% y = radtodeg(ang_y)
% z = radtodeg(ang_z)

% Power for each cubesat side
p_xp = 0; %x+
p_xn = 0; %x-
p_yp = 0; %y+
p_yn = 0; %y-

% Find Power Generation

%1)Check for Z axis
%If top or bottom is locale of vector then no power generation
if ang_z < NOPOW_ANG || (180 - ang_z) < NOPOW_ANG
    powerOut = 0; 
%Sunlight hits solar panel at low enough angle of incidence that the panel does not generate power
%2)Find plane of sunlight vector and calc power
elseif ang_y <= (pi/2) || (ang_y < C_ANG && ang_x > (pi/2)) || (ang_y < C_ANG && ang_x < (3*pi/2))
    p_yp = p0*abs(cos(ang_y)); %Sunlight hits Y Positive side
    %Check which X side is hit with sunlight
    if ang_x < pi
        p_xp = p0*abs(cos(ang_x));
    else
        p_xn = p0*abs(cos(ang_x));
    end
elseif ang_x <= (pi/2)|| (ang_x < C_ANG && ang_y > (pi/2)) || (ang_x < C_ANG && ang_y < (3*pi/2))
    p_xp = p0*abs(cos(ang_x)); %Sunlight hits X Positive side
    %Check which Y side is hit with sunlight
    if ang_y < (pi/2) 
        p_yp = p_yp + p0*abs(cos(ang_y));
    else
        p_yn = p_yn + p0*abs(cos(ang_y));
    end
elseif ang_x >= (3*pi/4)|| (ang_x > (pi - C_ANG) && ang_y > (pi/2)) || (ang_x > (pi - C_ANG) && ang_y < (3*pi/2))
    p_xn = p0*abs(cos(ang_x)); %Sunlight hits X Negative Side
    %Check which Y side is hit with sunlight
    if ang_y < (pi/2) 
        p_yp = p_yp + p0*abs(cos(ang_y));
    else
        p_yn = p_yn + p0*abs(cos(ang_y));
    end
elseif ang_y >= (3*pi/4)|| (ang_y > (pi - C_ANG) && ang_x > (pi/2)) || (ang_y > (pi - C_ANG) && ang_x < (3*pi/2))
    p_yn = p0*abs(cos(ang_y)); %Sunlight hits Y Negative Side
    %Check which X side is hit with sunlight
    if ang_x < pi
        p_xp = p_xp + p0*abs(cos(ang_x));
    else
        p_xn = p_xn + p0*abs(cos(ang_x));
    end
else
    powerOut = 0;
end

%3) Evaluate Failure Modes
%Failure Modes
%LOOP TO FIND WHEN FAILURE OF A CERTAIN NUMBER OF PANELS IS MISSION FAILURE
%USE STK FOR MISSION LENGTH
global spfail_modes
fail_state = spfail_modes;
% x y -x -y
% 1 = panel working
% 0 = none working

%Multiply Power by Failure Modes
if fail_state(1) == 0
    p_xp = 0;
end
if fail_state(2) == 0
    p_yp = 0;
end
if fail_state(3) == 0
    p_xn = 0;
end
if fail_state(4) == 0
    p_yn = 0;
end
%Sum of all power generation
powerOut = p_yp + p_xp + p_xn + p_yn; %Watts
%Convert to Watt Hours
powerOut=powerOut*timestep/3600; %Watt hours

%4) Check if sunlight was through drag sail
%Set Case for sunlight through sail 
% ADD BOOM RATIO (Boom shadow area : Sail shadow area)
if ang_z > (pi-SAIL_E_ANG) && ang_z < (pi-SAIL_E_ANG)|| ang_z > (pi + SAIL_C_ANG) && ang_y > SAIL_C_ANG && ang_x > SAIL_C_ANG
    %Multiply Power by Transparency
    powerOut = powerOut*transparency*BSR; 
end


end

