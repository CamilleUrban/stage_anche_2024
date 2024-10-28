# Write by E. Brasseur & C. Urban- March 2024


import os
import time
from pathlib import Path
from zaber import deplacement
from zaber import home1
from zaber import home2
from zaber import return_position
from pico import pico
from Camera import capture_image
from milieu_anche import milieu_anche


if __name__ == '__main__':

	numero_anche = 90
	force_anche = 2.5
	d_pointe_anche = 3  # mm, distance à la pointe de l'anche
	date = '90anches_2024.10.17'
	# ~ os.mkdir("mesures_BS_" + str(date))	# à commenter si le dossier existe déja
	
###########################################################################################
# ---------------------------- Parametres d'acquisition -----------------------------------
###########################################################################################
	channel_pico = 'A'
	channel_amp = 1
	gain_acqui = 900
	
	# Sensibilité
	S_capt = 0.04026*10**3 # (mV/N) # capteur force
	gain_calib = 100
	
	S = gain_acqui*S_capt/gain_calib
	
	# Initialisation settings de capture camera
	# Indiquez l'index de la caméra (trouver l'index camera avec la ligne : v4l2-ctl --list-devices)
	camera_index = 0	
	# Indiquez la résolution souhaitée
	width = 1920
	height = 1080
	
	idp = 7 # identification picoscope --> à vérifier en ouvrant le logiciel picoscope
	
	Temperature = [23.5,21.9, 21.1] #°C
	Hygrometrie = [49, 53, 49] #%
	
###########################################################################################
# ----------------- Creation de fichiers, initialisation de position ----------------------
###########################################################################################
	#  creation de dossier, initialisation des fichiers
	rep="mesures_BS_" + str(date)
	nom_fichier0=f"param_acqui.txt" # fichier d enregistrement paramètres d'acquisition
	nom_fichier=f"data_anche{numero_anche}.txt" # fichier d enregistrement des données
	# ~ os.mkdir(rep + nom_fichier0)
	
	# se placer à la position initiale 
	y_0, z_0, y_BD, S_cam = milieu_anche(numero_anche)
	
###########################################################################################
# -------------------------------- Paramètres de mesure -----------------------------------
###########################################################################################
	# parametres
	N = 5 	# nombre de point sur une demi largeur d'anche (impaire)
	n = 3		# nombre de points suivant z
	pas_i = abs((y_BD-y_0)/(N+1)) 	# pas sur le déplacment horizontal (y)
	step_i = int(pas_i/0.1905e-3)
	pas_j = 1.3/n	# pas sur un déplacement vertical (z)
	step_j = int(pas_j/0.1905e-3)
	
	
	# enregistrement des paramètres
	with open(f"{rep}/{nom_fichier0}", 'w') as param :
		param.write(f"Sensibilite camera : {S_cam} pix/mm \nSensibilité capteur force : {S_capt} mV/N \nGain qualibration = {gain_calib} et gain de mesure = {gain_acqui} \n")
		param.write(f"Channel ampli : {channel_amp} \nChannel_picoscope : {channel_pico} \n")
		param.write(f"Température : {Temperature} \nHygrométrie : {Hygrometrie} \n \n")
		param.write(f"distance à la pointe de l'anche : {d_pointe_anche} \n")
		param.write(f"nombre de point sur une largeur d'anche (suivant y): {N*2-1}, pas horizontal suivant y : {step_i} \nnombre de points suivant z : {n}, pas horizontal suivant z : {step_j}")
			
