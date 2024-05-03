clear all
close all

cd .. % On va dans : programmesBec
cd resultats
cd dynamique_3anches



figure (1);
load('anche_automatique_becrouge_(1).mat')
a=semilogx(f1,abs(fft(ampint)));
% hold on
% load('anche_automatique_becrouge_(2).mat')
% b=plot(f1,abs(fft(ampint)), 'r');
% hold on
% load('anche_automatique_becrouge_(3).mat')
% c=plot(f1,abs(fft(ampint)), 'g');
% hold on
% load('anche_automatique_becrouge_(4).mat')
% d=plot(f1,abs(fft(ampint)), 'y');
% hold on
% load('anche_automatique_becrouge_(3).mat')
% e=plot(f1,abs(fft(ampint)), 'k');
% title('Représentation des courbes de bifurcation pour 5 mesures referencées aux pressions de seuil')
% xlabel('Pressions moyennes dans le bec referencées aux pressions de seuil')
% ylabel('Pression dans le bec rms normalisée')
% 

% saveas(1, ['bifurcation repetabilite becrouge automatique (14.5).fig'])
