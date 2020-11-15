[![pipeline status](https://gaufre.informatique.univ-paris-diderot.fr/EmileRolley/pf5/badges/master/pipeline.svg)](https://gaufre.informatique.univ-paris-diderot.fr/EmileRolley/pf5/commits/master)

# Projet PF5 2020 : L-systèmes

## Prérequis à installer

Voir [INSTALL.md](../INSTALL.md)

  - ocaml évidemment
  - dune et make sont fortement conseillés
  - bibliothèque graphics si elle ne vient pas déjà avec ocaml
  - [OUnit2](https://github.com/gildor478/ounit) pour les tests unitaires.
(`opam install ounit2`)
  - [bimage](https://github.com/zshipko/ocaml-bimage) pour la sauvegarde des images.

## Compilation et lancement

Par défaut, `make` est seulement utilisé pour abréger les commandes `dune` (voir `Makefile` pour plus de détails):

  - `make` sans argument lancera la compilation `dune` de `main.exe`,
    c'est-à-dire votre programme en code natif.

  - `make byte` compilera si besoin en bytecode, utile pour faire
    tourner votre code dans un toplevel OCaml, voir `lsystems.top`.

  - `make clean` pour effacer le répertoire provisoire `_build`
    produit par `dune` lors de ses compilations.

Enfin pour lancer votre programme: `./run arg1 arg2 ...`