###########################################################################################	
# -------------------------------------DEBUT MESURE----------------------------------------
	with open(f"{rep}/{nom_fichier}", 'w') as fichier :
		
		fichier.write(f"force_anche distance_pointe_anche y z moyenne_brute moyenne(N) \n")
		offset0=pico(idp)
		fichier.write(f"offset: \n{offset0}  \ny_centre:\n{y_0}\n")
		# MESURE SUR UNE DEMI LARGEUR D'ANCHE
		for i in range(N):
						
			# offset defini pour chaque point de mesure sur la largeur d'anche
			offset=pico(idp)
			a = round((i)*pas_i, 3) # position en mm par rapport au milieu d'anche
			fichier.write(f"{force_anche} {d_pointe_anche} {a} 0 {offset} 0 \n")
			save_path = f"{rep}/image_{numero_anche}_{N-1-i}_0.jpg"
			capture_image(camera_index, save_path, width, height)
			time.sleep(0.5)
			# se mettre au contact de l'anche
			axe=1
			toto=int(1.8/0.1905e-3)
			deplacement(toto, axe)
			time.sleep(0.5) 

			for j in range(n):
				axe=1
				deplacement(step_j, axe)
				time.sleep(0.5)
				# ~ return_position(axe)
				moyenne_brute = pico(idp) 
				# ~ print(moyenne_brute)
				moyenne=(pico(idp)-offset0)/S # valeur de force en N 
				b = round((j+1)*pas_j, 3)
				fichier.write(f"{force_anche} {d_pointe_anche} {a} {b} {moyenne_brute} {moyenne}\n")
				save_path = f"{rep}/image_{numero_anche}_{N-1-i}_{j+1}.jpg"
				capture_image(camera_index, save_path, width, height)
		
			# retour à la position verticale initiale 
			axe=1
			pas=-pas_j*n
			step=int(pas/0.1905e-3)-toto
			deplacement(step, axe)
			
			# ~ # deplacement horizontal
			axe=2
			step_i=int(pas_i/0.1905e-3)
			time.sleep(0.5)
			deplacement(-step_i, axe)
			time.sleep(0.5)
			return_position(2)
		
		
		# DEUXIEME DEMI LARGEUR D'ANCHE
		# ~ home1()
		# ~ time.sleep(1)
		home2()
		time.sleep(1)
		
		# se positionner de nouveau sur le milieu de l'anche
		step=int(y_0/0.1905e-3) 
		deplacement(step, 2)
		time.sleep(0.5)
		# ~ deplacement(int((z_0+1.1)/0.1905e-3), 1) 
		# ~ time.sleep(0.5)
	
		for i in range (N-1):
			
			# deplacement horizontal
			axe=2
			time.sleep(0.5)
			deplacement(step_i, axe)
			time.sleep(0.5)
			return_position(2)
						
			# offset defini pour chaque point de mesure sur la largeur d'anche
			offset=pico(idp)
			# valeur de force en N : 
			a = round(-(i+1)*pas_i, 3)
			fichier.write(f"{force_anche} {d_pointe_anche} {a} 0 {offset} 0 \n")
			save_path = f"{rep}/image_{numero_anche}_{i+N}_0.jpg"
			capture_image(camera_index, save_path, width, height)
			
			# se mettre au contact de l'anche
			axe=1
			toto=int(1.8/0.1905e-3)
			deplacement(toto, axe)
			time.sleep(0.5) 
			
			for j in range(n):
				axe=1
				deplacement(step_j, axe)
				time.sleep(1)
				return_position(axe)
				moyenne_brute=pico(idp)
				moyenne=(pico(idp)-offset0)/S
				b = round((j+1)*pas_j, 3)
				fichier.write(f"{force_anche} {d_pointe_anche} {a} {b} {moyenne_brute} {moyenne}\n")
				
				
				# Indiquez le chemin de sauvegarde de l'image
				save_path = f"{rep}/image_{numero_anche}_{i+N}_{j+1}.jpg"
				
				# Capturez une image à partir de la caméra avec la nouvelle résolution et enregistrez-la
				capture_image(camera_index, save_path, width, height)
		
		
			# retour à la position verticale initiale 
			axe=1
			pas=-pas_j*n
			step=int(pas/0.1905e-3)-toto
			deplacement(step, axe)

home1()
home2()
