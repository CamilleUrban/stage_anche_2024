function freqvec=detection_freqvec(pmp,Fe)

pres=pmp;
pres_zero=pres-mean(pres);
pres_sq=pres_zero(1:length(pres_zero)-1).*pres_zero(2:length(pres_zero));

Neuler=find(pres_sq<0);

% figure()
% plot(pres_sq)
% hold on
% plot(Neuler,pres_sq(Neuler),'r*')
for i=1:2:length(Neuler)-2
    Nbyper(i)=Neuler(i+2)-Neuler(i);
end

enlev=find(Nbyper==0);
Nbyper(enlev)=[];

NbyperMEAN=mean(Nbyper);
freqvec=Fe/NbyperMEAN;













