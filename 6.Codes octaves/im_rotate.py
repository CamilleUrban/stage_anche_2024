import numpy as np
import matplotlib.pyplot as plt
import pandas as pd

from skimage.io import imread
from skimage.transform import rotate
import os

def im_rotate(J):
    cibles = ['Bec Gauche', 'Bec Droit']

    J = np.flipud(J)
    W = J.shape[1]  # Width
    H = J.shape[0]  # Height
    
    X = np.arange(1,W+1)  # coord. non calibrées
    Y = np.arange(1,H+1)
    a = 30
    N = 20  # taille fenêtre glissante (en px)
    dist_px = 5
    
    Ncibles = len(cibles)
    COLORS = plt.cm.cool(np.linspace(0, 1, Ncibles))

    Xcibles = np.full(len(cibles), np.nan)
    Ycibles = np.full(len(cibles), np.nan)

    for i in range(2):
        plt.figure()
        plt.clf()
        plt.imshow(J, cmap='gray', extent=[0, W, H, 0])
        plt.axis('equal')
        plt.xlim(0, W)
        plt.ylim(0, H)

        for j in range(1, i):
            # Tracer le carré
            plt.plot([Xcibles[j] - a, Xcibles[j] + a, Xcibles[j] + a, Xcibles[j] - a, Xcibles[j] - a],
                    [Ycibles[j] - a, Ycibles[j] - a, Ycibles[j] + a, Ycibles[j] + a, Ycibles[j] - a],
                    color=COLORS[j])

            # Tracer le marqueur '+'
            plt.plot(Xcibles[j], Ycibles[j], '+', color=COLORS[j])

        if i > len(cibles):
            break

        plt.title('Cliquer sur 1 = Bec G, 2 = Bec D  -> {} ({})'.format(i, cibles[i]))
        xclic, yclic = plt.ginput(1)[0]
        c1 = np.array([round(xclic), round(yclic)])  # prendre des entiers
        plt.title('')

        Xcibles[i] = c1[0]  # pixel x des cibles
        Ycibles[i] = c1[1]  # pixel y des cibles

    # rotation de l'image
    XL_mp = Xcibles[0]
    XR_mp = Xcibles[1]
    YL_mp = Ycibles[0]
    YR_mp = Ycibles[1]

    angle_rot = np.arctan2(YR_mp - YL_mp, XR_mp - XL_mp)
    J_rot = rotate(J, np.degrees(angle_rot), mode='constant', cval=np.mean(J))
    return angle_rot, J_rot

# # Chargement de l'image
# image_path = 'Banc statique\\2024.03.21\position1\\anche1\image_0_0.jpg'
# I = imread(image_path)

# # Appel de la fonction
# angle_rot, J_rot = im_rotate(I)

# # Affichage de l'image après rotation
# plt.figure()
# plt.imshow(J_rot, cmap='gray')
# plt.axis('off')
# plt.title('Image après rotation')
# plt.show()
