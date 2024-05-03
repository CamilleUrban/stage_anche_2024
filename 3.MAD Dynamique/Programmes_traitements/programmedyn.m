%% programme qui calcul certains paramètres de jeu d'un système anche/bec en dynamique

clear all
close all



%t=temps
%pmp=pression dans le bec
%pm=pression acoustique près du bec

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
bruit=load('bec1L_objectifs_proche_bruit(1).txt');

% On calcul l'offset des deux mesures avec la moyenne du bruit
offsetpmp=mean(bruit(:,2));
offsetpm=mean(bruit(:,3));

% On affecte la ligne correspondante aux valeurs mesurées
t=mesures(:,1);
pmp=mesures(:,2);
pm=mesures(:,3);

Fe=50000;
fs=Fe;

 %%  Ajustage des signaux

% On enlève le bruit Ã  nos mesures
pmp=pmp-offsetpmp;
pm=pm-offsetpm;

cd .. % On va dans : programmes
cd Programmes_traitements


Fc=1000; % frequence du filtre 1000
fcnum=Fc/Fe*2;
Nf=2^7;

% on filtre les signaux avec un filtre linéaire
b=fir1(Nf,fcnum,'low'); 
pmp=filter(b,1,pmp);

Fc=10000; % frequence du filtre 10000
fcnum=Fc/Fe*2;
b=fir1(Nf,fcnum,'low');
pm=filter(b,1,pm); 



% % on selectionne la partie du signal int?ressant
% plot(t,pmp)
% [tsig,psig]=ginput(2);
%  
% % indicateur des point selectionn?s
% Inddebut=max(find(t<tsig(1)));
% Indfin=max(find(t<tsig(2)));
%  
% % on reparam?tre nos mesures pour avoir la partie choisie de nos signauxx
% t=t(Inddebut:Indfin);
% pm=pm(Inddebut:Indfin);
% pmp=pmp(Inddebut:Indfin);
% % Nsig=length(pmp);


% on selectionne la partie du signal intéressant
[b,a] = butter(2, 2*[150/50000 190/50000]); % on filtre le signal dans une bande passante autour de f0
essai = filter(b,a, pmp);
figure(6); plot(t,pmp)
y=find(abs(essai)<0.004); % on met à 0 le signal filtré qui ne dépasse pas le seuil
essai(y)=0;
essai(1:10000)=zeros([1,10000]); % On enlève les premières mesures trop bruitées
a=find(abs(essai)>0); % on cherche le premier indice qui équivault au début du signal de fréquence f0 et d'amplitude supérieur au seuil
if std(essai(a(end)-30000:a(end)))<5E-4 % on enlève les bruits de fréquence comprisent dans le filtre
    essai=essai(1:a(end)-30000);
end
c=find(abs(essai)>0);
t=t(a(1):c(end)); % on redimensionne nos variables avec les indices trouvés précédement
pmp=pmp(a(1):c(end));
figure(7);
plot(t,pmp)
pm=pm(a(1):c(end));



Nsig=length(pmp);


% On met nos mesures en unité physique
pmp=pmp*senspmp; %hPa
pm=pm/senspm; %Pa


% On calcule les paramètres de jeu
%f0=detection_freqvec(pmp,Fe);
f0=170;
Nh=10;

 [fn,amp,~]=enveloppe(pmp,Fe,f0,Nh);
% [CGSmp,~] = CGS(fn,amp);
f0=fn(1);

%% Calculs de l'évolution des paramètres de jeu

% on calcul le pas pour intégrer notre signal
Nper=10; % integration sur 10 periodes
Npts=round(Nper*Fe/f0);



%On execute une boucle qui, pour chaque période calculée ci-dessus, calcul
%différents paramètres de jeu

m=1;
mok=1;

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
    Ffa=174,61;
    ecartcent(m)=abs(1200*log2(fdyn(m)/Ffa)); %fréquence d'un Fa dans la 2ème gamme tempérée
    
    Nhint=9;
    [f1(:,m),ampint(:,m),RSBint]=enveloppe(pmpdyn,Fe,f0,Nhint);
%     disp(['RSBint = ',num2str(RSBint)]);
    
%     Nhext=ceil(Fc/f0);
    Nhext=40;
    [f2(:,m),ampext(:,m),RSBext]=enveloppe(pmdyn,Fe,f0,Nhext);
    
    if (RSBint>14 || (0<RSBint && RSBint<1))
%     if (RSBint>6)
    [CGStemp,~] = CGS(f1,ampint);
    CGSint(mok)=CGStemp/f1(1);
    
    fjeu(mok)=fdyn(m);
%     ecartcent(mok)=abs(1200*log2(fjeu(mok)/f0));
    
    [CGStemp,~] = CGS(f2,ampext);
    CGSext(mok)=CGStemp/f2(1);
   
    pmpmoy1(mok)=pmpmoy(m);
    
    CGSoint(:,mok)=CGSparoctave(ampint,f1)/f0;
    CGSoext(:,mok)=CGSparoctave(ampext,f2)/f0;
%     envlspecint=evlspectrale(ampint,f1);
    mok=mok+1;
%     [B,A]=octdsgn(31.5,Fe,3);
%     Y=filter(B,A,pmpdyn);
%     [f11,ampint1,~]=enveloppe(Y,Fe,f0,Nhint);
%     CGS1=CGS(f11,ampint1);

    
    end
    
    
    t2(m)=t(k+round(Npts/2)); % Temps de la taille des paramètres en (m)
    m=m+1;
