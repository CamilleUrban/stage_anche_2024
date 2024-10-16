# Written by E. Brasseur & C. Urban - March 2024


import os
import time
from pathlib import Path
from pico import pico
from Camera import capture_image

###########################################################################################
# -------------- A vérifier avant chaque début de mesure : --------------------------------
###########################################################################################
date = '2024.10.01'
# branchement du capteur de force
channel_amp = 1
gain = 900
channel_pico = 'A'
Range = 5 # modifiablee sur pico.py

# Sensibilités
d_pix = 1860-186
d_mm = 20 #ditance entre 13 carreaux
S_force = 0.04026 # mV/N
S_camera = d_pix/(d_mm) # pix/mm

# conditions experimentales
temperature = [23.0, 20.7, 21.6, 20.4, 22.4, 20.7, 21.6] #°C
hygrometrie = [39,48] #%

# paramètres initiaux de mesure
position_init = 8.5 #mm
pas_mes = 0.2 #mm
distance_pointe_anche = 3 #mm
mollette_verticale = 3.500 #mm
###########################################################################################
# -----------------------------------------------------------------------------------------
numero_anche = 90
# -----------------------------------------------------------------------------------------
###########################################################################################

if __name__ == '__main__':
   
	idp=7
	offset = pico(idp)
	
	# ~ os.mkdir("mesures_"+str(date))		# à commenter si le dossier existe déjà
	rep="mesures_"+str(date)
	
	# Création du documents regroupants les paramètres spécifiés
	fichier_param=f"param mes_{date}.txt"
	with open(rep + "//" + f"{fichier_param}", 'w') as param:
		param.write(f"Channel ampli : {channel_amp} \nChannel_pico : {channel_pico}\n")
		param.write(f"Range : {Range} V \n")
		param.write(f"Gain : {gain} \n")
		param.write(f"Offset : {offset} N \n")
		param.write(f"Sensibilite capteur de force :  {S_force} \npour un gain de 100 en V/N \n")
		param.write(f"Sensibilite capteur de la caméra :  {S_camera} pix/mm \n")
		param.write(f"Temperature :  {temperature} \n°C \n")
		param.write(f"Hygrometrie :  {hygrometrie} pix/mm \n")
		param.write(f"Position initale de la mollette horizontale : {position_init} mm \n")
		param.write(f"Pas de déplcament : {pas_mes} mm \n")
		param.write(f"Distance à la pointe de l'anche : {distance_pointe_anche} mm -> position mollette verticale : {mollette_verticale} mm\n")

   
	nom_fichier=f"data_anche{numero_anche}.txt"
	with open(f"{rep}"+"//" + nom_fichier, 'w') as fichier:
		for i in range(31):
			
			# Indiquez l'index de la caméra (trouver l'index camera avec la ligne : v4l2-ctl --list-devices)
			camera_index = 0
			# Indiquez le chemin de sauvegarde de l'image
			save_path = f"{rep}/image_{numero_anche}_{i}.jpg"
			# Indiquez la résolution souhaitée
			width = 1920
			height = 1080
			# Capturez une image à partir de la caméra avec la nouvelle résolution et enregistrez-la
			capture_image(camera_index, save_path, width, height)
			
			moyenne=pico(idp)
			print(f"La moyenne à {round(position_init+i*pas_mes, 2)} = {moyenne}")
			fichier.write(f"{i} {round(position_init+i*pas_mes,2)} {moyenne}\n")

			input()		

