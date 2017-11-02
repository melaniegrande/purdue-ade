function [points,r,angles] = ArcRun( p,e,TrAi,TrAf,Om,w,i )
%ArcRun Calculates points along an Arc anc converts into x,y,z

if(TrAi>TrAf)
    TrAi=TrAi-2*pi;
end
    
angles=TrAi:0.001*pi:TrAf;
n=length(angles);
points=zeros(length(angles),3);
r=zeros(length(angles),1);

for x = 1:n
    r(x,1)=EllipOrb(p,e,angles(x));
    temp=DCM(Om,w+angles(x),i,[r(x,1) 0 0]);
    points(x,1)=temp(1);
    points(x,2)=temp(2);
    points(x,3)=temp(3);
end

end

