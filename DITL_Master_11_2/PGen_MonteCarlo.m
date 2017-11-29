%{
    Power Gen Monte Carlo
%}
clear; clc;
global spfail_modes
spfail_modes = [1,1,1,1];

i = 0;
p_gen = zeros(1,100000);
time_step = 60;
transparency = 0.83;
p0 = 1.9;
for i = 1:1:100000
    p_gen(i) = Power_Gen_Rev3(time_step,transparency,p0);
end
(3600/time_step)*mean(p_gen)