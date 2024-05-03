clear all
close all

cd .. % On va dans : programmesBec
cd resultats
cd BEC



figure (1);
load('anche_automatique_enlevement_becrouge_(1).mat')
a=plot((abs(pmpmoy))/Pseuil(1),pmprms);
hold on
load('anche_automatique_enlevement_becrouge_(2).mat')
b=plot((abs(pmpmoy))/Pseuil(1),pmprms, 'r');
hold on
load('anche_automatique_enlevement_becrouge_(3).mat')
c=plot((abs(pmpmoy))/Pseuil(1),pmprms, 'g');
hold on
load('anche_automatique_enlevement_becrouge_(4).mat')
d=plot((abs(pmpmoy))/Pseuil(1),pmprms, 'y');
 hold on
%  load('anche_automatique_enlevement_becrouge_(5).mat')
%  e=plot((abs(pmpmoy))/Pseuil(1),pmprms, 'k');
title('Représentation des courbes de bifurcation pour 5 mesures referencées aux pressions de seuil')
xlabel('Pressions moyennes dans le bec referencées aux pressions de seuil')
ylabel('Pression dans le bec rms')

figure (2);
load('anche_automatique_enlevement_becrouge_(1).mat')
a=plot((abs(pmpmoy)),pmprms);
hold on
load('anche_automatique_enlevement_becrouge_(2).mat')
b=plot((abs(pmpmoy)),pmprms, 'r');
hold on
load('anche_automatique_enlevement_becrouge_(3).mat')
c=plot((abs(pmpmoy)),pmprms, 'g');
hold on
load('anche_automatique_enlevement_becrouge_(4).mat')
d=plot((abs(pmpmoy)),pmprms, 'y');
hold on
% load('anche_automatique_enlevement_becrouge_(5).mat')
% e=plot((abs(pmpmoy)),pmprms, 'k');
title('Représentation des courbes de bifurcation pour 5 mesures')
xlabel('Pressions moyennes dans le bec')
ylabel('Pression dans le bec rms')


saveas(1, ['bifurcation repetabilite becrouge automatique_enlevement (14.5).fig'])