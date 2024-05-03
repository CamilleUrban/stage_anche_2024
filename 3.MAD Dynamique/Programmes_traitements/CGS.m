function [CGS,CGSA] = CGS(fn,amp);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Rôle de la fonction 
% calcule le Centre de Gravité Spectral (CGS) d'un signal determiné par fn et amp.
% calcule aussi le CGS pondéré A avec application du filtre de pondération A sur le spectre du signal.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Données d'entrée
% fn: tableau des fréquences
% amp : tableau des amplitudes
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Données de sortie : 
% CGS : 
% CGSA : CGS pondéré A.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% calcul CGS avec harmoniques signal
CGS=sum(amp.*fn)/sum(amp);

ampdB=20*log10(amp);
% Calcul du CGS pondéré A.
% filtre dBA
f=[100 125 160 200 250 315 400 500 625 800 1000 1250 1600 2000 2500 3150 4000 5000 6300 8000 10000];
correcdB=[-19.1 -16.1 -13.4 -10.9 -8.6 -6.6 -4.8 -3.2 -1.9 -0.8 0 0.6 1 1.2 1.3 1.2 1.1 0.5 -0.1 -1.1 -2.5];
p=polyfit(log(f),correcdB,3);
polydBA=polyval(p,log(fn));
ampcorrdB=ampdB+polydBA;

% amplitude des harmoniques (valeur lin) corrigée par dBA
ampcorr=10.^(ampcorrdB/20);

% calcul CGSA avec harmoniques signal d'amplitude corrigée par dBA.
CGSA=sum(ampcorr.*fn)/sum(ampcorr);
