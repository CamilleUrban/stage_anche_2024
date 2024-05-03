clear all
close all

cd ..
cd resultats
cd BEC

rouge='anche_automatique_becSP12rouge_(14.5).mat';
blanc='anche_automatique_becSP16blanc_(14.5).mat';
lx2='anche_automatique_beclx2_(14.5).mat';

load(rouge)
Ntr=size(ampint,2);
m=10;

for i=1:Ntr
    
figure(10)

load(rouge)
loglog(f1(:,m),ampint(:,m),'-bx','MarkerSize',6)
hold on
load(blanc)
loglog(f1(:,m),ampint(:,m),'-rx','MarkerSize',6)
hold on
load(lx2)
loglog(f1(:,m),ampint(:,m),'-go','MarkerSize',6)
legend('rouge','blanc','lx2')
title('supperposition des enveloppes spectrales sur la pression interne des différents bec')
xlabel('fréquence (Hz)')
ylabel('amplitude de la pression interne')
set(10, 'Units', 'Normalized', 'Position', [0 0 1 1]);

pause
close(10)
m=m+1;
end