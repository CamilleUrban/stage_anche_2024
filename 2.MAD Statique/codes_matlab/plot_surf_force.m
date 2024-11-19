## tracer la surface surf_c en fonction de la force
## ensuite on va essayer de faire un modèle paramétrique

clear all
close all
pkg load image
pkg load signal

##for R= 1:3
##  load(['mes_2024.03.22/A{R}.mat']);
##  F = load(['mes_2024.03.22/force_A{R}.txt'], '-ascii');
##end

surf_c1 = load('mes_2024.03.22/A1.mat').surf_c ;
F1 = load('mes_2024.03.22/force_A1.txt', '-ascii');
F1 = (F1()-F1(1))/(39.2)

##surf_c2 = load('mes_2024.03.22/A2.mat').surf_c ;
##F2 = load('mes_2024.03.22/force_A2.txt', '-ascii');
##
##surf_c3 = load('mes_2024.03.22/A3.mat').surf_c ;
##F3 = load('mes_2024.03.22/force_A3.txt', '-ascii');

figure(1)
set(gca,'FontSize', 15)
hold on
grid on
plot(F1,surf_c1, '*-', 'linewidth',1.8)
[paramopt, erreuropt] = identification_modele(F1, surf_c1)
##plot(F2,surf_c2, '*-', 'linewidth',1.8)
##plot(F3,surf_c3, '*-', 'linewidth',1.8)
axis([0 8 -2 13]);
xlabel('Force (mV)');
ylabel('Surface (mm²)');
title(sprintf('Surface du canal d''anche en fonction de la force d''appui \n de la lèvre articielle'));
legend('Force 1')
##legend('Force 1', 'Force 3', 'Force 5');

