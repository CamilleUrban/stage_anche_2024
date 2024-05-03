

clear all
close all

cd ..
cd resultats
cd BEC

load('beclx2_faible_(14.7).mat') % lx2
pm3=pmp;
load('becSP16blanc_faible_(14.7).mat') % blanc
pm2=pmp;




load('becSP16rouge_faible_(14.7).mat') % rouge




Fe=50000;
Nper=10; % integration sur 10 periodes
Npts=round(Nper*Fe/f0);
Nsig=length(pm);

cd ..
cd ..
cd Programmes_traitements

for k=1:Npts:floor(Nsig/Npts)*Npts
pmpdyn=pmp(k:k-1+Npts)-mean(pmp(k:k-1+Npts));
[z1,f1]=enveloppepoursupperposition(pmpdyn,Fe,f0,30);
pmdyn2=pm2(k:k-1+Npts)-mean(pm2(k:k-1+Npts));
[z2,f2]=enveloppepoursupperposition(pmdyn2,Fe,f0,30);
pmdyn3=pm3(k:k-1+Npts)-mean(pm3(k:k-1+Npts));
[z3,f3]=enveloppepoursupperposition(pmdyn3,Fe,f0,30);

figure(20)
loglog(f1(1:150),z1(1:150),'-x','MarkerSize',6)
hold on
loglog(f2(1:150),z2(1:150),'-rx','MarkerSize',6)
hold on
loglog(f3(1:150),z3(1:150),'-go','MarkerSize',6)
legend('bec rouge','bec blanc','bec lx2')
axis([400 4000 1E-6 1E-1]) 
set(20, 'Units', 'Normalized', 'Position', [0 0 1 1]);
pause
close(20)



end