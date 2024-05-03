close all
clear all

cd .. % On va dans : programmesBec
cd resultats
cd BEC

fichier1='becP5bleu-comparaison_13.9(1).mat';
fichier2='becP5bleu-comparaison_13.9(2).mat';
fichier3='becILbleu-comparaison_13.(2).mat';


load(fichier1);
Ntr=size(CGSint,2);
mok=3;

for i=1:1:Ntr
    
figure(1)

load(fichier1)
loglog([170 340],[CGSoint(1,mok) CGSoint(1,mok)],'b','MarkerSize',20)
hold on
load(fichier2)
loglog([170 340],[CGSoint(1,mok) CGSoint(1,mok)],'r','MarkerSize',20)
hold on
load(fichier3)
loglog([170 340],[CGSoint(1,mok) CGSoint(1,mok)],'g','MarkerSize',20)
legend('blanc','rouge','lx2','location','EastOutside')
hold on
load(fichier1)
loglog(340:1:680,CGSoint(2,mok),'b','MarkerSize',20)
hold on
load(fichier2)
loglog(340:1:680,CGSoint(2,mok),'r','MarkerSize',20)
hold on
load(fichier3)
loglog(340:1:680,CGSoint(2,mok),'g','MarkerSize',20)
hold on
load(fichier1)
loglog(680:1:1360,CGSoint(3,mok),'b','MarkerSize',20)
hold on
load(fichier2)
loglog(680:1:1360,CGSoint(3,mok),'r','MarkerSize',20)
hold on
load(fichier3)
loglog(680:1:1360,CGSoint(3,mok),'g','MarkerSize',20)
hold on
load(fichier1)
loglog(1360:1:2720,CGSoint(4,mok),'b','MarkerSize',20)
hold on
load(fichier2)
loglog(1360:1:2720,CGSoint(4,mok),'r','MarkerSize',20)
hold on
load(fichier3)
loglog(1360:1:2720,CGSoint(4,mok),'g','MarkerSize',20)
hold on
load(fichier1)
loglog(2720:1:5440,CGSoint(5,mok),'b','MarkerSize',20)
hold on
load(fichier2)
loglog(2720:1:5440,CGSoint(5,mok),'r','MarkerSize',20)
hold on
load(fichier3)
loglog(2720:1:5440,CGSoint(5,mok),'g','MarkerSize',20)

ymax=CGSoint(5)+5;
axis([170 5440 1 ymax]) 
title('Représentation des CGSint par octave des 3 becs')
xlabel('fréquence (Hz)')
ylabel('CGS sur la pression dans le bec')
set(1, 'Units', 'Normalized', 'Position', [0 0 1 1]);
pause
mok=mok+1;
close(1)
end