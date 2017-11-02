%IO Test
fid=fopen('ADE Umbra.txt','r');
UmbraData=fscanf(fid,'%f %f %f');
UmbraData=transpose(reshape(UmbraData,3,length(UmbraData)/3));
fclose(fid)
fid=fopen('OrbitalParameters.txt','r');
OrbitalData=fscanf(fid,'%f %f %f %f %f %f %f %f %f %f');
OrbitalData=transpose(reshape(OrbitalData,10,length(OrbitalData)/10));
fclose(fid)

length(OrbitalData(:,10))

