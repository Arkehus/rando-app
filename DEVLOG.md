# Journal de développement

But de ce fichier : garder une trace honnête des décisions, des blocages et de ce qu'on a appris,
au moment où ça se passe — pas une reconstruction a posteriori qui embellit tout.
C'est le document que tu relis avant un entretien, pas celui que tu montres à un utilisateur.

Une entrée = une session ou une semaine de travail. Pas besoin d'écrire tous les jours ;
mieux vaut une bonne entrée par semaine qu'une entrée creuse par session.

Structure suggérée pour chaque entrée :
- **Fait** : ce qui a été livré, en une ou deux lignes factuelles
- **Décidé** : un choix technique et pourquoi (le "pourquoi" est ce qui a de la valeur)
- **Bloqué** : ce qui n'a pas marché, et ce que tu as essayé
- **Appris** : une compétence, un concept, une erreur de raisonnement corrigée
- **Prochaine étape** : 1 à 3 items, pas une liste de 20

---
## Roadmap - V0
La V0 a pour but de tester l'intêret pour ces informations autour d'une même application en ciblant précisement les informations autour d'un seul massif. Les informations seront : 
- Réglementation Bivouac : France et 11 parcs nationaux
- Points d'eau : 1 massif
- Refuges + contacts : 1 massif
- Campings : 1 massif + périphérie
- Commerces : 1 massifs + villages traversés.

L'idée est de construire une application répondant à un réel besoin de manière à apprendre toutes les phases du developpement d'application, combiné avec une analyse business en découvrant comment l'IA peut être un outil accompagnant dans l'apprentissage pour réduire le risque de fail, de bug et obtenir des projets cohérent et structurés. 

#	Étape Sprint 0  	Résultat vérifiable
1	Outillage et décisions	: 9 outils répondent, massif choisi
2	Protection et dépôt Git	:	git status ne montre pas .env
3	Base de données Docker	:	docker compose ps → 2 services sains
4	DBeaver et QGIS	:	3 points affichés au bon endroit sur une carte
5–6	Squelette FastAPI	:	/health/db renvoie la version PostGIS
7	Ruff et Makefile	:	ruff check . sans erreur
8–9	Modélisation	:	Schéma validé par les 5 questions + 2 ADR
9	Migrations et index	:	alembic upgrade head sur base vierge
10	Sécurité et sauvegardes	:	Restauration testée et chronométrée
10	Tests et CI	:	CI au vert sur un push


## 2026-08-07 - Etape 0

**Fait**
Installation de Homebrew; Git via Brew; Docker + compose; python 3,12; Dbeaver; Qgis; Ruff

**Décidé**
4 version de python étaient installées. La version miniconda prenait le dessus. J'ai décidé de la désactiver, pour ne plus avoir la priorité sur les autres version Xcode et Python officiel.
Au lieu de forcer l'exécution de la version python 3.12, forcage d'utilisation de cette version face à la plus récente lors de la création de l'environnement. 
Attendre l'initialisation du projet pour installer PostgreSQL et PostGIS

Choix du Massif pilote : Écrins, car grosse densité de randonneur sur la période juillet et aout, réglementation complexe, pratique récente de randonnées sur ce massif, forte possibilité de vérification terrain.
Python 3.12 : Version stable car sortie en 2023, mise à jour jusqu'en 2028. 
Version Web PWA : Choix de développer une première version web pour réduire le temps de développement de la version 0, pour tester la réelle demande. 
**Bloqué**
Installationd de PostgreSQL et Post GIS : l'installation demande d'avoir initialiser le projet pour l'installer sans compromettre la sécurité. Déterminer l'ordre d'installation  des autres outils est le vrai enjeu pour la suite du projet. 

**Appris**
Comment installer et utiliser la dépendance Homebrew, à la place de Xcode directement. 
Lister l'ordre de priorité d'un même programme installé deux fois sur via Xcode et Brew (which -a git). Le Git apple; version antérieur, prend le dessus sur la version brew via (git --version puis which git). 
Ne pas désinstaller une version Xcode afin de ne pas créer de problème avec d'autres extensions. 
Lorsque trop d'outils installés sur une machine, gagner la dominance dans le Path n'est plus intéressant pour la version générique. Il faut rendre les projets indépendants de cette ambiguité. 
Un outil n'écrit rien dans le dossier d'un projet n'a aucune dépendance d'ordre. Il s'installe quand on veut. 

**Prochaine étape**
- [ ] Dédoublonnage OSM / refuges.info sur la même zone (voir §3.1 du rapport de faisabilité)
- [ ] Ajouter le champ `date_import` pour tracer la fraîcheur des données

---

## 2026-08-07 - Etape 0

**Fait**
Mise en place du fichier .gitignore en premier commit. 
Connection à github et premier push. 
Création + commit + push des fichiers : README.md, LICENCE; .env.example; CLaude.md
Création de .env et vérification qu'il n'est jamais commit. 

**Décidé**

