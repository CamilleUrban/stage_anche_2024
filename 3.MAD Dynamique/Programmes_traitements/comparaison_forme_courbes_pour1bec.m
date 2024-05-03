%% programme qui represente les diagrammes de bifurcation d'un seul bec normalisés à ses pressions de seuil
%% et référencés ses maximum de pressions rms ,pour plusieurs positions de lèvre. On peut comparer la forme des courbes

clear all
close all

cd .. % On va dans : programmesBec
cd resultats
cd BEC

%% On trace les courbes

figure (1);
load('beclx2_(13.5).mat')
a=plot((abs(pmpmoy))/Pseuil(1),pmprms,'b');
hold on
load('beclx2_(14).mat')
b=plot((abs(pmpmoy))/Pseuil(1),pmprms, 'r');
hold on
load('beclx2_(14.5).mat')
c=plot((abs(pmpmoy))/Pseuil(1),pmprms, 'g');
hold on
% load('beclx2_(4).mat')
% plot((abs(pmpmoy))/Pseuil(1),pmprms, 'y');
% hold on
% load('anche_automatique_becSP12rouge_(14.5).mat')
% plot((abs(pmpmoy))/Pseuil(1),pmprms/max(pmprms), 'k');
%legend([a,b,c],'14','14.2','14.5')
title('Représentation des courbes de bifurcation referencées aux pressions de seuil pour le bec SP12rouge (repetabilite)')
xlabel('Pressions moyennes dans le bec referencées aux pressions de seuil')
ylabel('Pression dans le bec rms')

figure (2);
load('beclx2_(13.5).mat')
a=plot((abs(pmpmoy)),pmprms,'b');
hold on
load('beclx2_(14).mat')
b=plot((abs(pmpmoy)),pmprms, 'r');
hold on
load('beclx2_(14.5).mat')
c=plot((abs(pmpmoy)),pmprms, 'g');
hold on
% load('beclx2_(4).mat')
% plot((abs(pmpmoy)),pmprms, 'y');
% hold on
% load('anche_automatique_becSP12rouge_(14.5).mat')
% plot((abs(pmpmoy)),pmprms, 'k');
% legend([a,b,c],'14','14.2','14.5')
title('Représentation des courbes de bifurcation pour le bec SP12rouge (repetabilite)')
xlabel('Pressions moyennes dans le bec')
ylabel('Pression dans le bec rms')

%% sauvegarde des courbes

%  saveas(1, ['bifurcations bec SP12rouge referencée_.fig'])
%  saveas(2, ['bifurcations bec SP12rouge_.fig'])