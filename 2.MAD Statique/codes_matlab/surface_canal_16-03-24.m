% Version du 19/03/2024 par Amélie Gaillard

% code permettant de détecter le contour du canal d'anche et de mesurer la surface du canal
% a utiliser avec la fonction im_rotate
% en sortie : 1 fichier.mat par anche enregistré dans le même dossier que les mesures contenant
%   - surf_c(ix1) = surface du canal pour les i forces appliquées
%   - def_r(ixn) = profil de l'anche (n pts) pour les i forces appliquées
%   - def_m(ixn) = profil du bec (n pts) pour les i forces appliquées

clear all
close all
pkg load image
pkg load signal

dossier = 'mes_2024.03.22/';
nom_anche = 'A';

% on repère les bords du bec pour une seule image (le bec ne bouge pas pour les autres ensuite alors on peut garder les mêmes cibles)
J = imread([dossier nom_anche '1_0.bmp']);

angle_rot = im_rotate(J);

% repère des bords de l'anche
cibles = {
    'Anche Gauche'
    'Anche Droite'
    };
hmax = 350; % hauteur de l'image
for R = 1

I = imread([dossier nom_anche num2str(R) '_0.bmp']);
I = imrotate(I, rad2deg(-angle_rot),'bilinear');
I = flipud(I);

I = I(150:hmax,:); % couper l'image pour ne garder qu'une partie utile

W = size(I,2); % Width
H = size(I,1); % Height

X = 1:W; % coord. non calibrées
Y = 1:H;
a = 30;
N = 20; % taille fenêtre glissante (en px)
dist_px = 5;

%% Trouver les bords du bec, on gardera les indices pour toutes les anches mesurées de la série


Ncibles = length(cibles);
COLORS = cool(Ncibles);

Xcibles = NaN*zeros(1,Ncibles);
Ycibles = NaN*zeros(1,Ncibles);

for i = 1:Ncibles+1

figure(2)
##set(gcf,'Position',get(0, 'screensize'));
clf
hold on
imagesc(X,Y,I)
shading flat
%caxis([0 255])
colormap(gray)
axis equal
xlim([0 W])
ylim([0 H])
line(xlim,[H H])

for j=1:i-1
plot(Xcibles(j)+[-1 1 1 -1 -1]*a,Ycibles(j)+[-1 -1 1 1 -1]*a,'Color',COLORS(j,:))
plot(Xcibles(j),Ycibles(j),'+','Color',COLORS(j,:))
end

if i>Ncibles
break
end

title(['Cliquer sur 1 = Anche Gauche , 2 = Anche Droite -> ' num2str(i) ' (' cibles{i} ')']);
[xclic yclic] = ginput(1);
c1 = [round(xclic) ; round(yclic)]; %prendre des entiers
title('');

Xcibles(i) = c1(1); % pixel x des cibles
Ycibles(i) = c1(2); %pixel y des cibles

end
Xv = Xcibles(1):Xcibles(2);

% Detection du profil pour toutes les forces d'une anche
for F = 0:30
##    if F < 10
        I = imread([dossier nom_anche num2str(R) '_' num2str(F) '.bmp']);
##    else
##        I = imread([dossier nom_anche num2str(R) '_' num2str(F) '.jpg']);
##    end

##  I = imrotate(I, rad2deg(-angle_rot),'bilinear');
  I = flipud(I);
  I = I(150:hmax,:);


##figure(3)
##set(gcf,'Position',[150 250 800 600])
##clf
##hold on
##imagesc(X,Y,I)
##shading flat
##%caxis([0 255])
##colormap(gray)
##axis equal
##xlim([0 W])
##ylim([0 H])

for i=1:length(Xv)
Iv = I(:,Xv(i)); % vecteur qui contient une tranche de l'image largeur 1 (x) et hauteur de l'image (y)
Iv = double(Iv);

Iv_2 = diff(Iv); %dérivée

smin = -13;
smax = 10;
pos1 = find(Iv_2<smin,1,'last')
pos2 = find(Iv_2>smax,1,'last')

if  ~isempty(pos2)
     Yv_m(i) = Y(pos2);
else
     Yv_m(i) = NaN;
    print('error!!!') %peu probable parce que detectera toujours la frontière lèvre/anche
end

if  ~isempty(pos1)
     Yv_r(i) = Y(pos1);
else
     Yv_r(i) = Yv_m(i); %lorsque le canal d'anche est fermé, il n'y aura pas de Yv_r. On lui donne la même vameur que Yv_m comme ça la différence sera de 0.
end

end
plot(Xv,Yv_r,'.-','linewidth',0.1)
plot(Xv,Yv_m,'m.-','linewidth',0.1)
pause(0.2)

##%% Calcule de la surface du canal d'anche

pix_canal = Yv_m-Yv_r

dist_px = 1064; %mesuré sur l'image MIRE 05-03-42 (8 carreaux)
dist_mm = 12; %mesuré à la règle sur la mire (cf mon cahier de labo, 2 carreaux = 3mm)
S = dist_mm / dist_px; % "sensibilité" (en mm/px)

nb_pix_canal = sum (pix_canal); % je compte tous les pixels qu'il y a dans le canal
surf_pix = S^2; % surface d'un pixel
dim_canal = (nb_pix_canal)*surf_pix; % surface en mm² du canal

%msgbox(['Surface canal estime = ',num2str(dim_canal),' mm²']); %permet d'afficher la surface estimée, attention je ne sais pas comment on fait pour les fermer automatiquement

surf_c(F+1,:)=dim_canal;
def_r(F+1,:)= Yv_r;
def_m(F+1,:)= Yv_m;


end
##savename = strcat([nom_anche num2str(R) '.mat']);
##save([dossier savename1],'def_r', 'def_m','surf_c', '-ascii');

savename1 = strcat([nom_anche num2str(R) '.txt']);
save([dossier savename1],'surf_c', '-ascii');
clear Xv Yv_m Yv_r def_r def_m;

end
