# ozproject
ozproject

Le design :

gameserver <----> trainer <-----> Gui / TrainerBot

Le Gui c'est pour le joueur principale et le trainerBot c'est pour les trainer en plus sur la map.

-------------------------------------------------
22/04

TODOs :

1)
	- TrainerMan (joueur / GUI)
	- TrainerAuto (joueur / auto)
	- TrainerNPC (pnj)
	-  --> Toutes des instances de port object Trainer

2)
	- Pokémoz en port object
	- Pokémoz list

3)
	- Combat (conditions de délenchement)
	-  --> Paramètres de TrainerNPC

4)
	- Map chargée depuis file

5)
	- Combat log


-------------------------------------------------

Ce qui doit encore être fait :

- Les combats entre trainer
- Pouvoir gagner la partie
- Bien gérer les paramètres en entrée (hardcodé à moitier pour l'instant)
- Intelligence des trainerBot pour l'instant purement aléatoire (si on a le temps )
- Musique

Ce qui est fait :

- Combat contre les wild pokemoz
- Déplacement
- Perdre quand pokemoz est à 0 hp
- Pokemoz gagne de l'experience et lvl up 

Si tu vois des trucs à rajouter n'hésite pas.
