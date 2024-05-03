clear all
close all

cd ..
cd resultats
cd BEC

rouge='anche_automatique_becSP12rouge_(14.5).mat';
blanc='anche_automatique_becSP16blanc_(14.5).mat';
lx2='anche_automatique_beclx2_(14.5).mat';

   
   figure(1) 
    
   load(rouge)
   semilogy(abs(pmpmoy1), ecartcent,'-bx','MarkerSize',6)
   hold on
   load(blanc)
   semilogy(abs(pmpmoy1), ecartcent,'-rx','MarkerSize',6)
   hold on
   load(lx2)
   semilogy(abs(pmpmoy1), ecartcent,'-go','MarkerSize',6)
   
legend('rouge','blanc','lx2')
title('supperposition des écart de fréquence en cent des trois becs')
xlabel('pression moyenne dans le bec (hPa)')
ylabel('Ecart entre fréquence de jeu et fondamentale (cent)')
set(1, 'Units', 'Normalized', 'Position', [0 0 1 1]);
