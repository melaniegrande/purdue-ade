function [ pos_n ] = DCM( Om,w,i,pos_o)
%DCM Direction Cosine Matrix

A=[(cos(Om)*cos(w)-sin(Om)*cos(i)*sin(w)) (-cos(Om)*sin(w)-sin(Om)*cos(i)*cos(w))  sin(Om)*sin(i);
   (sin(Om)*cos(w)+cos(Om)*cos(i)*sin(w)) (-sin(Om)*sin(w)+cos(Om)*cos(i)*cos(w)) -cos(Om)*sin(i);
   (sin(i)*sin(w))                        (sin(i)*cos(w))                          cos(i)];

pos_n=transpose(A*transpose(pos_o));

end