**Bloqué**
Les fichiers CLAUDE.md; .env.example; README.md étaient bloque dans "Staged Changes". Le commit ne passait pas et le push non plus. 
**Appris**
Comment Pull and Push sur Github.
Les quatres étapes d'un fichier : 
Dossier de travail  →  Indexé (staged)  →  Committé (local)  →  Poussé (GitHub)
     (le fichier          git add /           git commit          git push /
      existe sur           bouton +            bouton ✓            Sync Changes
      le disque)


**Prochaine étape**
- [ ] 

## 2026-08-07 - Etape 2

**Fait**
Mise en place de la base de donnée avec Docker. Création et configuration du fichier docker-compose.yml. 
Premier test avec la fonction db. 
Initialisation de redis. 

**Décidé**
Acceptation de l'émulation de db avec l'image officielle pour assurer la fiabilitée dans la durée, malgré la lenteur ajoutée. Ajout de : "platform: linux/amd64  " pour accepter l'avertissement. 

**Bloqué**
Lors de l'initiatilation avec db, une erreur de compatibilité ressort lié à l'utilisation de Puce Apple silcon. Cela créer un ralentissement du système mais il fonctionne. 
Lors de l'initialisation de redis, le status healthy ne s'affiche pas causé par l'absence du healthycheck. 
Blocage lors de l'initalisation de QGIS avec des indication de navigation qui était pour le logiciel QGIS mais confondu avec le logiciel Dbeaver. 

**Appris**

## 2026-08-07 - Etape 3

**Fait**
Vérification du bon fonctionnement de la base de donnée. Utilisation d'une base test avec trois points (Paris, Alpes et random) visible via QGIS et le fond de carte OpenStreetMap. Après validation elle est supprimé via Dbeaver. 

**Décidé**
Insérer un fond de carte manuellement pour vérifier la justesse des points tests. Le fond de carte OpenStreetMap n'est pas installé nativement via Brew, il faut donc l'ajouter. 

**Bloqué**
QGIS ne fournit pas de fond de carte.

**Appris**
Prendre l'habitude de vérifier la justesse des résultat après l'importe des coordonnées. 

## 2026-08-12 - Etape 4
**Fait**
1. fichier requirements.txt : initialiser les outils nécessaires
2. Dockerfile
3. config.py : lecture des variables d'environnement, avec valeur replis pour un lancement or DOCKER
4. db.py : Connection vers PostSQL
5. __init__.py dans /app/router
6. health.py : verifie que PostGRE répond avec une sécurité via "SELECT PostGIS_Version()" pour assurer que l'extension est activé et ne pas avoir un retour erreur imprecis. 
7. main.py : connect l'API au projet et renvoie une confirmation. 
8. ajout du service "api" dans docker-compose.yml

