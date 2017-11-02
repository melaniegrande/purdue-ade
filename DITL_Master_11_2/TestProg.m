%Benjamin Hilker

%Just testing functions
tol=0.0001;
Einit=pi/2;
dtr = pi/180;
rtd = 180/pi;
a_e = 149597927.0; 
M_e = dtr*-58.0848626;
e_e = 0.016712542; 
i_e = dtr*0.001051926; 
Om_e = dtr*0.0;
om_e = dtr*102.914377;
p_e = a_e*(1-e_e*e_e);
Epoch = 2448566.5;
enc_e = 2443376.000000;
enc_j = 2444064.000000;
mu_sun = 132712200000.00;
daytosec=24*3600;
calcTol=5*sqrt(132712200000.00);

EcA_e=KeplerSolver(Einit,M_e,e_e,tol);
TrA_e=EccenToTrue(e_e,EcA_e);
pos_e_i = [EccenOrb(p_e,e_e,TrA_e) 0 0];
pos_e_i = DCM(Om_e,om_e+TrA_e,i_e,pos_e_i);
