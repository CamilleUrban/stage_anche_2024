function env=envtemp(ppav,Fe)

Nech=length(ppav);
Fc=20;
Tc=1/Fc;
M=2*round(Tc*Fe/2)+1;
fenetre=hanning(M);
norme=sum(fenetre);

decal=(M-1)/2;
envppav0=conv(fenetre,abs(ppav))/norme;
envppav=envppav0(decal:decal+Nech-1);
env=envppav/max(envppav);
%env=envppav;




