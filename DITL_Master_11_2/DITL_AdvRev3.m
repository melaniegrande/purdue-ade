%ADE Day in the Life Analysis

%Original Code: Benjamin Hilker
%Modifications by:
%Jason Ang
%Isaac Droll
%Melanie Grande

%Orbit in the life analysis

%This script analyzes possible paths of the ADE
%Cubesat with various apoapses and orientations
%It will attempt to simulate different power 
%phases of the mission with respect to the physical
%position of the spacecraft as well as various states
%of data and power

%Assumptions:

%Our pseudo-inertial frame for this simulation will be referenced to our
%predicted launch site.
%Only currently taking pictures at apoapsis
%We are not currently integrating any "safe mode" logic - SAFE MODE LOGIC
%IMPLEMENTED
%The angle of the umbra and penumbra used is considered to be approximately
%the same value
%Using bit rate of 9600 bps
%Initial orbital state will be considered to have a periapsis of 185 km and
%an apoapsis of 35756 km

clear variables
close all
clc

%Set Simulation Case ('Average','Min', or 'Max')
global sim_case
sim_case = 'Average';
% sim_case = 'Max';
% sim_case = 'Min';

%Set slant range case (0 = current estimates, 1 = estimates based on
%CalPoly heritage of ~3000km)
global short_slant
short_slant = 0;
%short_slant = 1;

%Constants:
DEGTORAD=pi/180;
RADTODEG=180/pi;
DAYTOSEC=24*3600;
time_step=60; %in seconds
% % Average case: 30 sec
% % Min case: 

%Power Parameters
batt_num = 2; %number of batteries at start
batt_volt = 3.7; %Volts
batt_amp_min = 2.52; %Amps
batt_max = batt_volt*batt_amp_min*batt_num;%Watt-hours
batt_init = batt_max*0.8;%Watt-hours
batt_safe = batt_max*.50;
batt_min = batt_max*.10; %Charge of battery where battery cannot be recharged
batt_eff = 0.8; %Efficiency
proc_eff = 0.97; %Production efficiency

%Solar Panel Parameters
transparency = 0.83; %Transparency of CP1
p0 = 1.5; %Solar Panel Charge rate when sunlight is perpendicular to cell

%Power States
% ADD SAFE MODE FOR FAILURE STATES
% IMU on and Transmitting
highdraw=5.61607*time_step/3600; %Watt-hours per time step
% IMU Only
imudraw=1.26957*time_step/3600; %Watt-hours per time step
% Transmit Only
transdraw=4.965977*time_step/3600; %Watt-hours per time step
% Normal Ops
normdraw=0.61947*time_step/3600; %Watt-hours per time step
% Safe Mode
safedraw=0.618678*time_step/3600; %Watt-hours per time step
safe_flag = 0;

