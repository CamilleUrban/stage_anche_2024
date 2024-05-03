%% programme qui calcul certains param�tres de jeu d'un syst�me anche/bec en statique

clear all
close all


%t=temps
%pmp=pression dans le bec
%pm=pression acoustique pr�s du bec

%% Initialisation

cd .. % On va dans : programmesBec
cd donnees

% Selection du fichier de mesures � traiter
[nomfich]=uigetfile('*.*','Fichier � lire ?');
eval(['mesures=load(''',nomfich,''');']);

% On indique les sensibilités des capteurs
senspmp=66.0552;
senspm=31.6;

% On indique les fichiers a utiliser pour le bruit
bruit=load('beclx2_(bruit).txt');

% On calcul l'offset des deux mesures avec la moyenne du bruit
offsetpmp=mean(bruit(:,2));
offsetpm=mean(bruit(:,3));

% On affecte la ligne correspondante aux valeurs mesur�es
t=mesures(:,1);
pmp=mesures(:,2);
pm=mesures(:,3);

Fe=50000;
fs=Fe;

%% Ajustage des signaux

% On enl�ve le bruit à nos mesures
pmp=pmp-offsetpmp;
pm=pm-offsetpm;

cd .. % On va dans : programmes
cd Programmes_traitements


Fc=2000; % frequence du filtre
fcnum=Fc/Fe*2;
Nf=2^7;

% on filtre les signaux avec un filtre lin�aire
b=fir1(Nf,fcnum,'low');
pm=filter(b,1,pm); 
pmp=filter(b,1,pmp);



% On enl�ve les 100 premi�res mesures pour �viter des erreurs
pmp=pmp(100:end);
t=t(100:end);
pm=pm(100:end);
Nsig=length(pmp);

% On met nos mesures en unit� physique
pmp=pmp*senspmp; %hPa
pm=pm/senspm; %Pa


% On calcule les param�tres de jeu

f0=detection_freqvec(pmp,Fe);
[f1,amp1,~]=enveloppe(pmp,Fe,f0,30);
[CGSmp,~] = CGS(f1,amp1);
[f2,amp2,~]=enveloppe(pm,Fe,f0,30);
[CGSm,~] = CGS(f2,amp2);


%% On trace des courbes

figure(1)
subplot(3,1,1)
plot(t,pmp)
title('Pression en fonction du temps')
xlabel('Temps (s)')
ylabel('Pression (hPa)')

subplot(3,1,2)
plot(t,pm)
title('Pression acoustique en fonction du temps')
xlabel('Temps (s)')
ylabel('Pression (Pa)')



%% Sauvegarde

cd .. % On va dans : programmesBec
cd resultats


sauvegarde=input('on sauve les donn�es dans le fichier de sauvegarde ? (o/n)','s');

if (sauvegarde=='o') || (sauvegarde=='O')
% On sauvegarde les donn�es dans le repertoire mesures_phi en .mat
nom_mes=nomfich(1:(length(nomfich)-4));
num_mes=nomfich(15:(length(nomfich)-4));
savefile=[nom_mes, '.mat'];
save(savefile,'t','pm','pmp','f0', 'CGSm', 'CGSmp');

% Sauvegarde des courbes en image
saveas(1, ['pression_mesur�es_' nom_mes '.fig'])


else
    
% Fermeture des fenetres de graphiques

delete(1);


end