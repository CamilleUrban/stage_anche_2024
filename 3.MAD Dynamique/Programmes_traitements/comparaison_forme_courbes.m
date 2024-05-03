clear all
close all

%% programme qui represente les diagrammes de bifurcation de plusieurs becs normalisés à leur pression de seuil
%% et référencés à leur maximum de pression rms. On peut comparer la forme des courbes

cd .. % On va dans : programmesBec
cd resultats
cd BEC
  
%% initialisation des fichiers à lire

nom_mes=input('Quel est le numéro de la mesure ? : ','s');
lx2=['beclx2_(',nom_mes,').mat'];
rouge=['becSP16rouge_(',nom_mes,').mat'];
blanc=['becSP16blanc_(',nom_mes,').mat'];

%% On trace les diagrammes les uns sur les autres

figure;
load(lx2)
a=plot((abs(pmpmoy))/Pseuil(1),pmprms);
hold on
load(rouge)
b=plot((abs(pmpmoy))/Pseuil(1),pmprms, 'r');
hold on
load(blanc)
c=plot((abs(pmpmoy))/Pseuil(1),pmprms, 'g');
legend([a,b,c],'bec lx2','bec rouge','bec blanc')
title('Représentation des courbes de bifurcation des trois becs referencées aux pressions de seuil')
xlabel('Pressions moyennes dans le bec referencées aux pressions de seuil')
ylabel('Pression dans le bec rms')

figure (2);
load(lx2)
a=plot((abs(pmpmoy)),pmprms);
hold on
load(rouge)
b=plot((abs(pmpmoy)),pmprms, 'r');
hold on
load(blanc)
c=plot((abs(pmpmoy)),pmprms, 'g');
legend([a,b,c],'bec lx2','bec rouge','bec blanc')
title('Représentation des courbes de bifurcation des trois becs')
xlabel('Pressions moyennes dans le bec')
ylabel('Pression dans le bec rms normalisée')

%% sauvegarde des courbes

saveas(1, ['bifurcation 3 becs referencés(3eme)_' nom_mes '.fig'])
saveas(2, ['bifurcation 3 becs(3eme)_' nom_mes '.fig'])