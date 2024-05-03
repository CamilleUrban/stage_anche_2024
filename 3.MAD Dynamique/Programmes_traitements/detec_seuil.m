%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Role de la fonction
% Detection d'un signal par depassement d'un seuil
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Grandeurs d'entree
% t : tableau des temps
% env : signal à detecter (enveloppe d'un signal)
% seuil : valeur du seuil
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Grandeurs de sortie
% td : temps de debut des evenements
% tf : temps de fin des evenements
% erreur : si 0 pas d'erreur,  si 1 erreur de detection
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function [td tf erreur]=detec_seuil(t,env,seuil)

detect=zeros(size(t)); % 

indmax=find(env>seuil); % recherche des indices pour lesquels l'enveloppe est superieure au seuil
indmax=indmax'; % transposition du tableau des indices

Nmax=length(indmax); % Nombre d'echantillons du tableau indmax

% initialisation des parametres
m=1; % m : compte le nombre d'evenements detectes
td(1)=min(t(indmax)); % premier valeur du temps debut

% boucle pour reperer les positions des evenements detectes

for k=1:Nmax-1
if indmax(k+1)-indmax(k)>1 % si on a un saut d'indice on passe d'un evenement a un autre
tf(m)=t(indmax(k)); % calcul du temps de fin de l'evenement m
m=m+1; % increment pour passer a l'evenement suivant
td(m)=t(indmax(k+1)); % calcul du temps de debut de l'evenement suivant
end
end
tf(m)=max(t(indmax)); % calcul du temps de fin du dernier evenement

Nnotes=length(td); % calcul du nombre d'evenements detectes

if Nnotes ~= 7 % si le nombre d'evenements detectes est different de 7 alors erreur
erreur=1;
else
erreur=0;
end

%td2=zeros(1,Nnotes);
%tf2=zeros(1,Nnotes);
%td2(1)=min(t);
%tf2(Nnotes)=max(t);

%for k=2:Nnotes,
%tf2(k-1)=(td(k)+tf(k-1))/2*0.9;
%td2(k)=(td(k)+tf(k-1))/2*1.1;
%end

detect(indmax)=ones(size(t(indmax)))*0.5;

figure(2)
plot(t,env,'-',t,detect)
xlabel('time (s)','fontsize', 20)
ylabel('Enveloppe','fontsize', 20)
%title('Enveloppe temporelle et detection')
legend('Enveloppe','Detection')

%test=input('detection correcte (o/n)?','s');


disp('Notes detectees :')
Nnotes

if erreur == 1
Nnotesfaux=input('Nombre de notes a supprimer')
for k=1:Nnotesfaux
td2=[];
tf2=[];
nfaux=input('Numero de note a supprimer');
td2(1:nfaux-1)=td(1:nfaux-1);
tf2(1:nfaux-1)=tf(1:nfaux-1);
td2(nfaux:Nnotes-1)=td(nfaux+1:Nnotes);
tf2(nfaux:Nnotes-1)=tf(nfaux+1:Nnotes);

clear td
clear tf

disp('nouveaux temps estimes')
td=td2;
tf=tf2;
Nnotes=length(td)
pause(2)

indmax=[];
indok=[];

for m=1:Nnotes
indok=find(t>=td(m) & t<=tf(m));
indmax=[indmax indok];
end

detect=zeros(size(t)); % 
detect(indmax)=ones(size(t(indmax)))*0.5;

figure(10)
plot(t,env,'-',t,detect)
xlabel('temps (s)')
ylabel('Enveloppe')
title('Enveloppe temporelle et detection')
legend('enveloppe','Detection')


end
erreur=0;
end

%if erreur==1
%pause(2)
%%N=input('Nombre de silence à detecter manuellement')
%N=7;
%disp('Choisir les temps debut et fin des notes')
%[t2, env2] = ginput (2*N);

%for k=1:N
%td(k)=t2(2*k-1);
%tf(k)=t2(2*k);
%%tdbis(k)=t2(2*k-1);
%%tfbis(k)=t2(2*k);
%%indbis=find(t>=tdbis(k) & t<=tfbis(k));
%indmax=find(t>=td(k) & t<=tf(k));

%%indmax=sort([indmax indbis]);
%end

%%td=sort([tdbis]);
%%tf=sort([tfbis]);
%end

%detect=zeros(size(t));
%detect(indmax)=ones(size(t(indmax)))*0.5;

%plot(t,env,'-',t,detect)


