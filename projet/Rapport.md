# I. Identifiants :
nom: Rolley
prénom: Emile
identifiant Git Lab: @EmileRolley
numéro étudiant: 71802612

nom: Phol Asa
prénom: Rémy
identifiant Git Lab: @pholasa
numéro étudiant: 71803190

# II. Fonctionnalités :
Le projet est capable de :
	- dessiner étape par étape un L-Système en appuyant sur une touche (`a | l | j`)
	- revoir le dessin précédent du L-Système en appuyant sur une touche (`p | h | k`)
	- specifier un fichier .sys pour pouvoir le dessiner
	- redimensionner automatiquement le dessin
	- choisir la position où commencer le dessin
	- d'ajouter un dégradé de couleurs au dessin
	- d'ajouter une variation aléatoire au dessin 
	- de sauvegarder le dessin en une image png

# III. Compilation et exécution :
Pour avoir plus de détails sur la compilation et l'exécution du projet,
nous vous invitons à regarder le fichier README.md.

Bibliothèque externes ajoutés :
	-[OUnit2](https://github.com/gildor478/ounit) pour les tests unitaires.
	-[bimage](https://github.com/zshipko/ocaml-bimage) 
	-[bimage-unix](https://opam.ocaml.org/packages/bimage-unix/) pour la sauvegarde des images.

# IV. Découpage modulaire :

png.ml: 
	Ce module a pour but de transformer et sauvegarder l'interprétation graphique du 
	L-Système en une image png. Elle utilise les bibliothèques externe bimage et bimage-unix 
	pour faire cela.

test_systems.ml: 
	Ce module permet de gérer les tests liées à la création des L-Système 
	dans le projet. Elle utilise la bibliothèque OUnit2 pour les tests.

system.ml: 
	Ce module permet de gérer tout les calculs fait sur les L-Systèmes de la création
	du L-Système à partir d'un fichier .sys, au calcul des évolutions du L-Système.

turtle.ml:
	Ce module à pour but de gérer l'interprétation graphique d'un L-Système en ajoutant
	éventuellement de la couleur ou alors des variations aléatoires au dessin.
	
main.ml:
	Ce module permet de gérer les différentes options possible et de lancer
	l'application.

V. Organisation du travail :
Au début du projet, les tâches ont été réparties de cette manière :
	Rémy : 
		- Calcul de l'évolution suivante du L-Système.
		- La version basique de la Tortue.
		- Interprètation graphique un L-Système donné.
		
	Emile : 
		- Installer le CI/CD ainsi les tests unitaires du projet.
		- Diviser le projet en plusieurs packages.
		- Parser un fichier .sys en un L-Système utilisable par le projet.
		- Redimensionner automatiquement une interprétations de L-Système.
		- Première version du main avec la gestion des options

Vers le milieu du projet :
	Rémy :
		- Variation aléatoire dans l'interprétation graphique.
		- Possibilité d'avancer ou revenir en arrière dans l'évolution .
	
	Emile :
		- Sauvegarde de l'interprétation courrante en une image png en noir et blanc.
		- Couleur rouge avec dégradé pour l'interprétation de la Tortue.
	
Vers la fin du projet :
	Rémy :
		- Ajouter plusieurs couleurs à la Tortue à la place d'une seule
		- Modifier certaines fonctions en un style réccursif
	Emile : 
		- Nettoyer le Parser
		- Refactoriser certaines fonctions
		- Ajout de la sauvegarde des interprétations en couleurs.


















