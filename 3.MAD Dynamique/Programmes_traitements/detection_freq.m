function nd=detection_freq(t,s,seuil,Fe,fjeu)

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%rôle de la fonction :
%Fait la somme cumulée dans le temps de l'amplitude
%de la composante fréquentielle de la note désirée et retourne l'indice
%de l'instant où cette somme est supérieur à un seuil fixé arbitrairement
%
%%%%%%%%%%%%%%%%%%%%%%%%%%% 
% parametres d'entree
%
% t : temps
% x : signal à detecter
% seuil : valeur du seuil pour la detection
% Fe : frequence d'echantillonnage
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Parametre de sortie
%
% nd : indice estimé correspondant à l'evenement
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
N=length(s);


% Calcul FFT du signal
Ne=length(s);
NFFT=Ne;
f=0:Fe/NFFT:Fe/2-Fe/NFFT; % tableau des frequences --> f=1:1:12500
s1=s.*hanning(Ne); % Fenetrage de Hanning sur la dur�e du signal
z=fft(s1,NFFT); 
z1=4*abs(z(1:NFFT/2))/NFFT; 


%détermination fréquence fondamentale f0
fmin=30;
Imin=min(find(f>fmin)); % N� echantillon min 
Imax=max(find(f<1.1*fjeu)); %N� echantillon max


% Detection max amplitude debut spectre
[ymax,imax]=max(z1(Imin:Imax));
f0=f(imax)+fmin+Fe/Ne;


% Calcul des composantes du signal à la fréquence trouvée. 
A=cumsum(s.*cos(2*pi*f0.*t))/Fe;
B=cumsum(s.*sin(2*pi*f0.*t))/Fe;
amp=sqrt(A.^2+B.^2);
ampnorm=amp/max(amp);


%figure(9)
%plot(f,abs(z1))
%grid


%figure(10)
%subplot(211)
%plot(t,s)
%grid
%subplot(212)
%plot(t,ampnorm,t,ones(size(t))*seuil);
%grid
%pause

nd=min(find(ampnorm>seuil));



