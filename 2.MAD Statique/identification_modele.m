% Identification des parametres d'une caractéristique non linéaire d'anche
% pg : pression généralisée (= force de la lèvre )
% S : section d'ouverture
% S00 : section d'ouverture à pg nulle (ordonnée à l'origine)
% PM: pression de plaquage
% Coude : Pb dans le modèle
% Sfuites : section de fuites
%
% Paramopt : parametres optimaux [S00, PM, Coude, Sfuites]
% Smodelepg: section théorique correspondant aux parametres optimaux

function [Paramopt,erreuropt]=identification_modele(pg,S)

addpath('C:/Users/Admin/Documents/Stage anches Urban Camille/MAD Statique');

pkg load optim

% Identification grossière des parametres pour l'initialisation de l'optimisation
% on recherche à identifier la partie linéaire de la caractéristique
% pour estimer S00 et souplesse Cest donc PM0

## partie linéraire au début de la caractéristique
Smax=max(S);
indmax=find(S>0.5*Smax);
P=polyfit(pg(indmax),S(indmax),1);
Cest=-P(1); %pente
S0est=P(2); %ordonnée à l'origine
Stheo=polyval(P,pg(indmax));

% ============== parametres initiaux de l'optimisation ====================
PM0=S0est/Cest; % solution de l'équation de la droite de la partie linéraire (abscisse de Surface = 0)
Sfuites0=0;

% Valeur initiale de Coude0 variable pour trouver l'erreur min du modèle
% Attention ne pas utiliser Coude0 trop grand sans quoi il y a convergence vers Coude = PM !
Coude0=PM0/4;
p0=[S0est,PM0,Coude0,Sfuites0];  # parametres initiaux pour modele S00, PM, Pb, Sf

% minimisation au sens des moindres carrés
[Smodelepg,Paramopt]=leasqr(pg,S,p0,'caracNL_BG'); % modele avec PM + Pb
erreuropt=sqrt(sum((Smodelepg-S).^2)/sum(S.^2))*100;

pgt = linspace(0,6,100);
ST=caracNL_BG(pgt,Paramopt);

%plot(pg,S,'-+','linewidth',2);
hold on
plot(pgt,ST,'k','linewidth',3);
plot(0,Paramopt(1),'+r','LineWidth',6)
plot(Paramopt(2),0,'+r','LineWidth',6)
plot([Paramopt(2) 0],[0 Paramopt(1)],'-.r','LineWidth',1)
plot(Paramopt(2)+Paramopt(3),0,'+g','LineWidth',6)
plot(Paramopt(2)-Paramopt(3),0,'+g','LineWidth',6)
plot(0,Paramopt(4),'+b','LineWidth',6)
plot([0 6],[Paramopt(4) Paramopt(4)],':b','LineWidth',1)


limit=linspace(0,14,100);
plot((Paramopt(2)+Paramopt(3))*ones(size(limit)),limit,'--g',"linewidth",1,(Paramopt(2)-Paramopt(3))*ones(size(limit)),limit,'--g',"linewidth",1)

endfunction
