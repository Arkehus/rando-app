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
