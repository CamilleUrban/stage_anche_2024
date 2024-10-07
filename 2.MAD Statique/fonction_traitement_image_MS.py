import numpy as np
import matplotlib.pyplot as plt
import cv2


# Liste des fonctions : 
    # - bord_anche
    # - rotation d\'image
    # - rogner image
    # - détection du profil d\'anche

#----------------------------------------------------------------------------------------------------------------------------
# FONCTION DE ROTATION D'IMAGE 
# entrée : une image
# ginput : bord gauche et bord droit du bec
# sortie : angle de rotation, image J après rotation, coordonées des points selectionnés
def im_rotate(image):
    plt.imshow(image, cmap='gray')
    plt.title("Cliquez sur les bords du bec (gauche puis droit)")

    # récuperer les coordonnées des bords du bec
    bec_coord = plt.ginput(2)
    plt.close()
    # print(f"Cordonnées des bords du bec: {np.round(bec_coord, 2)}")
        
    # Calculer l'angle pour aligner l'image
    (x1, y1), (x2, y2) = bec_coord
    rot_angle = np.degrees(np.arctan2(y2 - y1, x2 - x1))
    # print(f"Angle à corriger: {rot_angle} degrés")

    # Calculer le centre de l'image
    (h, w) = image.shape
    center = (w // 2, h // 2)

    # Créer une matrice de rotation centrale
    rot_mat = cv2.getRotationMatrix2D(center, rot_angle, 1.0)

    # Appliquer la rotation
    img_rot = cv2.warpAffine(image, rot_mat, (w, h), flags=cv2.INTER_LINEAR, borderMode=cv2.BORDER_CONSTANT, borderValue=255)

    # plt.imshow(img_rot, cmap='gray')
    # plt.title("Image alignée")
    
    return rot_mat, img_rot, bec_coord

#----------------------------------------------------------------------------------------------------------------------------
# ROGNER IMAGE
# entrée : image, coordonées du bec (_,_, xy_bec = im_rotate(J))
def rogner(image, xy_bec):
    # img_rogn = np.flipud(image)
    x_BG = xy_bec[0][0]
    y_BG = xy_bec[0][1] 
    x_BD = xy_bec[1][0]
    y_BD = xy_bec[1][1]
    
        # bornes --> PEUVENT ETRE MODIFIER POUR MIEUX CORRESPONDRE AUX BESOINS DE L IMAGE
    wmin = int(x_BG)-20     # width min
    wmax = int(x_BD)+20
    hmin = int(y_BG-40)     # height min
    hmax = int(y_BG+130)
    img_rogn = image[hmin:hmax, wmin:wmax] 
    
    return img_rogn

#----------------------------------------------------------------------------------------------------------------------------
def bord_anche(image):
    points = []
    I = np.flipud(image)
    (H, W) = I.shape
    # print(H,W)
    plt.imshow(I, cmap='gray', extent=[0, W, H, 0])
    plt.axis('equal')
    plt.xlim(0, W)
    plt.ylim(0, H)
    plt.title("Cliquez sur les bords de l'anche")
    anche_coord = plt.ginput(2)
    plt.close()
    return anche_coord

#----------------------------------------------------------------------------------------------------------------------------
# CALCUL DU CANAL D'nbr_anche
# entrée :  image, sensibilite de la caméra en mm/pix, coordonnées des bords de l'anche,
def surface_canal(image, S, seuil, anche_coord):
    # s'assurer que I est bien en binaire
    _, I = cv2.threshold(image, seuil, 255, cv2.THRESH_BINARY)

    (x1, y1), (x2, y2) = map(lambda p: (int(p[0]), int(p[1])), anche_coord)
    # initialisation matrices vides
    Xv = np.arange(x1, x2, dtype=int)   # vecteur de la taille de la largeur de l'image coupée
    Yv_m = []
    Yv_r = []

    for xv in Xv:
        Iv = I[:, xv].astype(float)   # vecteur qui contient une tranche de l'image largeur 1 (x) et hauteur de l'image (y)
        Iv_2 = np.round(np.gradient(Iv)).astype(int)     # Dérivée centrée (flottante) + Arrondir + convertir en entiers
       
        # seuillage trache par tranche
        smin = -30
        smax = -smin
        pos1 = np.where(Iv_2 < smin)[0][0] if any(Iv_2 < smin) else None
        pos2 = np.where(Iv_2 > smax)[0][0] if any(Iv_2 > smax) else None
        (H, W) = I.shape
        Y = np.arange(1,H+1)
    
        if pos2 is not None:
            # Yv_m[i] = Y[pos2]
            Yv_m.append(Y[pos2])
        else:
            # Yv_m[i] = np.nan
            Yv_m.append(0)
            # print('error!!!')  # Peu probable parce que détectera toujours la frontière lèvre/anche

        if pos1 is not None:
            # Yv_r[i] = Y[pos1]
            Yv_r.append(Y[pos1])
        else:
            # Yv_r[i] = Yv_m[i]  # Lorsque le canal d'anche est fermé, il n'y aura pas de Yv_r. On lui donne la même valeur que Yv_m comme ça la différence sera de 0.
            Yv_r.append(Yv_m)
    
    # for m, r in zip(Yv_m, Yv_r):
    #     print(f"Type de m: {type(m)}, Type de r: {type(r)}")
           
    # Calculer la différence entre les deux courbes
    diff = [0 if m == 0 or r == 0 else (int(m) - int(r)) for m, r in zip(Yv_m, Yv_r)]
    diff = np.abs(diff)
    # les Nan sont remplacés par des 0
    # diff = np.nan_to_num(diff)

    # Calculer l'aire en utilisant la méthode des trapèzes en pixel²
    area = np.trapz(diff, Xv)

    # mise en mm²
    surf_pix = S ** 2  # surface d'un pixel
    dim_canal = area / surf_pix  # surface en mm² du canal
        
    return Xv, Yv_r, Yv_m, dim_canal