Construction de l'image via ces commandes : "
    1. docker compose build api; (Lit ton Dockerfile ligne par ligne : télécharge une base Linux+Python, copie requirements.txt, installe les librairies Python à l'intérieur de l'image (pip install), puis copie ton code (config.py, db.py, etc.) dans cette même image.)
    2. docker compose up -d; (éxécution du programme python)
    3. docker compose ps; (affiche de ce qui tourne dans le programme python "healthy")
    4. docker compose logs api (affiche chaque étape du programme avec l'état final "Application startup complete.")
    5. curl http://localhost:8000/health/db ()

**Décidé**
- construction des fichiers (main.py, health.py, config.py, db.py) et explication de chacun d'eux pour apprendre à les connections entre Docker, le réseau, les variables d'environnement, SQLAlchemy, PostGIS. 
- Système de maillage par dépendance : Walking Skeleton (requête HTTP → API → base de données → réponse )

**Bloqué**
- Construire l'image de l'API via les différentes commandes de Docker (confusion avec du SQL au lieu du terminale à la racine)
- enzomignot@macbook-air-de-enzo5 rando-app % curl http://localhost:8000/health/db
 {"status":"error","error":"name 'version' is not defined"}%     => fonction version n'était pas créait. 
**Appris**
Utiliser la dépendance FastAPI et SQLAlchemy
Verifier la définition de chaque fonction lors d'une erreur. 

## 2026-08-12 - Etape 5

**Fait**
- initialisation de Makefile dans la racine du projet : suivit des commandes passés
- création de pyproject.toml : configuration de Ruff pour le formatage des fichier python. 

**Décidé**

**Bloqué**

## 2026-08-13 - Etape 6

**Fait**
- Schématiser la structure de la base de donnée (Source; POI; Zone réglementaires; Règles Bivouac; Observations)
- Création du fichier base.py
- Création du fichier source.py 

- Répondre aux questions suivantes pour vérifier : 
    Quelles règles s'appliquent au point (6.5, 45.2) ?
    Quels points d'eau à moins de 2 km, non vérifiés depuis plus d'un an ?
    D'où vient l'information « ce refuge a 40 places », et sous quelle licence ?
    Quels POI proviennent d'OSM ? (nécessaire si la licence change un jour)
    Combien de POI n'ont jamais été vérifiés par un humain ?

- Choix de la structure 1 table ou 4. 
**Décidé**
- 1 seule table : 
    1. travaille une structure non apprise dans les cours classique de SQL
    2. La sécurité relative au SQL n'est plus présent, c'est-à-dire que Postgres accepte des lettre au lieu d'un nombre normalement attendu. La vérification ne passe plus par la base mais par le programme python directement. Le compromis entre la rigidité d'une base classique et la souplesse imposé par les applications. 
    3. Apprentissage de la compétence d'interroger à l'intérieur d'un JSON la base. 
    4. Permet de voir un cas courant dans différents systèmes. 

    - Choix de structurer "licence" avec Enum en ciblant le contenu toujours identique présent. Enum car double protection avec python et base et cohérence avec le schéma. Malgrè une difficulté supérieur par l'ajout ultérieur d'une migration Alembic, le choix est préféré face à Check. 

**Bloqué**

**Appris**

## 2026-08-14 - Etape 6
**Fait**
- création du fichier poi.py manuellement
- création du fichier des fichiers zone.py; observations.py; en collaboration avec claude AI car utilisation de fonctions déjà utilisés et explication de certaines notions différenciantes. 

**Décidé**
- table poi unique plutôt que quatre tables séparées, avec ton propre raisonnement corrigé en cours de route (le risque n'était pas dans les données, mais dans le code partagé).
- geography pour les points, geometry pour les zones — critère métrique vs topologique.
**Bloqué**
- SyntaxError sur une annotation doublement assignée, 
- NameError sur des imports oubliés (trois fois, à des endroits différents), 
- InvalidRequestError sur un __tablename__ manquant, ModuleNotFoundError sur un simple fichier mal nommé (observations.py vs observation.py).



**Appris**
- utiliser les class sur python. 
- Jouer avec la fonction Enum
- utiliser des fonctions avec créais dans d'autre programme dans un nouveau car présent dans un dossier spécifique
- Création de chaque fonction pour gérer la base de donnée présente sur une seule table. 
- Python ne révèle jamais qu'une seule erreur à la fois, celle qui bloque en premier
- la différence entre une contrainte qui protège réellement (String(255), Enum, ForeignKey) et une contrainte qui ne protège rien (JSONB acceptant "quarante" sans broncher) — et qui, de la base ou de l'API, doit porter la responsabilité dans chaque cas.

## 2026-08-13 - Etape 6

**Fait**
- Schématiser la structure de la base de donnée (Source; POI; Zone réglementaires; Règles Bivouac; Observations)
- Création du fichier base.py
- Création du fichier source.py 

- Répondre aux questions suivantes pour vérifier : 
    Quelles règles s'appliquent au point (6.5, 45.2) ?
    Quels points d'eau à moins de 2 km, non vérifiés depuis plus d'un an ?
    D'où vient l'information « ce refuge a 40 places », et sous quelle licence ?
    Quels POI proviennent d'OSM ? (nécessaire si la licence change un jour)
    Combien de POI n'ont jamais été vérifiés par un humain ?

- Choix de la structure 1 table ou 4. 
**Décidé**
- 1 seule table : 
    1. travaille une structure non apprise dans les cours classique de SQL
    2. La sécurité relative au SQL n'est plus présent, c'est-à-dire que Postgres accepte des lettre au lieu d'un nombre normalement attendu. La vérification ne passe plus par la base mais par le programme python directement. Le compromis entre la rigidité d'une base classique et la souplesse imposé par les applications. 
    3. Apprentissage de la compétence d'interroger à l'intérieur d'un JSON la base. 
    4. Permet de voir un cas courant dans différents systèmes. 

    - Choix de structurer "licence" avec Enum en ciblant le contenu toujours identique présent. Enum car double protection avec python et base et cohérence avec le schéma. Malgrè une difficulté supérieur par l'ajout ultérieur d'une migration Alembic, le choix est préféré face à Check. 

**Bloqué**

**Appris**

## 2026-08-14 - Etape 7
**Fait**
- Migrations Alembic fonctionnelles pour les cinq tables du schéma, avec extensions PostGIS et index GIST créés automatiquement.

**Décidé**
- le choix d'une liste blanche plutot qu'une liste noire car la liste noire oblige à connaitre ce qui doit être exclut en amont contrairement à la Blanche qui ne gère que ce qui est dans Base.metadata ce qui élimine le risque d'oubli. 
- Laisser GeoAlchemy2 gérer l'index car la déclaration manuelle à créer des conflits (duplicateTable). 

**Bloqué**
- Le déchiffrage des erreurs par CLaude AI nous a permis de relever un fichier migration trop lourd 700 lignes avec des noms de table qui n'existait pas. 

**Appris**
- --autogénérate compare ne regarde pas uniquement les modèles python utilisés et en déduit le SQL. Il lit l'état complet de la base réelle  et compare à tou ce que Base.metadata déclare. 