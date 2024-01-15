# Mutify

Appication Flutter qui permet de chercher des artistes et leurs musiques pour en écouter une partie

## Pré-requis

Flutter : 3.13.9

## Installation

1. Cloner le projet
2. utliser  la commande suivante pour installer les packages requis

```bash
flutter pub get
```

## Fonctionnalités

- API : https://api.spotify.com

- Artiste :
  - Rechercher un artiste
  - Sauvegarder un artiste
  - Supprimer un artiste
- Titre :
  - Rechercher un titre
  - Sauvegarder un titre
  - Supprimer un titre
  - Jouer un titre :
    - Se déplacer de titre en titre
    - Mettre sur pause/play
    - Aller à un temps precis d'une musique
    - recommencer depuis le debut

## Bugs rencontrés

Lecture de musique :
- Certaines musiques n'ont pas de Preview disponible (extrait de 30 sec libre d'accès : depuis 2013 sur spotify)
- Avoir une musique sans preview comme derniere musique peut causer :
  - symbole de chargement infini
  - plantage : probleme de duree et de position
