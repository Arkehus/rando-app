# [Nom du projet] — Application d'itinérance en montagne

> Une phrase qui dit ce que fait le projet et pour qui, pas ce qu'il "vise à révolutionner".
> Ex : *Trouver les points d'eau, la réglementation de bivouac et les campings sur un massif de montagne, en un seul endroit, sans compte ni pub.*

![status](https://img.shields.io/badge/statut-en%20d%C3%A9veloppement-yellow)
![licence](https://img.shields.io/badge/licence-MIT-blue)

## Pourquoi ce projet

2 à 3 phrases sur le problème (le vécu terrain qui a déclenché l'idée), pas sur la solution.
Renvoie vers `docs/analyse-marche.md` si tu as un rapport plus long — ne le colle pas ici.

## Périmètre actuel

Sois honnête sur ce qui est fait vs prévu. C'est ce qui distingue un README crédible d'un pitch.

- [x] Import et affichage des points d'eau (source : refuges.info + OSM)
- [x] Base de la réglementation bivouac (11 parcs nationaux, France)
- [ ] Contribution utilisateur (état d'un point d'eau)
- [ ] Mode hors ligne
- [ ] Import GPX

> Le détail complet de la roadmap est dans [`DEVLOG.md`](./DEVLOG.md) et les tickets [Issues](../../issues).

## Stack technique

| Couche | Choix | Pourquoi (1 ligne, lien vers le DEVLOG si la décision a été débattue) |
|---|---|---|
| Backend | FastAPI | — |
| Base de données | PostgreSQL + PostGIS | Requêtes spatiales natives, voir [DEVLOG 2026-08-05](./DEVLOG.md#2026-08-05) |
| Frontend carte | MapLibre GL + PMTiles | Coût d'egress nul vs Mapbox, voir DEVLOG |
| Mobile | React Native (Expo) | — |

## Installation locale

```bash
git clone <repo>
cd <repo>
cp .env.example .env      # renseigner les variables (voir ci-dessous)
docker compose up -d      # lance postgres+postgis, redis, api
```

Variables d'environnement minimales :

```
DATABASE_URL=
REDIS_URL=
```

## Structure du dépôt

```
/api          backend FastAPI
/etl          scripts d'ingestion des sources (OSM, refuges.info, DATAtourisme)
/mobile       app React Native
/docs         rapports, schémas de données, décisions d'architecture
CHANGELOG.md  historique des versions livrées
DEVLOG.md     journal de développement (décisions, blocages, apprentissages)
```

## Sources de données et licences

À maintenir à jour — c'est un point de vigilance juridique, pas un détail.

| Source | Licence | Usage |
|---|---|---|
| OpenStreetMap | ODbL | Points d'eau, commerces |
| refuges.info | CC BY-SA 2.0 | Refuges, points d'eau montagne |
| DATAtourisme | Licence Ouverte / Etalab | Campings, hébergements |

## Contribuer

Voir [`CONTRIBUTING.md`](./CONTRIBUTING.md) si le projet est ouvert à des contributions externes.
Sinon, retire cette section.

## Licence

[MIT](./LICENSE) — ou la licence choisie. Justifie le choix dans le DEVLOG si tu hésites entre plusieurs.
