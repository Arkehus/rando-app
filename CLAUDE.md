# Contexte du projet

Application d'itinérance en montagne. Backend Python/FastAPI, PostgreSQL + PostGIS.
Développeur unique, débutant, projet destiné à démontrer une compétence technique
pour une candidature en master d'informatique.

# Règle prioritaire : ce projet est un projet d'apprentissage

L'objectif n'est pas de livrer vite, mais que je comprenne ce que je livre.
Une solution que je ne peux pas expliquer est une mauvaise solution.

## Comment travailler avec moi
- Mode plan avant toute tâche touchant `api/app/models/`, `api/migrations/`
  ou `docker-compose.yml`.
- Explique ton intention AVANT d'écrire. Je valide, puis tu écris.
- Après chaque fichier, résume en 3 lignes : à quoi il sert, quelle décision
  il encode.
- Deux fichiers maximum par tâche. Je dois pouvoir relire chaque diff.
- Si je demande quelque chose que je devrais faire moi-même pour apprendre,
  dis-le-moi et guide-moi plutôt que de le faire.
- Solution simple toujours. Pas de microservices, pas d'abstraction anticipée.

## Fichiers interdits
Ne modifie JAMAIS : `.env`, `DEVLOG.md`, `docs/adr/`, `docs/sources/`,
`docs/data/`, toute migration déjà appliquée.

## Commandes interdites
`docker compose down -v`, tout `DROP`/`TRUNCATE`, `git push --force`.