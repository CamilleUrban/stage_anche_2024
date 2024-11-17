import numpy as np
import matplotlib.pyplot as plt
import cv2
from sklearn.linear_model import LinearRegression
from sklearn.preprocessing import PolynomialFeatures

# Liste des fonctions : 
    # - bord_anche
    # - rotation d\'image
    # - rogner image
    # - détection du profil d\'anche

#----------------------------------------------------------------------------------------------------------------------------
# OBTENIR LES COORDONNEES DES BORDS DE L'ANCHE
# ENTREE : une image
# ginput : bord gauche et bord droit du l'anche
# SORTIE : coordonnes en pixels des deux points
def bord_anche(image):
    I = np.flipud(image)
    (H, W) = I.shape
    # print(H,W)
    plt.imshow(I, cmap='gray', extent=[0, W, H, 0])
    plt.axis('equal')
    plt.xlim(0, W)
    plt.ylim(0, H)
    plt.title("Cliquez sur les bords de l'anche")
    coord_anche = plt.ginput(2)
    plt.close()
    return coord_anche

#----------------------------------------------------------------------------------------------------------------------------
# FONCTION DE ROTATION D'IMAGE 
# ENTREE : une image
# ginput : bord gauche et bord droit de l'anche
# SORTIE : angle de rotation, image J après rotatio
def rotate(image, coord):
    # Calculer l'angle pour aligner l'image
    (x1, y1), (x2, y2) = coord
    rot_angle = np.degrees(np.arctan2(y2 - y1, x2 - x1))
    # Calculer le centre de l'image
    (h, w) = image.shape
    center = (w // 2, h // 2)

    # Créer une matrice de rotation centrale
    rot_mat = cv2.getRotationMatrix2D(center, rot_angle, 1.0)

    # Appliquer la rotation
    img_rot = cv2.warpAffine(image, rot_mat, (w, h), flags=cv2.INTER_LINEAR, borderMode=cv2.BORDER_CONSTANT, borderValue=255)
    return rot_mat, img_rot

#----------------------------------------------------------------------------------------------------------------------------
# ROGNER IMAGE
# ENTREE : image, coordonées de l'anche (obtenue par exemple avec la fonction 'bord_anche')
# SORTIE : image ronée 
def rogner(image, coord):
    # img_rogn = np.flipud(image)
    x_BG = coord[0][0]
    y_BG = coord[0][1] 
    x_BD = coord[1][0]
    y_BD = coord[1][1]
    
    # bornes 
    wmin = int(x_BG)-20     # width min
    wmax = int(x_BD)+20
    hmin = int(y_BG-50)     # height min
    hmax = int(y_BG+350)
    img_rogn = image[hmin:hmax, wmin:wmax] 
    
    return img_rogn
    
#----------------------------------------------------------------------------------------------------------------------------    
# ENTREE
def detection_profil(image, seuil, coord):
    # s'assurer que I est bien en binaire
    _, I = cv2.threshold(image, seuil, 255, cv2.THRESH_BINARY)
    
    # coord = bord_anche(image)
    (x1, y1), (x2, y2) = map(lambda p: (int(p[0]), int(p[1])), coord)
    # initialisation matrices vides
    Xv = np.arange(x1, x2, dtype=int)   # vecteur de la taille de la largeur de l'image coupée
    Yv = []
    for xv in Xv:
        Iv = I[:, xv].astype(float)   # vecteur qui contient une tranche de l'image largeur 1 (x) et hauteur de l'image (y)
        Iv_2 = np.round(np.gradient(Iv)).astype(int)     # Dérivée centrée (flottante) + Arrondir + convertir en entiers

        # seuillage trance par tranche
        smin = -30
        pos1 = np.where(Iv_2 < smin)[0][-1] if any(Iv_2 < smin) else None
        H = I.shape[0]
        Y = np.arange(1,H+1)
    
        if pos1 is not None:
            Yv.append(Y[pos1])
        else:
            Yv.append(np.nan)
    
    plot_fig = False
    if plot_fig :
        plt.figure()
        plt.imshow(image, cmap='gray')
        plt.plot(Xv, Yv, 'm.-', linewidth=0.1)
            
    return Xv, Yv

#----------------------------------------------------------------------------------------------------------------------------  
# ENTREE : coefficient du polynôme de degré 2 sous forme développée
# SORTIE : coefficient du polynôme de degré 2 sous forme canonique
def polynome_forme_canonique(coef):
    a = coef[0]
    a = -a
    b = coef[1]
    c = coef[2]
    # print(f'forme développée : {a}x**2 + {b}x + {c}')
    K0 = c- (b**2)/4
    K1 = -a
    x0 = -b/(2*a)
    coef_cano = [K0, K1, x0]
    # print(f'forme canonique : {K0}-{K1}(x-{x0})**2')
    return coef_cano

#----------------------------------------------------------------------------------------------------------------------------  
# ENTREE : tableaux des positions de y et de z, forces
# SORTIE : coef a : tableau de pentes (raideur), coef b : ordonnées à l'origines, deb = point de départ de la section d'ajustement linéaire
def calcul_pentes_et_origines(position_y, position_z, force): 
    pentes = [] # initialisation du vecteur contenant les pentes
    ordos_origine = []
    deb = np.where(force > 0.2*max(force))[0][0] # indice du début de la zone d'intérêt : pour être certain.e que l'on est dans la partie linéaire, qu'on considère comme 20% de la valeur max
    for m in (np.unique(position_y, return_counts=True)[0]) :  # boucle selectionnant chaque valeur différente de position y
        y  = position_y == m 
        z = position_z[y]
        F = force[y]
        
        coefficients = np.polyfit(z[deb:], F[deb:], 1)   # curve fitting par ajustement polynomial d'ordre 1
        pentes.append(coefficients[0]) # une pente est défini et rangée dans le vecteur "pentes" pour chaque postion y différente
        ordos_origine.append(coefficients[1])
        
    return pentes, ordos_origine, deb


#---------------------------------------------------------------------------------------------------------------------------- 
# Extraction des coefficients des modèles paramétriques de paraboles sur la raideur et l'orconnées à l'origine
# ENTREE : tableau des positions de y et de z, forces
# Entree optionnelles : numéro de l'anche + possibilité de tracer les pentes ainsi que les profils de raideur et d'ordonnées à l'origine OU uniquement les profils
# SORTIE : coefficients du polynôme de raideur sous la forme canonique, coefficeint du polynôme des ordonnées à l'origine sous forme canonique, coefficient de régression R2
def modelisation_profile_de_raideur(position_y, position_z, Force, numero_anche = '0', profil_only=False, pentes_et_profils=False) :

    pos_y = np.unique(position_y)
    pentes, ordos_origine, deb = calcul_pentes_et_origines(position_y, position_z, Force)
    
    # delta K 
    Delta_K = pentes[-1] - pentes[0]
    
    # Profil de raideur (coefs a)
    coef = np.polyfit(np.unique(pos_y), pentes, 2) # forme développée
    coef_cano = polynome_forme_canonique(coef) # forme canonique {K0}-{K1}(x-{x0})**2
    coef_pentes_cano = polynome_forme_canonique(coef)
    K0 = coef_pentes_cano[0]
    K1 = coef_pentes_cano[1]
    x0 = coef_pentes_cano[2]
    
    # Profil d'ordonnée à l'origine (coefs b )
    coef_origine = np.polyfit(np.unique(pos_y), ordos_origine, 2)
    coef_origine_cano = polynome_forme_canonique(coef_origine)
    
    # coefficient de régression R2
    poly = PolynomialFeatures(degree=2)
    poly_y = poly.fit_transform(np.array(pos_y).reshape(-1,1))
    linspace_posy = np.linspace(pos_y[0], pos_y[-1], num=100)
    pentes = np.array(pentes)
    reg_model = LinearRegression().fit(poly_y, pentes)
    R2 = reg_model.score(poly_y, pentes)# R2 is defined as (1-u/v), where u is the residual sum of squares ((y_true - y_pred)** 2).sum() and 
        # v is the total sum of squares ((y_true - y_true.mean()) ** 2).sum()
        
  
    # FIGURE 1 : profils de raideurs (a) et d'ordonnées à l'origine (b)
    if profil_only :
        fig, (axs1, axs2) = plt.subplots(1, 2, figsize=(12, 6))
        # Premier axe y
        axs1.set_xlabel('Coordonnée y (mm)', fontsize=16)
        axs1.set_ylabel('Raideur $k=F/z$ (N/mm)', fontsize=16)
        axs1.plot(pos_y, pentes, '.', label='données expérimentales (pentes)')
        axs1.plot(linspace_posy, np.polyval(coef, linspace_posy), linestyle='-', lw='2.5', label=f'z = {round(K0,3)}{round(K1,3)}(x{round(x0,3)})²')
        axs1.grid()

        # Création du second axe y
        axs2.set_xlabel('Coordonnée y (mm)', fontsize=16)
        axs2.set_ylabel('Force N', fontsize=16)
        # axs2.plot(pos_y, np.array(ordos_origine), '.', color='coral', label='données expérimentales (ordos origine)')
        # axs2.plot(pos_y, np.polyval(coef_origine, pos_y), linestyle='-', lw='2.5', color='darkred',
        #         label=f'z = {round(coef_origine_cano[0],3)}{round(coef_origine_cano[1],3)}(x{-round(coef_origine_cano[2],3)})²')
        axs2.plot(pos_y, -np.array(ordos_origine), '.', color='coral', label='données expérimentales (ordos origine)')
        axs2.plot(linspace_posy, -np.polyval(coef_origine, linspace_posy), linestyle='-', lw='2.5', color='darkred',
                label=f'z = {-round(coef_origine_cano[0],3)}{-round(coef_origine_cano[1],3)}(x{round(coef_origine_cano[2],3)})²')
        axs2.grid()
        
    # FIGURE 2 : pentes et profils
    if pentes_et_profils : 
        mymap = plt.get_cmap("Blues")
        fig = plt.figure(figsize=(12, 6))
        # fig, axs = plt.subplots(1, 2, figsize=(12, 6))
        grid = fig.add_gridspec(2, 2, width_ratios=[1, 1], height_ratios=[1, 1])
        # axs[0] prend toute la partie gauche (fusion des deux lignes)
        axs0 = fig.add_subplot(grid[:, 0])
        # axs[1] et axs[2] sont empilés à droite
        axs1 = fig.add_subplot(grid[0, 1])
        axs2 = fig.add_subplot(grid[1, 1])

        for idx, m in enumerate(np.unique(position_y, return_counts=True)[0]):
            couleur = mymap((idx+4) / len(np.unique(position_y)))
            y = position_y == m
            z = position_z[y]
            F = Force[y]
            coefficients = np.polyfit(z[deb:], F[deb:], 1)
            axs0.plot(z, F, '.', label=f'y = {m} mm', color=couleur)
            axs0.plot(z[deb:], np.polyval(coefficients, z[deb:]), linestyle='-', color=couleur, label=f'f(z) = {np.round(coefficients[0], 2)}z {np.round(coefficients[1], 2)}')
            # pente = coefficients[0]
            # pente = round(pente, 2)
            axs1.plot(m, pentes[idx], '.', color=couleur)
            # axs2.plot(m, np.array(ordos_origine)[idx], '.', color=couleur)
            axs2.plot(m, np.array(ordos_origine)[idx], '.', color=couleur)
    

        axs0.set_title(f'Force mesurée en fonction de la postion z \npour différents point sur la largeur de l\'anche (y)')
        axs0.legend(bbox_to_anchor=(-0.5, 0.5), loc='center left', fontsize=10, borderaxespad=0)
        axs0.set_xlabel('Coordonnée z (mm)', fontsize=14)
        axs0.set_ylabel('Force f(N)', fontsize=14)
        axs0.grid()

        axs1.set_title('Profil de raideur')
        axs1.plot(linspace_posy, np.polyval(coef, linspace_posy), linestyle='-', lw='2', color='orange', label=f'K(y) = {round(K0,3)}{round(K1,3)}(y{round(x0,3)})² \n $\Delta$k = {round(Delta_K,3)}')   # {coef[0]:.2f}x² + {coef[1]:.2f}x + {coef[2]:.2f} \nR² = {round(R2, 3)}
        axs1.set_xlabel('Coordonnée y (mm)', fontsize=14)
        axs1.set_ylabel('Raideur $k=f/z$ (N/mm)', fontsize=14)
        axs1.legend(loc='lower center')
        axs1.grid()
        
        axs2.set_title('Profil des ordonnées à l\'origine')
        axs2.set_xlabel('Coordonnée y (mm)', fontsize=14)
        axs2.set_ylabel('Force (N)', fontsize=14)
        # axs2.plot(pos_y, np.polyval(coef_origine, pos_y), linestyle='-', lw='2.5', color='darkred',
        #         label=f'z = {round(coef_origine_cano[0],3)}{round(coef_origine_cano[1],3)}(x{-round(coef_origine_cano[2],3)})²')
        axs2.plot(linspace_posy, np.polyval(coef_origine, linspace_posy), linestyle='-', lw='2', color='olivedrab',
                label=f'$F_0(y)$ = {round(coef_origine_cano[0],3)}+{round(coef_origine_cano[1],3)}(y{round(coef_origine_cano[2],3)})²')
        axs2.legend(loc='upper center')
        axs2.grid()


        # fig.suptitle(f'Raideur par Banc Statique Anche N° {numero_anche} (nbr_points : {len(pos_y) * len(np.unique(position_z))})', fontsize=16) # Ajouter un titre global
        plt.tight_layout(rect=[0, 0, 1, 0.95]) # Utilisation de tight_layout pour ajuster l'espace
    
    return coef_cano, coef_origine_cano, Delta_K, R2, pos_y, coef, coef_origine

#---------------------------------------------------------------------------------------------------------------------------- 