%% programme qui calcul certains param�tres de jeu d'un syst�me anche/bec en dynamique
% pkg load signal
clear all
close all


%t=temps
%pmp=pression dans le bec
%pm=pression acoustique près du bec

%% Initialisation

cd ..
cd donnees

% Selection du fichier de mesures � traiter
[nomfich]=uigetfile('*.*','Fichier �� lire ?');
eval(['mesures=load(''',nomfich,''');']);

% On indique les sensibilit�s des capteurs
senspmp=66.0552;
senspm=31.6;

% On indique les fichiers a utiliser pour le bruit
bruit=load('bruitanchedynamique_(3).txt');

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



Fc=10000; % frequence du filtre
fcnum=Fc/Fe*2;
Nf=2^7;

% on filtre les signaux avec un filtre lin�aire
b=fir1(Nf,fcnum,'low');
pm=filter(b,1,pm); 
pmp=filter(b,1,pmp);

cd ..
cd Programmes_traitements

env=envtemp(pm,Fe);

% selection automatique du signal

%seuil=3e-2;
%ind=find(env>=seuil);
%
%figure(10)
%plot(t,env)
%grid
%
%pmp=pmp(ind);
%pm=pm(ind);
%t=t(ind);
%
%figure(100)
%subplot(211)
%plot(t,pm)
%subplot(212)
%plot(t,pmp)
%
% on selectionne la partie du signal int�ressant
plot(t,pmp);
[tsig,psig]=ginput(2);

% indicateur des point selectionn�s
Inddebut=max(find(t<tsig(1)));
Indfin=max(find(t<tsig(2)));

% on reparam�tre nos mesures pour avoir la partie choisie de nos signauxx
t=t(Inddebut:Indfin);
pm=pm(Inddebut:Indfin);
pmp=pmp(Inddebut:Indfin);
Nsig=length(pmp);


% On met nos mesures en unite physique
pmp=pmp*senspmp; %hPa
pm=pm/senspm; %Pa


% On calcule les parametres de jeu
f0=detection_freqvec(pmp,Fe);
[fn,amp,fo]=enveloppe(pmp,Fe,f0);
[CGSmp,~] = CGS(fn,amp);

%% Calculs de l'�volution des param�tres de jeu

% on calcul le pas pour int�grer notre signal
Nper=10; % integration sur 10 periodes
Npts=round(Nper*Fe/fo);

% On initialise la taille de nos vecteurs
t2=zeros(1,167);
pmpmoy=zeros(1,167);
pmprms=zeros(1,167);
fdyn=zeros(1,167);
CGSint=zeros(1,167);
CGSext=zeros(1,167);

%On execute une boucle qui, pour chaque p�riode calcul�e ci-dessus, calcul
%diff�rents param�tres de jeu

m=1;

for k=1:Npts:floor(Nsig/Npts)*Npts
    
    % Calcul des valeurs de pression sur chaque p�riode (en dyn, moy et
    % rms)
    pmpmoy(m)=mean(pmp(k:k-1+Npts)); 
    pmpdyn=pmp(k:k-1+Npts)-pmpmoy(m);
    pmprms(m)=std(pmpdyn);
    pmdyn=pm(k:k-1+Npts)-mean(pm(k:k-1+Npts));
    
    % Calcul des param�tres de jeu sur chaque p�riode avec les valeurs de
    % pressions dynamiques
    fdyn(m)=detection_freqvec(pmpdyn,Fe);
    [f1,ampint,~]=enveloppe(pmpdyn,Fe,f0);
    [CGStemp,~] = CGS(f1,ampint);
    CGSint(m)=CGStemp/f1(1);
    [f2,ampext,~]=enveloppe(pmdyn,Fe,f0);
    [CGStemp,~] = CGS(f2,ampext);
    CGSext(m)=CGStemp/f2(1);
    
    t2(m)=t(k+round(Npts/2)); % Temps de la taille des param�tres en (m)
    m=m+1;
end



%% On trace des courbes

figure(1)
subplot(2,1,1)
plot(t,pmp)
title('Pression en fonction du temps')
xlabel('Temps (s)')
ylabel('Pression (hPa)')

subplot(2,1,2)
plot(t,pm)
title('Pression acoustique en fonction du temps')
xlabel('Temps (s)')
ylabel('Pression (Pa)')

% Detection de l'écart de fréquence par rapport à la fréquence moyenne

ecartcent=1200*log10(fdyn/f0)/log10(2);
indicent=abs(ecartcent);
ind=find(indicent<80); % ecart maximum inférieur à 90 cent
pmpmoyutile=pmpmoy(ind);
pmprmsutile=pmprms(ind);
CGSintutile=CGSint(ind);
CGSextutile=CGSext(ind);
fdynutile=fdyn(ind);
%
%figure(2)
%plot(abs(pmpmoy),indicent)
%xlabel('Pression moyenne dans le bec (hPa)')
%ylabel('Frequence (Hz)')
%legend('Frequence de jeu','Frequence moyenne estimee sur tout le signal')
%set(2, 'Units', 'Normalized', 'Position', [0 0 1 1]);
%grid

%plot(abs(pmpmoy),pmprms)
%xlabel('Pression moyenne dans le bec (hPa)')
%ylabel('Pression RMS dans le bec')
%grid

% On selectionne les pressions de seuil et de plaquage � la main sur le graphique
Pseuil=abs(pmpmoyutile(end))
Pplaquage=abs(pmpmoyutile(1))

Etendue=Pplaquage-Pseuil; % Plage de fonctionnement

figure(3)
plot(abs(pmpmoyutile),fdynutile','-o')
hold all
grid on
title('Evolution fr�quence en fonction de la pression moyenne dans le bec')
xlabel('Pression moyenne dans le bec (hPa)')
ylabel('Fr�quence (Hz)')
% On trace les limites de l'entendue
%plot([Pplaquage(1) Pplaquage(1)],[0 max(fdyn)],'r')
%plot([Pseuil(1) Pseuil(1)],[0 max(fdyn)],'r')

figure(4)
subplot(2,1,1)
plot(abs(pmpmoyutile),CGSintutile)
hold all
grid on
title('Evolution du CGS de la pression interne en fonction de la pression moyenne dans le bec')
xlabel('Pression moyenne dans le bec (hPa)')
ylabel('CGS interne')
%plot([Pplaquage(1) Pplaquage(1)],[0 max(CGSint)],'r')
%plot([Pseuil(1) Pseuil(1)],[0 max(CGSint)],'r')

subplot(2,1,2)
plot(abs(pmpmoyutile),CGSextutile)
hold all
grid on
title('Evolution du CGS de la pression externe en fonction de la pression moyenne dans le bec')
xlabel('Pression moyenne dans le bec (hPa)')
ylabel('CGS externe')
%plot([Pplaquage(1) Pplaquage(1)],[0 max(CGSext)],'r')

figure(5)
plot(abs(pmpmoyutile),pmprmsutile)
xlabel('Pression moyenne dans le bec (hPa)')
ylabel('Pression RMS dans le bec')
grid

figure(6)
plot(CGSintutile,CGSextutile,'o')
grid
xlabel('CGS interne')
ylabel('CGS externe')

cd ..
cd resultats

nomfich=nomfich(1:(length(nomfich)-4));
% sauv=[abs(pmpmoyutile)' pmprmsutile' fdynutile' CGSintutile' CGSextutile'];
savefile=[nomfich, '.mat'];
pmpmoyutile=abs(pmpmoyutile);
save(savefile, 'Pseuil', 'Pplaquage', 'pmpmoyutile', 'pmprmsutile', 'fdynutile', 'CGSintutile', 'CGSextutile')


%% Sauvegarde

%sauvegarde=input('on sauve les donn�es dans le fichier de sauvegarde ? (o/n)','s');

%if (sauvegarde=='o') || (sauvegarde=='O')
%% On sauvegarde les donn�es dans le repertoire mesures_phi en .mat

%
%% Sauvegarde des courbes en image
%%saveas(1, ['pression_mesur�es_' nom_mes '.fig'])
%%saveas(2, ['bifurcation_' nom_mes '.fig'])
%%saveas(3, ['evolution_frequence_' nom_mes '.fig'])
%saveas(4, ['evolution_CGS_' nom_mes '.fig'])
%
%% Fermeture des fenetres de graphiques
%delete(2);
%delete(1);
%delete(4);
%delete(3);
%
%else
%delete(2);
%delete(1);
%delete(4);
%delete(3);
%
%end