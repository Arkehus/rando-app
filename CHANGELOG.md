# Changelog

Format basé sur [Keep a Changelog](https://keepachangelog.com/fr/1.1.0/),
versionnage selon [Semantic Versioning](https://semver.org/lang/fr/).

Ce fichier liste ce qui change **pour l'utilisateur final du dépôt** (un
autre développeur, ou toi dans six mois qui clones le projet) — pas le
détail des décisions techniques, qui va dans `DEVLOG.md`.

## [Non publié]

### Ajouté
- Environnement de développement reproductible via Docker Compose
  (PostgreSQL 16 + PostGIS 3.4, Redis)
- Squelette API FastAPI avec endpoints `/health/` et `/health/db`
- Modèle de données complet : `source`, `poi`, `zone_reglementaire`,
  `regle_bivouac`, `observation`
- Migrations Alembic versionnées, avec extensions PostGIS et index
  spatiaux GIST créés automatiquement
- Séparation des privilèges Postgres : compte `api_readonly` (lecture
  seule) pour l'API, `etl_writer` réservé aux futurs scripts d'import
- Scripts de sauvegarde et de restauration, restauration testée sur une
  base entièrement détruite puis recréée
- Formatage et vérification automatique du code (Ruff)
- Premier test automatisé et intégration continue (GitHub Actions)

---

## [0.1.0] - à définir

Première version stable une fois le Sprint 1 (curation de la
réglementation bivouac des 11 parcs) livré.