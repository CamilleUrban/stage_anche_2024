import numpy as np
from scipy.optimize import least_squares
from caracNL_BG import caracNL_BG

import matplotlib.pyplot as plt

# Identification des parametres d'une caractéristique non linéaire d'anche
# pg : pression généralisée (= force de la lèvre)
# S : section d'ouverture
# S00 : section d'ouverture à pg nulle (ordonnée à l'origine)
# PM: pression de plaquage
# Coude : Pb dans le modèle
# Sfuites : section de fuites
def erreur_modele(param, pg, S):
        modele = caracNL_BG(pg, param)  # Appel à votre fonction de modèle caracNL_BG
        return modele - S   
    

def identification_modele(pg, S):  
    # Identification grossière des parametres pour l'initialisation de l'optimisation
    # on recherche à identifier la partie linéaire de la caractéristique
    
    # pour estimer S00 et souplesse Cest donc PM0

    # partie linéraire au début de la caractéristique
    Smax = np.max(S)
    indmax = np.where(S > 0.5 * Smax)[0]
    P = np.polyfit(pg[indmax], S[indmax], 1)
    Cest = -P[0]  # pente
    S0est = P[1]  # ordonnée à l'origine
    Stheo = np.polyval(P, pg[indmax])

    # parametres initiaux de l'optimisation
    PM0 = S0est / Cest  # solution de l'équation de la droite de la partie linéraire (abscisse de Surface = 0)
    Sfuites0 = 0
    
    # Valeur initiale de Coude0 variable pour trouver l'erreur min du modèle
    # Attention ne pas utiliser Coude0 trop grand sans quoi il y a convergence vers Coude = PM !
    Coude0 = PM0 / 4 
    p0 = [S0est, PM0, Coude0, Sfuites0]  # parametres initiaux pour modele S00, PM, Pb, Sf

    # minimisation au sens des moindres carrés
    result = least_squares(lambda param: erreur_modele(param, pg, S), p0)
    Paramopt = result.x
    erreuropt = np.sqrt(np.sum((caracNL_BG(pg, Paramopt) - S) ** 2) / np.sum(S ** 2)) * 100

    return Paramopt, erreuropt



