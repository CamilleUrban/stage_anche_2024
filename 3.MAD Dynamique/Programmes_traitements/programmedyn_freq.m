%% programme qui calcul certains paramètres de jeu d'un système anche/bec en dynamique

clear all
close all


%t=temps
%pmp=pression dans le bec
%pm=pression acoustique prÃ¨s du bec

%% Initialisation

cd .. % On va dans : programmesBec
cd donnees

% Selection du fichier de mesures à traiter
[nomfich]=uigetfile('*.*','Fichier à  lire ?');
eval(['mesures=load(''',nomfich,''');']);

% On indique les sensibilités des capteurs
senspmp=66.0552;
senspm=31.6;

% On indique les fichiers a utiliser pour le bruit
bruit=load('bruitanchedynamique_(3).txt');

% On calcul l'offset des deux mesures avec la moyenne du bruit
offsetpmp=mean(bruit(:,2));
offsetpm=mean(bruit(:,3));

% On affecte la ligne correspondante aux valeurs mesurées
t=mesures(:,1);
pmp=mesures(:,2);
pm=mesures(:,3);

Fe=50000;
fs=Fe;

%% Ajustage des signaux

% On enlève le bruit Ã  nos mesures
pmp=pmp-offsetpmp;
pm=pm-offsetpm;

cd .. % On va dans : programmes
cd Programmes_traitements


Fc=10000; % frequence du filtre
fcnum=Fc/Fe*2;
Nf=2^7;

% on filtre les signaux avec un filtre linéaire
b=fir1(Nf,fcnum,'low');
pm=filter(b,1,pm); 
pmp=filter(b,1,pmp);

% on selectionne la partie du signal intéressant
plot(t,pmp)
[tsig,psig]=ginput(2);

% indicateur des point selectionnés
Inddebut=max(find(t<tsig(1)));
Indfin=max(find(t<tsig(2)));

% on reparamètre nos mesures pour avoir la partie choisie de nos signauxx
t=t(Inddebut:Indfin);
pm=pm(Inddebut:Indfin);
pmp=pmp(Inddebut:Indfin);
Nsig=length(pmp);


% On met nos mesures en unité physique
pmp=pmp*senspmp; %hPa
pm=pm/senspm; %Pa


% On calcule les paramètres de jeu
f0=detection_freqvec(pmp,Fe);
[fn,amp,fo]=enveloppe(pmp,Fe,f0);
[CGSmp,~] = CGS(fn,amp);

%% Calculs de l'évolution des paramètres de jeu

% on calcul le pas pour intégrer notre signal
Nper=5; % integration sur 10 periodes
Npts=round(Nper*Fe/fo);

% On initialise la taille de nos vecteurs
t2=zeros(1,167);
pmpmoy=zeros(1,167);
pmprms=zeros(1,167);
fdyn=zeros(1,167);
CGSint=zeros(1,167);
CGSext=zeros(1,167);

%On execute une boucle qui, pour chaque période calculée ci-dessus, calcul
%différents paramètres de jeu

m=1;

for k=1:Npts:floor(Nsig/Npts)*Npts
    
    % Calcul des valeurs de pression sur chaque période (en dyn, moy et
    % rms)
    pmpmoy(m)=mean(pmp(k:k-1+Npts)); 
    pmpdyn=pmp(k:k-1+Npts)-pmpmoy(m);
    pmprms(m)=std(pmpdyn);
    pmdyn=pm(k:k-1+Npts)-mean(pm(k:k-1+Npts));
    
    % Calcul des paramètres de jeu sur chaque période avec les valeurs de
    % pressions dynamiques
    fdyn(m)=detection_freqvec(pmpdyn,Fe);
    [f1,ampint,~]=enveloppe(pmpdyn,Fe,f0);
    [CGStemp,~] = CGS(f1,ampint);
    CGSint(m)=CGStemp/f1(1);
    [f2,ampext,~]=enveloppe(pmdyn,Fe,f0);
    [CGStemp,~] = CGS(f2,ampext);
    CGSext(m)=CGStemp/f2(1);
    
    t2(m)=t(k+round(Npts/2)); % Temps de la taille des paramètres en (m)
    m=m+1;
end



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


figure(2)
% plot(abs(pmpmoy),pmprms)
plot(abs(pmpmoy),pmprms/max(pmprms))
title('Diagramme de bifurcation')
xlabel('Pression moyenne dans le bec (hPa)')
ylabel('Pression rms en sortie du bec (Pa)')
set(2, 'Units', 'Normalized', 'Position', [0 0 1 1]);
hold all
plot(abs(pmpmoy),2e-2*ones(size(pmpmoy)),'r')
grid



figure(3)
plot(abs(pmpmoy),fdyn)
hold all
grid on
title('Evolution fréquence en fonction de la pression moyenne dans le bec')
xlabel('Pression moyenne dans le bec (hPa)')
ylabel('Fréquence (Hz)')

% On selectionne les pressions de seuil et de plaquage à la main sur le graphique
Pseuil=ginput(1) 
Pplaquage=ginput(1);

Etendue=Pplaquage(1)-Pseuil(1) % Plage de fonctionnement

figure(4)
subplot(3,1,1)
plot(abs(pmpmoy),CGSint)
hold all
grid on
title('Evolution du CGS de la pression interne en fonction de la pression moyenne dans le bec')
xlabel('Pression moyenne dans le bec (hPa)')
ylabel('CGS interne')
plot([Pplaquage(1) Pplaquage(1)],[0 max(CGSint)],'r')
plot([Pseuil(1) Pseuil(1)],[0 max(CGSint)],'r')

subplot(3,1,2)
plot(abs(pmpmoy),CGSext)
hold all
grid on
title('Evolution du CGS de la pression externe en fonction de la pression moyenne dans le bec')
xlabel('Pression moyenne dans le bec (hPa)')
ylabel('CGS externe')
plot([Pplaquage(1) Pplaquage(1)],[0 max(CGSext)],'r')
plot([Pseuil(1) Pseuil(1)],[0 max(CGSext)],'r')


%% Sauvegarde

cd .. % On va dans : programmesBec
cd resultats
cd dynamique_3anches


sauvegarde=input('on sauve les données dans le fichier de sauvegarde ? (o/n)','s');

if (sauvegarde=='o') || (sauvegarde=='O')
% On sauvegarde les données dans le repertoire mesures_phi en .mat
nom_mes=nomfich(1:(length(nomfich)-4));
num_mes=nomfich(15:(length(nomfich)-4));
savefile=[nom_mes, '.mat'];
save(savefile,'t','pm','pmp','f0', 'Pseuil', 'Pplaquage', 'Etendue');

% Sauvegarde des courbes en image
%saveas(1, ['pression_mesurées_' nom_mes '.fig'])
%saveas(2, ['bifurcation_' nom_mes '.fig'])
%saveas(3, ['evolution_frequence_' nom_mes '.fig'])
saveas(4, ['evolution_CGS_' nom_mes '.fig'])

% Fermeture des fenetres de graphiques
delete(2);
delete(1);
delete(4);
delete(3);

else
delete(2);
delete(1);
delete(4);
delete(3);

end