end

CGSextmoy=mean(CGSext);
CGSintmoy=mean(CGSint);

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


figure('units','normalized','outerposition',[0 0 1 1]);
% plot(abs(pmpmoy),pmprms)
plot(abs(pmpmoy),pmprms/max(pmprms))
title('Diagramme de bifurcation')
xlabel('Pression moyenne dans le bec (hPa)')
ylabel('Pression rms en sortie du bec (Pa)')
hold all
plot(abs(pmpmoy),2e-2*ones(size(pmpmoy)),'r')
grid

% On selectionne les pressions de seuil et de plaquage à la main sur le graphique
Pseuil=ginput(1); 
Pplaquage=ginput(1);
% Pseuil=12;
% Pplaquage=54;
% Pmilieu=(Pplaquage(1)+Pseuil(1))/2;
% pmprmsmilieu=pmprms(find(abs(pmpmoy) <= Pmilieu,1));
pmprmsmilieu=max(pmprms);
pmprmsdB=20*log10(pmprmsmilieu/2E-7);

Etendue=(Pseuil(1)/Pplaquage(1))*100; % Plage de fonctionnement

%%
figure;

plot(abs(pmpmoy1),fjeu)
title('Evolution fréquence de jeu en fonction de la pression moyenne dans le bec')
xlabel('Pression moyenne dans le bec (hPa)')
ylabel('Fréquence (Hz)')


figure;

plot(CGSint,CGSext,'o-')
title('Evolution du CGS esterne en fonction du CGS interne')
xlabel('CGS interne')
ylabel('CGS externe')


figure;

subplot(3,1,1)
plot(abs(pmpmoy1),CGSint)
title('Evolution du CGS de la pression interne en fonction de la pression moyenne dans le bec')
xlabel('Pression moyenne dans le bec (hPa)')
ylabel('CGS interne')

subplot(3,1,2)
plot(abs(pmpmoy1),CGSext)
title('Evolution du CGS de la pression externe en fonction de la pression moyenne dans le bec')
xlabel('Pression moyenne dans le bec (hPa)')
ylabel('CGS externe')

% figure(3)
% plot(abs(pmpmoy),fdyn)
% hold all
% grid on
% title('Evolution fréquence en fonction de la pression moyenne dans le bec')
% xlabel('Pression moyenne dans le bec (hPa)')
% ylabel('Fréquence (Hz)')
% % On trace les limites de l'entendue
% plot([Pplaquage(1) Pplaquage(1)],[0 max(fdyn)],'r')
% plot([Pseuil(1) Pseuil(1)],[0 max(fdyn)],'r')
% 
% figure(4)
% subplot(3,1,1)
% plot(abs(pmpmoy),CGSint)
% hold all
% grid on
% title('Evolution du CGS de la pression interne en fonction de la pression moyenne dans le bec')
% xlabel('Pression moyenne dans le bec (hPa)')
% ylabel('CGS interne')
% plot([Pplaquage(1) Pplaquage(1)],[0 max(CGSint)],'r')
% plot([Pseuil(1) Pseuil(1)],[0 max(CGSint)],'r')
% [p1,p2]=ginput(2);
% CGSintmoy=mean(CGSint(find(abs(pmpmoy) <= p1(2),1):find(abs(pmpmoy) <= p1(1),1)));
% 
% figure;
% plot(abs(pmpmoy),CGSint)
% hold on
% stem(p1(1), p2(1));
% 
% subplot(3,1,2)
% plot(abs(pmpmoy),CGSext)
% hold all
% grid on
% title('Evolution du CGS de la pression externe en fonction de la pression moyenne dans le bec')
% xlabel('Pression moyenne dans le bec (hPa)')
% ylabel('CGS externe')
% plot([Pplaquage(1) Pplaquage(1)],[0 max(CGSext)],'r')
% plot([Pseuil(1) Pseuil(1)],[0 max(CGSext)],'r')
% [p3,p4]=ginput(2);
% CGSextmoy=mean(CGSext(find(abs(pmpmoy) <= p3(2),1):find(abs(pmpmoy) <= p3(1),1)));
% 
% 
 %% Sauvegarde
% 
 cd .. % On va dans : programmesBec
 cd resultats
 cd BEC
% 
% 
%  sauvegarde=input('on sauve les données dans le fichier de sauvegarde ? (o/n)','s');
% 
% if (sauvegarde=='o') || (sauvegarde=='O')
% % On sauvegarde les données dans le repertoire mesures_phi en .mat
nom_mes=nomfich(1:(length(nomfich)-4));
num_mes=nomfich(15:(length(nomfich)-4));
savefile=[nom_mes, '.mat'];
save(savefile,'t','pmp','pm','pmpmoy','pmprms','f0', 'Pseuil','pmpmoy1', 'Pplaquage','pmpdyn','pmdyn','fjeu','CGSint','CGSext','f1','ampint','f2','ampext','CGSoint','CGSoext','ecartcent');
% pause
% close all
% Sauvegarde des courbes en image
%saveas(1, ['pression_mesurées_' nom_mes '.fig'])
%saveas(2, ['bifurcation_' nom_mes '.fig'])
%saveas(3, ['evolution_frequence_' nom_mes '.fig'])
% saveas(4, ['evolution_CGS_' nom_mes '.fig'])

% Fermeture des fenetres de graphiques
% delete(2);
% delete(1);
% delete(4);
% delete(3);
% 
% else
% delete(2);
% delete(1);
% delete(4);
% delete(3);
% 
% end