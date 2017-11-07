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
%We are not currently integrating any "safe mode" logic
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
sim_case = 'Max';

%Constants:
DEGTORAD=pi/180;
RADTODEG=180/pi;
DAYTOSEC=24*3600;
time_step=60; %in seconds
% % Average case: 30 sec
% % Min case: 

%Power Parameters
batt_num = 3; %number of batteries at start
batt_volt = 3.7; %Volts
batt_amp_min = 2.52; %Amps
batt_init = 10;%Watt-hours
batt_max = batt_volt*batt_amp_min*batt_num;%Watt-hours
batt_min = batt_max*.30; %Charge of battery where battery cannot be recharged
batt_eff = 0.8; %Efficiency
proc_eff = 0.97; %Production efficiency

%Solar Panel Parameters
transparency = 0.83; %Transparency of CP1
p0 = 1.5; %Solar Panel Charge rate when sunlight is perpendicular to cell

%Power States
% ADD SAFE MODE FOR FAILURE STATES
highdraw=5.2160*time_step/3600; %Watt-hours per time step
imudraw=0.8695*time_step/3600; %Watt-hours per time step
transdraw=4.96597*time_step/3600; %Watt-hours per time step
normdraw=0.61947*time_step/3600; %Watt-hours per time step

%Failure Modes 
global spfail_modes
spfail_modes = [1,1,1,1];
% solar panels (x y -x -y)
%(1 = both panels on one side operational
%(0 = no panels on one side operational)

%Data Parameters
    %%% X PHOTOS/ORBIT * 900 KB/PHOTO + X THUMBNAILS/ORBIT * 1 KB
picDelta=1*900000*8+8*1000*8; %bits,Amount of data we are gathering from each apoapsis picture sessionimuPull =352; %bits/pull,Amount of data we are gathering per data pull (Max Case)
cam_fmsc = (900000*8*2);  %bits, Amount of data from cameras for FMSC (2 full size images)
pull_time=20*60; %seconds,time we are pulling data around periapsis with the IMU
imuPull = 352;  % bits/pull
imuFreq=10; %Hz (pull/sec)
imuDelta=imuPull*imuFreq*time_step; %bits, Amount of data gathered per time_step
   %%% DEFINED RADIATION PULL, DELTA
radPull=64; %bits/pull, Amount of data from radiation sensor incl. temperature
radFreq=1; %Hz
radDelta=radPull*radFreq*time_step; %bits, 8 sensors
telemDelta=floor(524288 / 24 / 3600) * time_step; %bits, Amount of telemetry data gathered per time_step
bit_loss = 0.60;
bit_rate=9600*time_step*bit_loss;%bpm, Amount of data downlinked during time_step
   %%% ADD COMPRESSION AND ENCODING
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
   %%% DATACOUNT IS DEFINED BY THE INITIAL [10] IMAGES AT START OF SIM
   %%% SINCE ONLY IMAGES, ALREADY COMPRESSED, ADD ONLY ENCODING
dataCount= floor((9*900000*8+9*1000*8) / encFactor); %Goes up with imu_on, down with in_tmrange on
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

time=OrbitalData(1,1);
if(OrbitalData(1,10)<0.5 || OrbitalData(1,10)>359.5)
    orbStart=OrbitalData(1,1);
    orbStartFlag=1;
else
    orbStartFlag=0;
end
t2=0:time_step:(steps-1)*time_step;

    %%% ADD CADENCES
% Cadence definition:
cadence = 7 * (2);  % Camera cadence: 1x per [X] weeks
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
        if(orbStartFlag && (DAYTOSEC*(time-orbStart)<pull_time/2 || period+DAYTOSEC*(orbStart-time)<pull_time/2))
            % Logic turns on IMU only once when approaching periapsis and only
            % for 20 mins??
            % imu_on(X)=1;
            %%% ADD IMU CADENCE
            if (rem(orbCounter/5,1)==0)
                % On/Off Flip:
                if skip == 1
                    skip = 0;
                elseif skip == 0
                    skip = 1;
                end
            end
            % IMU draw?
            if skip == 0    
                imu_on(X)=1;
            end     
        end
        
        %Check to see if we are in the shadow
        if(shadowCount<=length(UmbraData(:,1)))
            if((UmbraData(shadowCount,3)/DAYTOSEC)+UmbraData(shadowCount,1)<time)
                shadowCount=shadowCount+1;
            elseif(UmbraData(shadowCount,1)<=time)
                in_shadow(X)=1;
            end
        end
                
        
        %Check to see if we are close to apoapsis for pictures
        % Option A, Cadence: Images for 1st 5 orbits, then only once per [2] week(s)
        if(orbStartFlag && picsTaken==0 && DAYTOSEC*(time-orbStart)>period/2)
            if (camera_counter <= 5)
                fprintf('X: %d',X)
                picsTaken=1  % Take only one set of photos per orbit
                camera_counter=camera_counter+1
                dataCount=dataCount + floor(picDelta/encFactor);
                dataProd=dataProd + floor(picDelta/encFactor);
                picTotal = picTotal + floor(picDelta/encFactor);
    %         elseif (camera_counter == 5)
    %             fprintf('\nFMSC for IMU (1st 5 orbits)\n')
    %             fprintf('Data Produced: %0.0f Mb\n', dataProd/1e6)
    %             fprintf('Data Transmitted, to date: %0.0f Mb\n', dataCount/1e6);
    %             fprintf('Time: %f days\n', 1+t2(X)/DAYTOSEC);
    %             camera_counter=camera_counter+1
            elseif X == cad_starts(cad_iter)
                dataCount=dataCount + floor(picDelta/encFactor);
                dataProd=dataProd + floor(picDelta/encFactor);
                picTotal = picTotal + floor(picDelta/encFactor);
                cad_iter=cad_iter+1;
                camera_counter=camera_counter+1;
            end
        end
        pic_state(X) = picTotal; % Running total of specifically camera data
        % Option B, Cadence: 5 orbits on, 5 off:
%         if(orbStartFlag && picsTaken==0 && DAYTOSEC*(time-orbStart)>period/2)
%             if skip == 0
%                 picsTaken=1;  % Take only one set of photos per orbit
%                 dataCount=dataCount + floor(picDelta/encFactor);
%                 dataProd=dataProd + floor(picDelta/encFactor);
%                 camera_counter=camera_counter+1;
%             end    
%         end

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
           %%% ADD COMPRESSION AND ENCODING TO IMU
           dataCount=dataCount + floor(imuDelta*compRatio/encFactor);
           dataProd=dataProd + floor(imuDelta*compRatio/encFactor);
           imuTotal = imuTotal + floor(imuDelta*compRatio/encFactor);  % Running total of specifically IMU datae
        end
        imu_state(X) = imuTotal;
        if (at_fmsc_imu==0 && camera_counter == 5)
            fprintf('\nFMSC for IMU (1st 5 orbits)\n')
            fprintf('Data Produced by IMU: %0.0f Mb\n', imu_state(X)/1e6)
            fprintf('Total Data Produced: %0.0f Mb\n', dataProd/1e6)
            fprintf('Data Transmitted, to date: %0.0f Mb\n', imu_state(X)/1e6);
            fprintf('Time: %f days\n', 1+t2(X)/DAYTOSEC);
            imu_state_fmsc = imu_state(X);
            at_fmsc_imu=1;
        end
        %%% ADD COMPRESSION AND ENCODING TO TELEMETRY AND RADIATION
        dataCount=dataCount + floor((telemDelta+radDelta)*compRatio/encFactor);
        dataProd=dataProd + floor((telemDelta+radDelta)*compRatio/encFactor);
        %%% is 'steps' (X) the number of minutes that have passed???
        rad_state(X) = X * floor(radDelta*compRatio/encFactor);
        telem_state(X) = X * floor(telemDelta*compRatio/encFactor);
        if (at_fmsc_rad==0 && camera_counter == 3)
                % 3 orbits have now passed --> FMSC for Rad Sensors
                rad_state_fmsc = rad_state(X);
                fprintf('FMSC Radiation Data: %0.0f bits\n', rad_state_fmsc)
                at_fmsc_rad=1;
        end

        %Downlink data if possible
        if(in_tmrange(X))
             dataCount=dataCount-bit_rate;
             dataTrans=dataTrans+bit_rate;
        end
        if(dataCount<0)
            dataCount=0;
        end
        
        %Update Data State
        dataStore_state(X) = dataCount;
        dataProd_state(X) = dataProd;  % Total data produced up to this time_step
        dataTrans_state(X) = dataTrans;  % Total data transmitted up to this time_step

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
        if(power_state(X) < batt_min)
            break  %End sim
        end
        
        %Update flags
        prev_power_state=power_state(X);
        time=OrbitalData(X,1);
        if(orbStartFlag)
            if(DAYTOSEC*time>=DAYTOSEC*orbStart+period)
                orbStart=time;
                picsTaken=0;  %Reset to zero at beginning of new orbit
                % camera_counter is a running total of times camera has been turned on
                orbit_number = 1;
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
fprintf('\nMax Data State: %f kB',max(dataStore_state)/8000)
fprintf('\nIMU Draw Time: %f min\n',pull_time/60)
fprintf('\nTotal Data Produced: %f kB',dataProd/8000)
fprintf('\nTotal Data Downlinked: %f kB',dataTrans/8000)
fprintf('\nTotal Data Delta: %f kB\n\n',(dataProd-dataTrans)/8000)
fprintf('FMSC Data Volumes:\n')
fprintf('IMU: %0.3f Mb\n',imu_state_fmsc/1e6)
fprintf('Cameras: %0.3f Mb\n',cam_fmsc/1e6)
fprintf('Rad Sensors: %0.3f Mb\n',rad_state_fmsc/1e6)
fprintf('-------------------------\n')
total_fmsc = imu_state_fmsc + cam_fmsc + rad_state_fmsc;
fprintf('Total for FMSC: %0.3f Mb\n\n', total_fmsc/1e6)

%Process information
stateData = [(1+t2/DAYTOSEC)', dataProd_state.', dataTrans_state.', dataStore_state.'];
stateFile = 'DITL_comp345_cadence-1pics-8thumbs-2wk_imu-5on5off_init22.csv';
csvwrite(stateFile,stateData)

% %Big Plot
figure(1)
subplot(5,1,1)
plot(1+t2/DAYTOSEC,imu_on)
title('IMU Data Gathering')
ylabel('State');
subplot(5,1,2)
plot(1+t2/DAYTOSEC,in_shadow)
title('Satellite in Shadow')
ylabel('State');
subplot(5,1,3)
plot(1+t2/DAYTOSEC,dataStore_state)
title('Data Stored')
ylabel('Data (bits)')
subplot(5,1,4)
plot(1+t2/DAYTOSEC,in_tmrange)
title('Transmitting')
ylabel('Flag')
subplot(5,1,5)
plot(1+t2/DAYTOSEC,power_state)
title('Power State')
xlabel('Time (Days)')
ylabel('Energy (Watt-hours)')

% %Breakout Plots
% figure(2)
% title('Orbital Position (2D Projection)');
% x=loc(1,:).*cos(loc(2,:));
% y=loc(1,:).*sin(loc(2,:));
% plot(x,y);
% figure(3)
% title('Orbital Position (J2000 Frame)')
% plot3(positionXYZ(1,:),positionXYZ(2,:),positionXYZ(3,:));
% xlim([-50000 50000]);
% ylim([-50000 50000]);
% zlim([-50000 50000]);
% figure(4)
% plot(1+t2/DAYTOSEC,imu_on)
% title('IMU Data Gathering')
% ylabel('State');
% xlabel('Time (Days)')
% figure(5)
% plot(1+t2/DAYTOSEC,in_shadow)
% title('Satellite in Shadow')
% xlabel('Time (Days)')
% ylabel('State');

   %%%  COMPARE DATA STATE TO MEMORY MAX, AND DATA TRANSMITTED TO DATA PRODUCED
figure(6)
plot(1+t2/DAYTOSEC,dataStore_state)
title('Data Stored')
xlabel('Time (Days)')
ylabel('Data (bits)')
grid on
set(gca,'FontSize',16)
xloc=2;
yloc=max(dataStore_state)*0.98;
text(xloc,yloc,'Note: Memory Storage Maximum is 2.56e+11 bits.','FontSize',14)
figure(7)
plot(1+t2/DAYTOSEC,dataTrans_state, 1+t2/DAYTOSEC,dataProd_state)
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
fprintf('DO THE TOTALS MATCH?')
total = imu_state(X)+pic_state(X)+rad_state(X)+telem_state(X)
final_data_production_total = dataProd_state(X)

% figure(9)
% plot(1+t2/DAYTOSEC,in_tmrange)
% title('Transmitting')
% xlabel('Time (Days)')
% ylabel('Flag')
% figure(10)
% plot(1+t2/DAYTOSEC,power_state,'LineWidth',2)
% ylim([0,1.1*max(power_state)]);
% if strcmp(sim_case,'Average')
%     title('Power State - Average Deorbit Case','FontSize',20)
% elseif strcmp(sim_case,'Max')
%     title('Power State - Max Deorbit Case','FontSize',20)
% elseif strcmp(sim_case,'Min')
%     title('Power State - Min Deorbit Case','FontSize',20)
% end
% xlabel('Time (Days)','FontSize',20)
% ylabel('Energy (Watt-hours)','FontSize',20)    
