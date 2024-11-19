%Caracteristique non lineaire S(p)
%p : Pression dans la bouche
%S00 : Ouverture a p=0
%pM : Pression de plaquage
%Coude : Etendue de la partie coude en Pa
%Fuite : Ouverture equivalente a la fuite

function S=caracNL_BG(p,param)
%p=p-min(p);
S00=param(1);
pM=param(2);
Pb=param(3);
SL=param(4);
##SL=0;

C=S00/pM; %pente de la droite linéaire
PprimeM=(S00-SL)/C;
A=(S00-SL)/(4*Pb*PprimeM);

pb1=PprimeM-Pb; % pression début coude
pb2=PprimeM+Pb; % pression fin coude
ind1=find(p<=pb1); % indice pour lequel la partie est linéaire
ind2=find((p>pb1)&(p<pb2)); % indice pour lequel on a le coude
ind3=find(p>=pb2); %indice pour lequel on a la fuite

S=zeros(size(p));
S(ind1)=S00-C*p(ind1); % partie linéaire avant enroulement
S(ind2)=A*(p(ind2)-PprimeM-Pb).^2+SL; % Coude -> équation du second degré
S(ind3)=SL; % fuite

endfunction
