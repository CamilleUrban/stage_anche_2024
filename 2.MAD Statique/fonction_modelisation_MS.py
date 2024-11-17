import numpy as np
import matplotlib.pyplot as plt
from scipy.optimize import curve_fit


# Liste des fonctions : 
    # - bord_anche
    # - rotation d\'image
    # - rogner image
    # - détection du profil d\'anche

#----------------------------------------------------------------------------------------------------------------------------
# Caracteristique non lineaire S(p)
# p : Pression dans la bouche
# S00 : Ouverture a p=0
# F_max : Pression de plaquage, force maximale
# K : raideur, pente de la section linéaire
# Coude C : Etendue de la partie coude en Pa
# Fuite L : Ouverture equivalente a la fuite
def caracNL_BG(p, S00, F_max, Coude, Fuite):
    p = p - min(p)

    # Calcul de la pente de la droite linéaire, raideur K
    K = S00 / F_max # raideur
    F_prime_max = (S00 - Fuite) / K
    A = (S00 - Fuite) / (4 * Coude * F_prime_max)

    coude_deb = F_prime_max - Coude  # pression début coude
    coude_fin = F_prime_max + Coude  # pression fin coude

    # Création des indices pour différentes parties de la courbe
    ind1 = np.argwhere(p <= coude_deb)  # partie linéaire
    ind2 = np.argwhere((p > coude_deb) & (p < coude_fin))  # coude
    ind3 = np.argwhere(p >= coude_fin)  # fuite

    # Initialisation de la section S
    S = np.zeros_like(p)
    # print(S.shape)

    # Calcul des valeurs de S pour les différentes parties de la courbe
    S[ind1] = S00 - K * p[ind1]  # partie linéaire avant enroulement
    S[ind2] = A * (p[ind2] - F_prime_max - Coude) ** 2 + Fuite  # coude -> équation du second degré
    S[ind3] = Fuite  # fuite
    return S

#----------------------------------------------------------------------------------------------------------------------------
# force : pression généralisée (= force de la lèvre )
# S_ouverture : section d'ouverture

# S00 : section d'ouverture à force nulle (ordonnée à l'origine)
# F_max : pression de plaquage
# Coude (C): Pb dans le modèle
# Sfuite : section de fuites
# Paramopt : parametres optimaux [S00, PM, Coude, Sfuites]
# Smodelepg: section théorique correspondant aux parametres optimaux


# couleur par default : c=['#2eb1d5', '#1d2343'], teinte de bleu
def identification_modele(force, S_ouverture, numero_anche, c=['#2eb1d5', '#1d2343'], plot_figure=False):
    # Identification grossière des paramètres pour l'initialisation de l'optimisation
    indmax = np.where(S_ouverture > 0.5 * np.max(S_ouverture))
    
    # partie linéaire au début de la caractéristique
    coef_polyfit = np.polyfit(force[indmax], S_ouverture[indmax], 1)
    K_estim = -coef_polyfit[0]  # pente
    S00_estim = coef_polyfit[1]  # ordonnée à l'origine
    S_ouverture_theorique = np.polyval(coef_polyfit, force[indmax])

    #####################################################################
    # Paramètres initiaux de l'optimisation
    F_max_init = S00_estim / K_estim # solution de l'équation de la droite de la partie linéraire (abscisse de Surface = 0)
    Sfuite_init = 0 
    
    # Valeur initiale de Coude_init variable pour trouver l'erreur min du modèle
    # Attention ne pas utiliser Coude_init trop grand sans quoi il y a convergence vers Coude = F_max !
    Coude_init = F_max_init / 4
    
    
    p_init = [S00_estim, F_max_init, Coude_init, Sfuite_init]
    Paramopt = curve_fit(caracNL_BG, xdata=force, ydata=S_ouverture, p0=p_init ,method='lm') # Use non-linear least squares to fit a function, f, to data
    
    Paramopt = Paramopt[0]
    surface = Paramopt[0]
    pression = Paramopt[1]
    coude = Paramopt[2]
    fuite = Paramopt[3]
    # Tracé des résultats
    pgt = np.linspace(0, 13, 300)
    ST = caracNL_BG(pgt, surface, pression, coude, fuite)
    
    if plot_figure : 
        plt.plot(force, S_ouverture, '+', lw=6, color=c[1], label=f'Anche {numero_anche}')
        plt.plot(pgt, ST, lw=2, color=c[0], label=f'Modèle {numero_anche}')

        
        # Affichage des traits de coustruction du modèle 
        plt.plot(0, Paramopt[0], '+r', lw=6)
        plt.plot(Paramopt[1], 0, '+r', lw=6)
        plt.plot([Paramopt[1], 0], [0, Paramopt[0]], '-.r', lw=1)
        plt.plot(Paramopt[1] + Paramopt[2], 0, '+g', lw=6)
        plt.plot(Paramopt[1] - Paramopt[2], 0, '+g', lw=6)
        plt.plot(0, Paramopt[3], '+b', lw=6)
        plt.plot([0, 6], [Paramopt[3], Paramopt[3]], ':b', lw=1)
        limit = np.linspace(0, 14, 100)
        plt.plot((Paramopt[1] + Paramopt[2]) * np.ones_like(limit), limit, '--g', lw =1)
        plt.plot((Paramopt[1] - Paramopt[2]) * np.ones_like(limit), limit, '--g', lw =1)
        
        plt.xlabel('force (N)', fontsize=12)
        plt.ylabel('Section d\'ouverture (mm²)', fontsize=12)
        plt.xticks(fontsize=12)
        plt.xlim([-0.1,10])
        plt.yticks(fontsize=12)
        plt.grid('True')
        plt.legend()
        plt.show()

    return Paramopt