%Failure Modes 
global spfail_modes
spfail_modes = [1,1,1,1];
% solar panels (x y -x -y)
%(1 = both panels on one side operational
%(0 = no panels on one side operational)

%Data Parameters
    %%% X PHOTOS/ORBIT * 900 KB/PHOTO + X THUMBNAILS/ORBIT * 1 KB
picDelta=(8)*1000*8; %bits, (8) thumbnails
picDelta_full = (0)*900000*8;  %bits; (0) full-size photos
cam_fmsc = (900000*8*2);  %bits, Amount of data from cameras for FMSC (2 full size images)
pull_time=20*60; %seconds,time we are pulling data around periapsis with the IMU
discComp = 0.25;  % Discretization of IMU data
imuPull = 352;  % bits/pull
imuFreq=10; %Hz (pull/sec)
imuDelta=imuPull*imuFreq*time_step; %bits, Amount of data gathered per time_step
   %%% DEFINED RADIATION PULL, DELTA
radPull=32; %bits/pull, Amount of data from radiation sensor incl. temperature MRT NOTE: INCLUDING WHAT TEMPERATURE?
radFreq=1/60; %Hz
radDelta=8*radPull*radFreq*time_step; %bits, 8 sensors
telemDelta=floor(524288 / 24 / 3600) * time_step; %bits, Amount of telemetry data gathered per time_step
bit_loss = 0.60;  % 60% estimated loss due to bad orientation, missed data, or other problems
bit_rate=9600*time_step*bit_loss;%bpm, Amount of data downlinked during time_step
% compRatio = 0.39;  % Compression Ratio 39%; Based on 'gzip' tool in Linux
compRatio = 0.345;  % Compression Ratio 34.5%; Based on 'bzip2' tool in Linux
encFactor = 0.9275;  % AX.25 encoding; Effects increase in data to be transmitted


% %IMU Cadence
% imu_initial = 2.5*24*3600/time_step; %Number consecutive of orbits where IMU data is taken immediately after deployment event
% imu_cadence = [1,0]; %After initial, cadence of imu data collection 
% %[# of passes to collect, # of orbits to wait]

%Variable Parameters:
ade_pos=zeros(1,3);%position of the ADE in EarthXYZ
ade_ellip=zeros(1,2);%position of the ADE in orbital parameters r,theta

%Pulling in files
% Allows for avg/min/max Umbra cases
if strcmp(sim_case,'Average')
    UmbraData=csvread('ADE Umbra - Average.csv',1,0);
elseif strcmp(sim_case,'Max')
    UmbraData=csvread('ADE Umbra - Max.csv',1,0);
elseif strcmp(sim_case,'Min')
    UmbraData=csvread('ADE Umbra - Min.csv',1,0);
end
% 1 JulianDateIn
% 2 JulianDateOut
% 3 Duration

if strcmp(sim_case,'Average')
    OrbitalData=csvread('ADE OrbitalParameters - Average.csv',1,0);
elseif strcmp(sim_case,'Max')
    OrbitalData=csvread('ADE OrbitalParameters - Max.csv',1,0);
elseif strcmp(sim_case,'Min')
    OrbitalData=csvread('ADE OrbitalParameters - Min.csv',1,0);
end

% 1 JulianDate
% 2 Altitude of Apoapsis
% 3 Altitude of Periapsis
% 4 ArgofPeriapsis
% 5 Eccentricity
% 6 Inclination
% 7 Period
% 8 RAAN
% 9 RadofPeriapsis
% 10 TrueAnomaly

%Output file
fid=fopen('Data.txt','w');
steps=length(OrbitalData(:,10));

%Battery failure modeling
batt_failtimes = [max(steps)+1, max(steps)+1, max(steps)+1];
batt_iter = 1;
% Battery fail times are in terms of "steps". If the value in
% batt_failtimes is > than the max value of steps, the battery will not
% fail in the mission timeline.

%Calculating initial positions and factors
Erad=OrbitalData(1,9)-OrbitalData(1,3);
period=OrbitalData(1,7);%initial orbital period
p=(OrbitalData(1,9))*(1+OrbitalData(1,5));
r=EllipOrb(p,OrbitalData(1,5),OrbitalData(1,10));%initial radius
ade_loc=[r OrbitalData(1,10)];%initial radius and true anomoly
ade_pos=DCM(OrbitalData(1,8),OrbitalData(1,4),OrbitalData(1,6),[r,0,0]);%initial xyz position

%Flags & Outputs:
[in_tmrange,run]=Ground_contact_stk(OrbitalData(1,1),OrbitalData(steps,1));
in_shadow=zeros(1,steps);
in_VAB=zeros(1,steps);
imu_on=zeros(1,steps);
rad=zeros(1,steps);
pe=zeros(1,steps);
loc=zeros(2,steps);
  % Data Initial Condition includes Checkout + Sail Deployment
beaconDelta = 228*8; %bits
dataInit = (imuDelta*discComp*compRatio + 8e3*2 + radDelta*8*compRatio + beaconDelta*compRatio)/encFactor + (imuDelta*discComp*compRatio + 8e3*14 + 2)/encFactor;  %bits
dataCount= dataInit; %bits, Running total; will go up with imu_on, down with in_tmrange on
dataProd=dataCount;
dataTrans=0;
dataStore_state=zeros(1,steps);
dataProd_state=zeros(1,steps);
dataTrans_state=zeros(1,steps);
imuTotal=0;
imu_state=zeros(1,steps);
picTotal=dataCount;
pic_state=zeros(1,steps);
radTotal=0;
rad_state=zeros(1,steps);
telemTotal=0;
telem_state=zeros(1,steps);
transfer=0;%Set if any of the stations in range
power_state=zeros(1,steps);
prev_power_state=batt_init;
positionXYZ=zeros(3,steps);
pow_draw=zeros(1,steps);
m_pass = 0; %Number of passes into mission (for IMU data collection)
orbit_number = 0; %number of orbit
shadowCount=1;
temp_pow=zeros(1,steps);
pow_hold=0;
safe_flag_vector = zeros(1,steps);

time=OrbitalData(1,1);
if(OrbitalData(1,10)<0.5 || OrbitalData(1,10)>359.5)
    orbStart=OrbitalData(1,1);
    orbStartFlag=1;
else
    orbStartFlag=0;
end
t2=0:time_step:(steps-1)*time_step;

% Cadence definition:
cadence = 1;  % Camera cadence: 1x run per X days
cad_counts = floor((OrbitalData(:,1)-OrbitalData(1,1))/cadence);
cad_shift1 = [0; cad_counts];
cad_shift2 = [cad_counts; max(cad_shift1)];
cad_starts = find(cad_shift2-cad_shift1);
cad_starts = [cad_starts; max(steps)+1];
cad_iter = 1;
picsTaken=0;%Will only take one set per orbit
camera_counter=0;%Checking to see the number of times the camera takes pictures.
orbCounter = 0;  % Number of orbits that have passed ?
skip = 1;  % Skip orbit? Y:1 N:0
imuCount = 0;
at_fmsc_rad=0; % Y:1, N:0
at_fmsc_imu=0; % Y:1, N:0


%Primary loop: Loops over all given orbit data
for X=1:steps
        %Update current state
        %Check to see if we are close to periapsis for IMU data
        if(orbStartFlag && (DAYTOSEC*(time-orbStart)<pull_time/2 || period-DAYTOSEC*(time-orbStart)<pull_time/2) && ~safe_flag)
%             % Logic turns on IMU only if it's at the beginning of an orbit?
%             % && if within +/- 1/2 pull_time on either side of periapsis
            imu_on(X)=1;
%             if (rem(orbCounter/5,1)==0)
%                 % On/Off Flip:
%                 if skip == 1
%                     skip = 0;
%                 elseif skip == 0
%                     skip = 1;
%                 end
%             end
%             % IMU draw?
%             if skip == 0    
%                 imu_on(X)=1;
%             end     
        end
        
        %Check to see if we are in the shadow
        if(shadowCount<=length(UmbraData(:,1)))
            if((UmbraData(shadowCount,3)/DAYTOSEC)+UmbraData(shadowCount,1)<time)
                shadowCount=shadowCount+1;
            elseif(UmbraData(shadowCount,1)<=time)
                in_shadow(X)=1;
            end
        end
                
        
        %   Check to see if we are close to apoapsis for pictures
        % Option A, Camera Cadence: Images for 1st 5 orbits, then only once per [1] week(s)
        % MRT Note: This flag to check near apoapsis only checks if you're
        % at a point greater than halfway through your orbit in mean
        % anomaly.  That's incorrect for an apoapsis check.  It was also
        % messing with the 2 week camera cadence.  I've commented it out
        % for now.
        %if(orbStartFlag && picsTaken==0 && DAYTOSEC*(time-orbStart)>period/2)
        if(orbStartFlag && picsTaken==0)
            picsTaken=1;  % Take only one set of photos per orbit
            dataCount=dataCount + floor((picDelta + picDelta_full)/encFactor);
            dataProd=dataProd + floor((picDelta + picDelta_full)/encFactor);
            picTotal = picTotal + floor((picDelta + picDelta_full)/encFactor);
            camera_counter=camera_counter+1;
%             % If the camera has taken less 5 photos [0:4]
%             if (camera_counter < 5)
%                 picsTaken=1;  % Take only one set of photos per orbit
%                 camera_counter=camera_counter+1;
%                 dataCount=dataCount + floor(picDelta/encFactor);
%                 dataProd=dataProd + floor(picDelta/encFactor);
%                 picTotal = picTotal + floor(picDelta/encFactor);
%             elseif X == cad_starts(cad_iter)
%                 dataCount=dataCount + floor((picDelta + picDelta_full)/encFactor);
%                 dataProd=dataProd + floor((picDelta + picDelta_full)/encFactor);
%                 picTotal = picTotal + floor((picDelta + picDelta_full)/encFactor);
%                 cad_iter=cad_iter+1;
%                 camera_counter=camera_counter+1;
%             end
        end
         
        % Option B, Camera Cadence: 5 orbits on, 5 off:
%         if(orbStartFlag && picsTaken==0 && DAYTOSEC*(time-orbStart)>period/2)
%             if skip == 0
%                 picsTaken=1;  % Take only one set of photos per orbit
%                 dataCount=dataCount + floor(picDelta/encFactor);
%                 dataProd=dataProd + floor(picDelta/encFactor);
%                 camera_counter=camera_counter+1;
%                 picTotal = picTotal + floor(picDelta/encFactor);
%             end    
%         end
        pic_state(X) = picTotal; % Running total of specifically camera data

            %%% WHOSE CADENCE WORK? NEED DISCUSSION
%         if(X<camera_off)
%             if(orbStartFlag && picsTaken==0 && DAYTOSEC*(time-orbStart)>period/2)
%                 picsTaken=1;
%                 dataCount=dataCount+picDelta;
%                 dataProd=dataProd+picDelta;
%                 camera_counter=camera_counter+1;
%             end
%         end
%         if (X<imu_initial) %Check if in the initial orbits after deployment event
%             %Update Data stored first
%             if(imu_on(X))
%                dataCount=dataCount+imuDelta;
%                dataProd=dataProd+imuDelta;
%             end
%             dataCount=dataCount+telemDelta; %Adding in telemetry data
%             dataProd=dataProd+telemDelta;
%         else %If not in initial orbits, follow IMU cadence
%             if orbit_number == 1 %If new orbit add 1 to mpass
%                 m_pass = m_pass + 1;
%                 orbit_number = 0;
%             end
%             if(imu_on(X)) && m_pass <= imu_cadence(1) %If mpass is a data pass then update data
%                dataCount=dataCount+imuDelta;
%                dataProd=dataProd+imuDelta;
%             else
%                 imu_on(X) = 0; %Set IMU off for power draw
%             end
%             dataCount=dataCount+telemDelta; %Adding in telemetry data
%             dataProd=dataProd+telemDelta;
%             if m_pass == imu_cadence(1) + imu_cadence(2) %Update m pass
%                 m_pass = 0;
%             end
%         end

        % Update data stored first
        if(imu_on(X))
           dataCount=dataCount + floor(imuDelta*compRatio*discComp/encFactor);
           dataProd=dataProd + floor(imuDelta*compRatio*discComp/encFactor);
           imuTotal = imuTotal +  floor(imuDelta*compRatio*discComp/encFactor);  % Running total of specifically IMU data
        end
        imu_state(X) = imuTotal;
        dataCount=dataCount + floor((telemDelta+radDelta)*compRatio/encFactor);
        dataProd=dataProd + floor((telemDelta+radDelta)*compRatio/encFactor);
        rad_state(X) = X * floor(radDelta*compRatio/encFactor);
        telem_state(X) = X * floor(telemDelta*compRatio/encFactor);
        if (at_fmsc_rad==0 && camera_counter == 3)
                % 3 orbits have now passed --> FMSC for Rad Sensors
                rad_state_fmsc = rad_state(X);
                fprintf('\nFMSC for Radiation Data: %.3f Mb\n', rad_state_fmsc/1000000)
                at_fmsc_rad=1;
        end

        %Downlink data if possible
        if(in_tmrange(X) && ~safe_flag && dataCount>0)
             dataCount=dataCount-bit_rate;
             if dataCount<0
                 trans = bit_rate - abs(dataCount);
                 dataCount = 0;
                 dataTrans=dataTrans + trans;
             else
                dataTrans=dataTrans+bit_rate;
             end
        end
        
        %Update Data State
        dataStore_state(X) = dataCount;
%         dataProd_state(X) = dataProd;  % Total data produced up to this time_step
        dataProd_state(X) = imu_state(X) + pic_state(X) + rad_state(X) + telem_state(X);  % Total data produced up to this time_step
        dataTrans_state(X) = dataTrans;  % Total data transmitted up to this time_step
        
        if (at_fmsc_imu==0 && camera_counter == 5)
            fprintf('FMSC for IMU: %0.3f Mb\n', imu_state(X)/1000000)
            fprintf('Total Data Produced, to date: %0.3f Mb\n', dataProd_state(X)/1000000)
            fprintf('Data Transmitted, to date: %0.3f Mb\n', dataTrans_state(X)/1000000);
            fprintf('Time: %0.2f days\n', 1+t2(X)/DAYTOSEC);
            imu_state_fmsc = imu_state(X);
            at_fmsc_imu=1;
        end

        %Update battery count
        if batt_failtimes(batt_iter) == X
            batt_num = batt_num - 1;
            batt_max = batt_volt*batt_amp_min*batt_num;
            batt_low = batt_max*.30;
            batt_min = batt_max*.10;
            if batt_iter < length(batt_failtimes)
                batt_iter = batt_iter + 1;
            end
        end
        
        %Draw Power
        pow_draw=0;
        if(~safe_flag)
            if(imu_on(X))
                if(in_tmrange(X) && dataCount>0)
                    %Highest power draw-imu on and transmitting
                    power_state(X)=prev_power_state-highdraw/proc_eff;
                    pow_draw=highdraw/proc_eff;
                else
                    %Only imu on, not transmitting
                    power_state(X)=prev_power_state-imudraw/proc_eff;
                    pow_draw=imudraw/proc_eff;
                end
            elseif(in_tmrange(X) && dataCount>0)
                %Only transmitting, no imu
                power_state(X)=prev_power_state-transdraw/proc_eff;
                pow_draw=transdraw/proc_eff;
            else
                %Normal Operations
                power_state(X)=prev_power_state-normdraw/proc_eff;
                pow_draw=normdraw/proc_eff;
            end
        elseif(safe_flag)
            power_state(X)=prev_power_state - safedraw/proc_eff;
            pow_draw=safedraw/proc_eff;
        end
        
        %Generate Power if possible
        if(in_shadow(X))
            temp_pow(X)=0;
        else
            pow_hold=Power_Gen_Rev3(time_step,transparency,p0);
            if(pow_hold-pow_draw>0)
                temp_pow(X)= proc_eff*(pow_draw+batt_eff*(pow_hold-pow_draw));
            else
                temp_pow(X)=proc_eff*pow_hold;
            end
        end
        power_state(X)=power_state(X)+temp_pow(X);
        
        %Set Battery Power State (Max)
        if(power_state(X)> batt_max)
            power_state(X)=batt_max;
        end
        if(power_state(X)<0)
            power_state(X)=0;
        end
        if(power_state(X) < batt_safe)
            % if power state low, enter safe mode
            safe_flag = 1;
        elseif(power_state(X) < batt_min)
            fprintf('\n\nPower state fell below minimum: mission end\n\n');
            break  %End sim
        end
        if(safe_flag && (power_state(X) >= batt_max*.95))
                safe_flag = 0;
        end
        safe_flag_vector(X) = safe_flag;
        %Update flags
        prev_power_state=power_state(X);
        time=OrbitalData(X,1);
        if(orbStartFlag)
            if(DAYTOSEC*time>=DAYTOSEC*orbStart+period)
                orbStart=time;
                picsTaken=0;  %Reset to zero at beginning of new orbit
                % camera_counter is a running total of times camera has been turned on
%                 orbit_number = 1;
                orbCounter = orbCounter+1; % Running total of orbits
            end
        else
           if(OrbitalData(X,10)<1 || OrbitalData(X,10)>359)
               orbStartFlag=1;
               orbStart=time;
           end
        end

        %Update Spacecraft Position
        Erad=OrbitalData(X,9)-OrbitalData(X,3);
        period=OrbitalData(X,7);%orbital period
        p=(OrbitalData(X,9))*(1+OrbitalData(X,5));
        r=EllipOrb(p,OrbitalData(X,5),OrbitalData(X,10)*DEGTORAD);%radius
        rad(X)=r;
        pe(X)=p;
        ade_loc=[r OrbitalData(X,10)*DEGTORAD];%radius and true anomoly
        loc(:,X)=transpose(ade_loc);
        ade_pos=DCM(OrbitalData(X,8)*DEGTORAD,(OrbitalData(X,4)+OrbitalData(X,10))*DEGTORAD,OrbitalData(X,6)*DEGTORAD,[r,0,0]);%xyz position
        positionXYZ(:,X)=ade_pos;

end

%Outputs
fprintf('\nOutputing data to text file\n');
% for X=1:steps
%     fprintf(fid,'%f\t%d\t%f\t%f\t%f\n',OrbitalData(X,1),in_shadow(X),pow_draw*3600/time_step,temp_pow(X)*3600/time_step,rad(X));
% end
fclose(fid);
fprintf('\nMax Data State: %.3f kB',max(dataStore_state)/8000)
fprintf('\nIMU Draw Time: %.3f min\n',pull_time/60)
fprintf('\nTotal Data Produced: %.3f kB',dataProd_state(end)/8000)
fprintf('\nTotal Data Downlinked: %.3f kB',dataTrans/8000)
fprintf('\nTotal Data Delta: %.3f kB\n\n',(dataProd_state(end)-dataTrans)/8000)
fprintf('FMSC Data Volumes:\n')
fprintf('IMU: %0.3f Mb\n',imu_state_fmsc/1e6)
fprintf('Cameras: %0.3f Mb\n',cam_fmsc/1e6)
fprintf('Rad Sensors: %0.3f Mb\n',rad_state_fmsc/1e6)
fprintf('-------------------------\n')
total_fmsc = imu_state_fmsc + cam_fmsc + rad_state_fmsc;
fprintf('Total for FMSC: %0.3f Mb\n\n', total_fmsc/1e6)

%Process information
stateData = [(1+t2/DAYTOSEC)', dataProd_state.', dataTrans_state.', dataStore_state.'];
stateFile = 'DITL_comp345_cam-1pics-8thumbs-2wk_imu-all_init9-0pics.csv';
csvwrite(stateFile,stateData)

%Big Plot
figure(1)
subplot(5,1,1)
plot(1+t2/DAYTOSEC,imu_on)
title('IMU Data Gathering','FontSize',16)
ylabel('State');
subplot(5,1,2)
stairs(1+t2/DAYTOSEC,in_shadow)
title('Satellite in Shadow','FontSize',16)
ylabel('State');
subplot(5,1,3)
plot(1+t2/DAYTOSEC,dataStore_state)
title('Data Stored','FontSize',16)
ylabel('Data (bits)')
subplot(5,1,4)
stairs(1+t2(~safe_flag_vector)/DAYTOSEC,in_tmrange(~safe_flag_vector))
title('Transmitting','FontSize',16)
ylabel('Flag')
subplot(5,1,5)
plot(1+t2/DAYTOSEC,power_state)
title('Power State','FontSize',16)
xlabel('Time (Days)')
ylabel('Energy (Watt-hours)')
% 
%Breakout Plots
figure(2)
title('Orbital Position (2D Projection)');
x=loc(1,:).*cos(loc(2,:));
y=loc(1,:).*sin(loc(2,:));
plot(x,y);
figure(3)
title('Orbital Position (J2000 Frame)')
plot3(positionXYZ(1,:),positionXYZ(2,:),positionXYZ(3,:));
xlim([-50000 50000]);
ylim([-50000 50000]);
zlim([-50000 50000]);
figure(4)
plot(1+t2/DAYTOSEC,imu_on)
title('IMU Data Gathering')
ylabel('State');
xlabel('Time (Days)')
figure(5)
plot(1+t2/DAYTOSEC,in_shadow)
title('Satellite in Shadow')
xlabel('Time (Days)')
ylabel('State');

figure(6)
plot(1+t2/DAYTOSEC,dataStore_state)
title('Data Stored')
xlabel('Time (Days)')
ylabel('Data (bits)')
grid on
set(gca,'FontSize',16)
xloc=2;
yloc=max(dataStore_state)*0.98;
text(xloc,yloc+2e6,'Note: Memory Storage Maximum is 2.56e+11 bits.','FontSize',14)

figure(7)
hold on
plot(1+t2/DAYTOSEC,dataTrans_state, 1+t2/DAYTOSEC,dataProd_state)
line([0, 1+t2(end)/DAYTOSEC], [total_fmsc, total_fmsc], 'Color','red','LineStyle','--', 'LineWidth', 0.5)
title('Total Data Transmitted Compared to Production')
xlabel('Time (Days)')
ylabel('Data (bits)')
legend('Total Data Transmitted', 'Total Data Produced','Location','northwest')
grid on
set(gca,'FontSize',16)

figure(8)
hold on
plot(1+t2/DAYTOSEC,dataProd_state)
plot(1+t2/DAYTOSEC,pic_state)
plot(1+t2/DAYTOSEC,imu_state)
plot(1+t2/DAYTOSEC,rad_state)
plot(1+t2/DAYTOSEC,telem_state)
title('Total Data Produced per Subsystem')
xlabel('Time (Days)')
ylabel('Data (bits)')
legend('Total Data Produced', 'Cameras', 'IMU', 'Radiation Sensors', 'Telemetry', 'Location','northwest')
grid on
set(gca,'FontSize',16)
hold off
fprintf('Check that the subsystems total matches total data produced:')
subsystems_sum = imu_state(X)+pic_state(X)+rad_state(X)+telem_state(X)
final_data_production_total = dataProd_state(X)

figure(9)
stairs(1+t2(~safe_flag_vector)/DAYTOSEC,in_tmrange(~safe_flag_vector))
title('Transmitting')
xlabel('Time (Days)')
ylabel('Flag')
figure(10)
plot(1+t2/DAYTOSEC,power_state,'LineWidth',1)
ylim([0,1.1*max(power_state)]);
if strcmp(sim_case,'Average')
    title('Power State - Average Deorbit Case','FontSize',20)
elseif strcmp(sim_case,'Max')
    title('Power State - Max Deorbit Case','FontSize',20)
elseif strcmp(sim_case,'Min')
    title('Power State - Min Deorbit Case','FontSize',20)
end
xlabel('Time (Days)','FontSize',20)
ylabel('Energy (Watt-hours)','FontSize',20)    
