# Rando-app — Application d'itinérance en montagne

Trouver les points d'eau, la réglementation de bivouac et les campings sur un massif de montagne, en un seul endroit, sans compte ni pub.

![status](https://img.shields.io/badge/statut-en%20d%C3%A9veloppement-yellow)
![licence](https://img.shields.io/badge/licence-MIT-blue)

## Pourquoi ce projet

Lors d'une semaine de bivouac, plusieurs problématiques sont apparues, sans solution réelle chez les applications d'itinérance actuelles :

- Où se situent les points d'eau ?
- Quelles sont les restrictions liées au bivouac, selon le massif ?
- Quels restaurants, bars et magasins sont ouverts à proximité ?

L'idée : un format communautaire, sur le modèle de Waze pour les automobilistes — chaque spot tenu à jour par les utilisateurs eux-mêmes, de nouveaux spots partagés au fil des sorties, l'affluence suivie en temps réel.

Pour plus de détail voir docs/analyse-marché.md

## État actuel : Sprint 0 (fondations)

Le projet est en phase d'installation des fondations techniques (Docker, PostgreSQL + PostGIS, dépôt Git) — pas encore en développement fonctionnel. Détail complet dans [`DEVLOG.md`](./DEVLOG.md).

- [ ] Import et affichage des points d'eau (source : refuges.info + OSM)
- [ ] Base de la réglementation bivouac (11 parcs nationaux, France)
- [ ] Contribution utilisateur (état d'un point d'eau)
- [ ] Mode hors ligne
- [ ] Import GPX

## Stack technique

| Couche | Choix | Pourquoi |
|---|---|---|
| Backend | FastAPI | Léger, typé, documentation interactive générée automatiquement |
| Base de données | PostgreSQL + PostGIS | Requêtes spatiales natives (distance, containance, superposition de zones) |
| Frontend carte | MapLibre GL + PMTiles | Coût d'egress quasi nul comparé à Mapbox/Google |
| Web / offline (V0) | PWA (Service Worker) | Cache hors-ligne opérationnel en ~2 semaines contre 8-10 en natif ; le modèle et l'API sont réutilisés à 100 % en cas de passage au natif ensuite |
| Mobile natif (V2, différé) | React Native (Expo), non commencé | Envisagé seulement après validation de la V0 |

## Installation locale

```bash
git clone <repo>
cd <repo>
cp .env.example .env      # renseigner les variables (voir ci-dessous)
docker compose up -d      # lance postgres+postgis, redis, api
```

Variables d'environnement (voir `.env.example` pour le détail complet) :