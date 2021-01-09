# Projet PF5 2020 : L-systèmes

[![pipeline status](https://gaufre.informatique.univ-paris-diderot.fr/EmileRolley/pf5/badges/master/pipeline.svg)](https://gaufre.informatique.univ-paris-diderot.fr/EmileRolley/pf5/commits/master)

## Compilation

### Prérequis à installer

Voir [INSTALL.md](../INSTALL.md)

- ocaml évidemment
- dune et make sont fortement conseillés
- bibliothèque graphics si elle ne vient pas déjà avec ocaml
- [OUnit2](https://github.com/gildor478/ounit) pour les tests unitaires.
(`opam install ounit2`)
- [bimage](https://github.com/zshipko/ocaml-bimage) et [bimage-unix](https://opam.ocaml.org/packages/bimage-unix/)
pour la sauvegarde des images.

### Docker

Pour ne pas avoir à installer toutes les dépendances il est possible d'utiliser
l'image `Docker`

[emilerolley/opam2-dune](https://hub.docker.com/r/emilerolley/opam2-dune)

#### Comment l'utiliser

Pour récupérer l'image, utiliser :

```shell
> docker pull emilerolley/opam2-dune:latest
```

Pour pouvoir ouvrir la fenêtre de la lib `graphics`, utiliser :

```shell
> docker run --rm -ti --net=host -e DISPLAY emilerolley/opam2-dune
```

### Make

Liste des commandes `Make` disponible :

- `make` compile l'exécutable *./_build/default/main/main.exe*.

- `make test` compile et exécute les tests unitaires.

- `make clean` efface le répertoire provisoire `_build`
    produit par `dune` lors de ses compilations.

### Lancement

Pour lancer l'exécutable, `./run arg1 arg2 ...`.
