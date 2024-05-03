%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% fait par Ewen Carcreff (ESEO), mars 2007
%
% [X_RESONANCES,IND_RESONANCES] = detect_pic_local(x,y,NB_points) d�tecte
% les maximums locaux de y(x). X_RESONANCES sont les abcisses des maximums
% et IND_RESONANCES sont les indices des abscisses correspondants.
%
% entr�es : vecteur x => abcisses
%           vecteur y => ordonn�es
%           entier NB_points => nombre de points de d�tection du max
%
% sorties : vecteur X_RESONANCES => abscisses des maximums locaux
%           vecteur IND_RESONANCES => indices des abscisses des maximums locaux 
%
% application : d�tection automatiques des 5 fr�quences de r�sonance d'une 
% fonction de transfert issue de mesures effectu�es sur un anche de clarinette 
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function [X_MAX] = detect_pic_local(x,y,NB_points)

global NB_capteurs
global NB_DDL

Y_MAX = [];
X_MAX = [];
IND_MAX = [];
N = length(x);
y=y/max(y);
seuil=0.2;

% recherche des maximum locaux sur NB_points points %
for i = NB_points+1: N-NB_points,
    COMP = 0;
    for k = 1:NB_points
        if and(y(i)>y(i-k),y(i)>y(i+k))
            COMP = COMP + 1;
        end
    end
    
    if (COMP == NB_points & y(i) > seuil)
        Y_MAX = [Y_MAX ;y(i)];
        X_MAX = [X_MAX ; x(i)];
        IND_MAX = [IND_MAX ; i];
    end
end

