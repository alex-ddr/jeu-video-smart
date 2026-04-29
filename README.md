# 🎮 Projet Godot - Conventions et Architecture

Ce document définit les standards de code, de nommage et d'architecture utilisés dans ce projet. L'objectif est de maintenir un projet propre, lisible, modulaire et optimisé pour le développement sur le long terme.

## 📁 1. Architecture du Projet (Feature-based)

Le projet est organisé par **fonctionnalités (Composants)**. Si une ressource (script, scène, sprite) est exclusive à une entité, elle doit vivre dans le dossier de cette entité. Ne pas faire de dossiers globaux "Scripts" ou "Scenes".

```text
res://
├── assets/               # Ressources brutes partagées (audio, polices, textures globales)
│   └── .gitkeep          # Fichier vide pour forcer Git à push ce dossier
│
├── core/                 # Fondations techniques et Autoloads
│   ├── constants.gd      # Dictionnaire global (class_name Constants)
│   └── game_manager.gd   # Autoload (GameManager) pour le score, la gestion des niveaux
│
├── entities/             # Acteurs dynamiques (Joueurs, Ennemis, PNJ)
│   └── player_duo/           
│       ├── PlayerDuo.tscn   # Scène parente (CharacterBody2D : Physique globale & Logique asymétrique)
│       ├── player_duo.gd     
│       ├── Player.tscn       # Scène enfant (Node2D : Visuel & Inputs individuels) instanciée 2x
│       └── player.gd         
│
└── levels/               # Salles de test et niveaux du jeu
	└── Level_01.tscn     
```

---
# 🏷️ Conventions de Nommage

Standard de nommage pour garantir la compatibilité technique (genre si on le met sur le web plus tard) et la clarté du projet.

| Élément | Format | Exemple |
| :--- | :--- | :--- |
| **Dossiers & Fichiers** | `snake_case` | `res://entities/player_duo.tscn` |
| **Nœuds** | `PascalCase` | Donc une instance de `player.tscn` devient le nœud `Player`. |
| **Nœuds Enfants** | `snake_case` | `p1_collision` |
| **Variables & Fonctions** | `snake_case` | `velocity`, `_ready()` |
| **Constantes** | `UPPER_SNAKE_CASE` | `MAX_SPEED` |

### Input Map (Contrôles)
* **Format :** `[joueur]_[action]` en `snake_case`.
* **Exemples :** `p1_up`, `p2_left`.

---

## 📝 3. Principes de Développement et GDScript

### Utilisation de `@export` (Game Design)
Ne mettre des @export que quand c'est quelque chose qui sera souvent changé à chaque instance. Ne pas en abuser car on peut vite perdre le fil entre ce qui est écrit dans le fichier et ce qu'on a défini dans la scène.
```gdscript
@export var variable: float = 2.0
```

### Physique et Mouvements
* **Indépendance au Framerate (`delta`) :** Toute animation, déformation ou changement de vitesse doit être multiplié par `delta` pour s'adapter à la puissance du PC du joueur.
* **Mouvements Fluides :** Pas de changements secs. Utilisez `move_toward()` pour la vélocité et `lerp()` pour les transformations fluides (comme l'étirement élastique).

### Indépendance des Ressources (Ressources Partagées)
Si la taille d'une zone de collision (`RectangleShape2D`) doit être modifiée en plein jeu pour un personnage spécifique, la forme doit d'abord être rendue unique dans le `_ready()` pour ne pas affecter les autres instances.
```gdscript
p1_collision.shape = p1_collision.shape.duplicate()
```
