% Fonction tattack
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Role de la fonction 
% Calcule les temps de debut et fin de l'attaque d'un signal musical
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Grandeurs d'entree
% Fe : frequence d'echantillonnage
% env : enveloppe du signal a analyser
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Grandeurs de sortie
% temps début et fin de l'enveloppe d'un signal
% duree d'attaque d'un son base sur la derivee seconde de l'enveloppe : PAS UTILISE

function temps=attack(Fe,env);

Nech=length(env); % nombre d'echantillons de l'enveloppe
t=1/Fe:1/Fe:Nech/Fe; % tableau des temps

%-------------------- calcul du temps de montee par recherche des passages à 10% et 90% -----

nd=max(find(env<0.1));
nf=min(find(env>0.9));
tf=t(nf);
td=t(nd);
temps=[td,tf];

figure(5)
%plot(t,env,td,env(nd),'o','markersize',20,tf,env(nf),'o','markersize',20)
plot(t,env,td,env(nd))
xlabel('Time (s)')
ylabel('Pressure signal enveloppe')
pause(3)

%figure(1)


% ---------- calcul du temps de montee par recherche des min et max de la derivee seconde ---

%% Calcul de la derivee seconde de l'enveloppe
%deriv=[-Fe^2 2*Fe^2 -Fe^2]; % filtre derivateur (derivee seconde)
%envppavderiv=conv(deriv,env); % convolution entre le filtre et l'enveloppe => derivee seconde de l'enveloppe
%critere=envppavderiv(3:Nech); % la derivee seconde est normalement calculee pour les echantillons 2 a Nech + 1. On supprime un echantillon au debut et a la fin pour eviter des amplitudes trop importantes.
%Nc=length(critere); % nombre d'echantillons du critere

%%Filtrage passe bas de la derivee seconde
%Fc=20; % Frequence de coupure
%Tc=1/Fc; % duree du filtre passe bas
%M=2*round(Tc*Fe/2)+1; % nombre d'echantillons du filtre passe bas (nombre impair : 2N+1)

%k=1:M; % indices k pour calcul de la fenetre ci dessous
%fenetre=0.5*(1-cos((2*pi*k)/(M-1))); % fenetre de Hanning
%norme=sum(fenetre); % somme des coefficients de la fenetre

%decal=(M-1)/2; % decalage temporel du au filtrage passe bas
%crit0=conv(fenetre,critere)/norme; % convolution entre le critere (derivee seconde de l'enveloppe) et le filtre passe bas
%critere=crit0(decal:decal+Nc-1); % recalage temporel de la derivee seconde filtree passe bas

%indmin=find(critere==min(critere)); % recherche du minimum de la derivee seconde => debut
%indmax=find(critere==max(critere)); % recherche du maximum de la derivee seconde => fin

%if indmin>indmax
%indmin=1;
%end

%t2=t(indmax)-t(indmin); % calcul du temps d'attaque

%tattack=[t1;t2];
%tattack=t1;

%figure(3)
%plot(t(3:Nech),critere,t(indmin),critere(indmin),t(indmax),critere(indmax));
%pause(1)



