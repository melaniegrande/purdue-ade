function [ conn,run ] = Ground_contact_stk( startdate,enddate )
%UNTITLED2 Summary of this function goes here
%  This function is able to take data from ask and import it into our
%  matlab simulation. A couple of problems i have been having. first the excel files are not 
%all the same size. This has caused some trouble in my second loop advice
%would be nice. also there is so much data it would be nice if you could
%think of a way to check if it works. I find 1 every once in a while but if
%you know a better way than just looking through that would be cool. Also
%if you know how to make it run more effiently let me know im always trying
%to learn. Sorry if its sloppy i tried to comment as much as possible to
%make it clear happy to answer any questions. 

%launch date needs to be in a string in the format 'dd-mm-yyyy'
%or i suppose i could change start date to julian wouldnt be hard not sure
%which is better for you we can discuss tomorrow. thanks for understanding
%about not meeting today

global sim_case

% MRT Note: We should come up with a way to choose which case to use within
% this contact function.  For now it is set to Average for use in a
% presentation. Adding an argument to the function to pick the case would
% be a good idea.
Cal = csvread(['CalPolycontact - ', sim_case, '.csv'],1,0); %takes excel data calpoly
Purdue = csvread(['Purduecontact - ', sim_case, '.csv'],1,0); %takes excel data purdue
ASU = csvread(['ASUcontact - ', sim_case, '.csv'],1,0); %takes excel data
Tech = csvread(['GaTechcontact - ', sim_case, '.csv'],1,0); %takes excel data
julianseconds = (((1/24)/60)/60); %creates seconds in julian time
step = julianseconds*60; % 60 second step

jd1Cal=Cal(:,1);
jd2Cal=Cal(:,2);
jd1Pur=Purdue(:,1);
jd2Pur=Purdue(:,2);
jd1Tech=Tech(:,1);
jd2Tech=Tech(:,2);
jd1ASU=ASU(:,1);
jd2ASU=ASU(:,2);


% %%this for loop is used to make an array of julian dates of ground contact
% %the +693960 is a factor used to get the date right not sure why you need
% %it but you do
% [m,n] = size(Cal); %needed for loops
%  for a = 1:m
%      %Calpoly
%      dt1Cal = datestr(Cal(:,1)+693960,'mm dd, yyyy HH:MM:SS');
%      jd1Cal= juliandate(dt1Cal); %inital contact
%      dt2Cal = datestr(Cal(:,2)+693960,'mm dd, yyyy HH:MM:SS');
%      jd2Cal = juliandate(dt2Cal); %exiting contact
%  end
%  [m,n] = size(Purdue);
%  for a=1:m
%      %Purdue
%      dt1Pur = datestr(Purdue(:,1)+693960,'mm dd, yyyy HH:MM:SS');
%      jd1Pur= juliandate(dt1Pur); %inital contact
%      dt2Pur = datestr(Purdue(:,2)+693960,'mm dd, yyyy HH:MM:SS');
%      jd2Pur = juliandate(dt2Pur); %exiting contact
%  end
%  [m,n] = size(Tech);
%  for a=1:m
%      %Georgia Tech
%      dt1Tech = datestr(Tech(:,1)+693960,'mm dd, yyyy HH:MM:SS');
%      jd1Tech= juliandate(dt1Tech); %inital contact
%      dt2Tech = datestr(Tech(:,2)+693960,'mm dd, yyyy HH:MM:SS');
%      jd2Tech = juliandate(dt2Tech); %exiting contact
%  end
%  [m,n] = size(ASU);
%  for a=1:m
%      %ASU
%      dt1ASU = datestr(ASU(:,1)+693960,'mm dd, yyyy HH:MM:SS');
%      jd1ASU= juliandate(dt1ASU); %inital contact
%      dt2ASU = datestr(ASU(:,2)+693960,'mm dd, yyyy HH:MM:SS');
%      jd2ASU = juliandate(dt2ASU); %exiting contact
%  end

 
 %%this loop outputs a 1 or zero depending on contact
 % 1 = contact
 % 0 = no contact

 
%Flags
x = 1 ; 
%Control Flags
Calcount=1;
Purcount=1;
Techcount=1;
ASUcount=1;

Calprev=0;
Purprev=0;
Techprev=0;
ASUprev=0;

Callen=length(jd1Cal);
Purlen=length(jd1Pur);
Techlen=length(jd1Tech);
ASUlen=length(jd1ASU);

Calflag=1;
Purflag=1;
Techflag=1;
ASUflag=1;

%Test flags
Caltouch=0;
Purtouch=0;
Techtouch=0;
ASUtouch=0;

for a = startdate:step:(enddate+step)
    conn(x) = 0;
    Calconn(x)=0;
    Purconn(x)=0;
    Techconn(x)=0;
    ASUconn(x)=0;
    run(x)=a;
    
    %Calpoly
    if(Calflag) %check flags
        if(jd1Cal(Calcount)<= a && jd2Cal(Calcount)>=a)%if inbetween dates then contact 
            Calprev=1;
            conn(x) = 1;
            Calconn(x) = 1;
            Caltouch=Caltouch+1;
        else
            if(Calprev)
                Calcount=Calcount+1;
                if(Calcount>Callen)
                    Calflag=0;
                    fprintf('Last CalPoly Contact: %f %f\n',jd2Cal(Calcount-1),Calcount-1);
                end
            end
            Calprev=0;
        end
    end    
    %Purdue
    if(Purflag) %check flags
        if(jd1Pur(Purcount)<= a && jd2Pur(Purcount)>=a)%if inbetween dates then contact
            Purprev=1;
            conn(x) = 1;
            Purconn(x) = 1;
            Purtouch=Purtouch+1;
        else
            if(Purprev)
                Purcount=Purcount+1;
                if(Purcount>Purlen)
                    Purflag=0;
                    fprintf('Last Purdue Contact: %f %f\n',jd2Pur(Purcount-1),Purcount-1);
                end
            end
            Purprev=0;
        end
    end
    %Georgia Tech
    if(Techflag) %check flags
        if(jd1Tech(Techcount)<= a && jd2Tech(Techcount)>=a)%if inbetween dates then contact
            Techprev=1;
            conn(x) = 1; 
            Techconn(x) = 1;
            Techtouch=Techtouch+1;
        else
            if(Techprev)
                Techcount=Techcount+1;
                if(Techcount>Techlen)
                    Techflag=0;
                    fprintf('Last GeorgiaTech Contact: %f %f\n',jd2Tech(Techcount-1),Techcount-1);
                end
            end
            Techprev=0;
        end
    end
    %Arizona State Univeristy
    if(ASUflag) %check flags
        if(jd1ASU(ASUcount)<= a && jd2ASU(ASUcount)>=a)%if inbetween dates then contact
            ASUprev=1;
            conn(x) = 1;
            ASUconn(x) = 1;
            ASUtouch=ASUtouch+1;
        else
            if(ASUprev)
                ASUcount=ASUcount+1;
                if(ASUcount>ASUlen)
                    ASUflag=0;
                    fprintf('Last ASU Contact: %f %f\n',jd2ASU(ASUcount-1),ASUcount-1);
                end
            end
            ASUprev=0;
        end
    end
	x=x+1;
    set=1;
end

figure(12)
subplot(4,1,1)
plot(Calconn)
title('CalPoly Contacts');
subplot(4,1,2)
plot(Purconn)
title('Purdue Contacts');
subplot(4,1,3)
plot(Techconn)
title('Georgia Tech Contacts');
subplot(4,1,4)
plot(ASUconn)
title('Arizona State Contacts');

end

