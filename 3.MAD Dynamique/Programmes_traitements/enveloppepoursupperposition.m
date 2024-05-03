function [z1,f]=enveloppe(s,Fe,fjeu,Nh);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Role de la fonction
% Calcul les frequences et amplitudes des raies d'un signal periodique.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Donnees d'entree
% s : signal a analyser
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Donnees de sortie
% fn : tableau des frequences
% amp : tableau des amplitudes
% f0 : frequence fondamentale du signal
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% Calcul FFT du signal

% s0=zeros(10000,1);
% s=[s;s0];
Ne=length(s);
NFFT=Ne;
f=0:Fe/NFFT:Fe/2-Fe/NFFT; % tableau des frequences --> f=1:1:12500
s1=s.*hanning(Ne); % Fenetrage de Hanning sur la durée du signal
z=fft(s1,NFFT); 
z1=4*abs(z(1:NFFT/2))/NFFT; 

%figure(3)
%plot(f,abs(z1));

%determination frequence fondamentale f0
fmin=30;
Imin=min(find(f>fmin)); % Numero echantillon min 
Imax=max(find(f<1.1*fjeu)); %Numero echantillon max

% Detection max amplitude spectre
% [ymax,imax]=max(z1(Imin:Imax)); 
% f0=f(imax)+fmin+Fe/Ne;

%Nh=input('Nb harmoniques ?'); %Nombre d'harmoniques qui seront prise en compte pour le calcul du CGS
%Nh=round(Fe/(2*f0));
%Fc=10000;
%Nh=ceil(Fc/f0);

clear fn;
clear amp;

%fn(1)=f0;
%amp(1)=ymax;
%Nmin=2;
Nmin=1;
f0=fjeu;

% Recherche des frequences correspondant aux maximum d'amplitudes locaux
for n=Nmin:Nh
    fnmin=(n-1/2)*f0;
    inmin=max(find(f<fnmin));
    fnmax=(n+1/2)*f0;
    inmax=max(find(f<fnmax));
    ftemp=f(inmin:inmax);
    z1temp=z1(inmin:inmax);
    [amp(n),imax]=max(z1temp);
    fn(n)=f(inmin+imax-1);
end

RMSest=sqrt(sum(amp.^2/2));

varbruitest=var(s)-RMSest^2;
if varbruitest <0
 varbruitest=var(s);
end

RSBest=10*log10(RMSest^2/varbruitest);


% % Affichage de la FFT et des harmoniques detectees
%  figure(20)
%  loglog(f,z1,'MarkerSize',20)
%  hold on
% %  loglog(fn,amp,'ro','MarkerSize',20)
% %  xlabel('Frequency (Hz)','fontsize', 20)
% % ylabel('Pressure spectrum (dB)','fontsize', 20);
% 
%  pause
% close(20)
