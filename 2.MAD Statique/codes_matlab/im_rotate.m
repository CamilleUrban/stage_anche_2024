

##pkg load signal
##pkg load image
##% on repère les bords du bec pour une seule image (le bec ne bouge pas pour les autres ensuite alors on peut garder les mêmes cibles)
##I = imread('C:/Users/gaillard/Documents/THESE/MAD/MAD statique/anches sax soprano/S5_0001.jpg');rot_img

function angle_rot = im_rotate(J)

cibles = {
    'Bec Gauche'
    'Bec Droit'
    };

J = flipud(J);
W = size(J,2); % Width
H = size(J,1); % Height

X = 1:W; % coord. non calibrées
Y = 1:H;
a = 30;
N = 20; % taille fenêtre glissante (en px)
dist_px = 5;

%% Trouver les bords du bec

Ncibles = length(cibles);
COLORS = cool(Ncibles);

Xcibles = NaN*zeros(1,Ncibles);
Ycibles = NaN*zeros(1,Ncibles);

for i = 1:Ncibles+1

figure(1)
%set(gcf,'Position',[150 250 800 600])
clf
hold on
imagesc(X,Y,J)
shading flat
colormap(gray)
axis equal
xlim([0 W])
ylim([0 H])

for j=1:i-1
plot(Xcibles(j)+[-1 1 1 -1 -1]*a,Ycibles(j)+[-1 -1 1 1 -1]*a,'Color',COLORS(j,:))
plot(Xcibles(j),Ycibles(j),'+','Color',COLORS(j,:))
end

if i>Ncibles
break
end

title(['Cliquer sur 1 =  Bec G , 2 = Bec D  -> ' num2str(i) ' (' cibles{i} ')']);
[xclic yclic] = ginput(1);
c1 = [round(xclic) ; round(yclic)]; %prendre des entiers
title('');

Xcibles(i) = c1(1); % pixel x des cibles
Ycibles(i) = c1(2); %pixel y des cibles

end
% rotation de l'image
XL_mp = Xcibles(1);
XR_mp = Xcibles(2);
YL_mp = Ycibles(1);
YR_mp = Ycibles(2);

angle_rot = atan2(YR_mp - YL_mp, XR_mp - XL_mp);
J_rot = imrotate(J, rad2deg(angle_rot),'bilinear');
%close
%figure(2)
%J_rot = flipud(J_rot);
%I = imshow(J_rot);

