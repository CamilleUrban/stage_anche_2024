import os
import time
from pathlib import Path
from zaber import deplacement
from zaber import home1
from zaber import home2
from zaber import return_position
from pico import pico
from Camera import capture_image
import numpy as np
import serial
import cv2



def milieu_anche(numero_anche):
	
	C = 0.1905e-3
	# Initialiser la liste des points
	points = []
	
	# Fonction de rappel de clic de la souris
	def clic(event, x, y, flags, param):
		nonlocal points
		# Si le bouton gauche de la souris est cliqué, enregistrer les coordonnées
		if event == cv2.EVENT_LBUTTONDOWN:
			points.append((x, y))
			# Afficher un cercle sur le point cliqué
			cv2.circle(image, (x, y), 5, (0, 255, 0), -1)
			cv2.imshow('image', image)
	
	# Initialisation des positions
	time.sleep(0.5)
	home1()
	time.sleep(0.5)
	home2()
	time.sleep(0.5)

	# premier deplacement horizontal pour se mettre au dessus de l'anche
	pas=12
	step=int(pas/C)
	time.sleep(2)
	deplacement(step, 2)

	time.sleep(0.5)
	# premier déplacement vertical pour ne pas être trop loin de l'anche
	pas=15
	step=int(pas/C)
	time.sleep(0.2)
	deplacement(step, 1)


	# numero_anche = 7
	date = '90anches_2024.10.17'
	rep="mesures_BS_" + str(date)
	# ~ os.mkdir("mesures_BS_" + str(date))
	# ~ rep="anche"+str(numero_anche)
	# ~ os.mkdir("anche"+str(numero_anche))	
	nom_fichier=f"param_anche{numero_anche}.txt"
	camera_index = 0
	width = 1920
	height = 1080

# ---------------------------------------------------------------

	# ~ with open(rep +"//" + nom_fichier, 'w') as fichier:

	# enregistrer position et image
	save_path = rep + "/test1.jpg"
	capture_image(camera_index, save_path, width, height)

	time.sleep(0.2)
	# Charger l'image
	image = cv2.imread(rep + "/test1.jpg")
	cv2.imshow('image', image)
	print('Cliquez sur le BG puis BD du capteur puis BG et BD de l\'anche \nBG = Bord Gauche, BD = Bord Droit')


	# Attacher la fonction de rappel de clic à la fenêtre
	cv2.setMouseCallback('image', clic)

	# Attendre que l'utilisateur clique sur quatre points
	while len(points) < 4:
		cv2.waitKey(100)

	# Fermer la fenêtre
	cv2.destroyAllWindows()

	# Afficher les coordonnées des points
	C_a = (points[2][0]+points[3][0])/2
	C_c1 = (points[0][0]+points[1][0])/2
	BD = points[3][0]
	
	time.sleep(0.2)
	# déplacement de 4mm
	pas=4 
	step=int(pas/C)
	time.sleep(2)
	deplacement(step, 2)
	
	# enregistrer position et image
	save_path = rep + "/test2.jpg"
	capture_image(camera_index, save_path, width, height)
	
	# Charger l'image
	image = cv2.imread(rep + "/test2.jpg")
	cv2.imshow('image', image)
	print('Cliquez sur le BG puis BD du capteur')


	# Reinitialiser la liste des points
	points = []
	
	# Attacher la fonction de rappel de clic à la fenêtre
	cv2.setMouseCallback('image', clic)

	# Attendre que l'utilisateur clique sur 2 points
	while len(points) < 2:
		cv2.waitKey(100)
		
	# Fermer la fenêtre
	cv2.destroyAllWindows()

	# Afficher les coordonnées des points
	C_c2=abs(points[0][0]+points[1][0])/2
	# distance en pixel pour un déplacement de 4 mm
	d_pix = abs(C_c1 - C_c2)
	# distance en mm entre le centre du capteur et le bord droit de l'anche
	pas_CBD = abs((C_c2 - BD)*pas/d_pix)
	# position en mm centre a
	pas_C_a = abs((pas * (C_a-BD))/d_pix)
	
	# position absolue bord droit
	time.sleep(0.2)
	step=int((-pas_CBD + pas_C_a)/C)
	deplacement(step, 2)
	time.sleep(0.2)
	y_0 = return_position(2)# en mm
	print(f'y_0 = {round(y_0,3)} mm')
	
	# ajustement vertical
	time.sleep(0.2)
	# ~ deplacement(int(0.2/C),1)
	time.sleep(0.2)
	z_0 = return_position(1) # en mm
	print(f'z_0 = {round(z_0,3)} mm')
	# enregistrer position et image
	save_path = rep + "/centre.jpg"
	capture_image(camera_index, save_path, width, height)
	
	Sensibilite = d_pix/pas # pix/mm
	print(f'Sensibilite = {round(Sensibilite,3)} pix/mm')
	
	y_BD = 9+4-pas_CBD
	print(f'y_BD = {round(y_BD,3)} mm')
	
	# ~ fichier.write(f"milieu anche = {y_0} \mm")
	return (y_0, z_0, y_BD, Sensibilite)
