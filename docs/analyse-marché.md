# Rapport de faisabilité — Application d'itinérance en montagne
### Analyse marché, contraintes techniques, scaling, communauté et coûts

**Rédigé du point de vue d'un développeur accompagnant l'équipe produit/marketing.**
Chaque recommandation est argumentée : ce qui est techniquement possible, ce qui ne l'est pas, et le compromis retenu pour une V1 livrable.

Date : août 2026

---

## 0. Résumé exécutif (à lire même si tu ne lis rien d'autre)

**Le constat de départ est juste, mais la conclusion doit être nuancée.** Aucune application ne regroupe tes 7 problématiques — mais ce n'est pas un oubli du marché. C'est le résultat de trois obstacles structurels :

1. **Les 7 problématiques n'ont pas la même nature technique.** Trois relèvent de la donnée statique (facile, déjà en open data), deux de la donnée semi-statique juridique (coûteux, non disponible), deux du temps réel communautaire (impossible sans masse critique d'utilisateurs). Les regrouper dans une seule app, c'est empiler trois modèles économiques et trois difficultés d'ingénierie très différents.
2. **La donnée qui a le plus de valeur (affluence, disponibilité, réglementation locale) est précisément celle qui n'existe nulle part**, et qu'il faut donc produire soi-même — soit par la communauté (problème de démarrage à froid), soit par un travail manuel de curation (problème de coût).
3. **L'agrégation seule n'est pas un moat.** Si tu ne fais que rassembler OpenStreetMap + refuges.info + DATAtourisme, un concurrent te copie en 3 semaines. La défensibilité vient de la donnée fraîche que toi seul possèdes.

**Ce que je recommande :** ne pas construire l'agrégateur des 7 problématiques. Construire **un outil vertical sur l'itinérance multi-jours (2 à 10 jours)** — le segment où le besoin est le plus douloureux et le moins servi — sur **un seul massif**, avec **deux** problématiques traitées vraiment bien (eau + réglementation bivouac), et les autres traitées en "best effort" avec de l'open data. Puis élargir massif par massif.

**Coût d'infrastructure réel :** ~50 €/mois en pilote, ~500 €/mois à 50 000 utilisateurs actifs mensuels, ~4 000 €/mois à 500 000. **Ce n'est pas là que se joue ton budget.** Le vrai coût est humain : curation et modération des données.

**Fenêtre de marché :** elle est réellement ouverte en ce moment. Komoot a été racheté par Bending Spoons en mars 2025 (~300 M€) avec licenciement d'environ 75 à 85 % des équipes et passage de fonctionnalités historiques derrière un abonnement Premium. AllTrails est détenu par le fonds Permira depuis 2023 avec une dérive premium comparable. Une part significative de la communauté outdoor cherche activement des alternatives non extractives. C'est un argument de positionnement, pas un argument technique — mais c'est ton meilleur angle marketing.

---

## 1. Cadrage : traduire les 7 problématiques en objets techniques

C'est l'étape que la plupart des porteurs de projet sautent, et c'est celle qui détermine tout le reste. Une "fonctionnalité" n'a pas de coût — une **donnée** en a un, qui dépend de sa fraîcheur exigée et de son mode de production.

| # | Problématique | Nature de la donnée | Fraîcheur exigée | Source disponible ? | Difficulté | Dépend de la communauté ? |
|---|---|---|---|---|---|---|
| 1 | Points d'eau | Statique géolocalisée + état saisonnier | Saison | ✅ OSM, refuges.info, BD Carthage/IGN | ⭐⭐ Faible | Partiellement (état) |
| 2 | Refuges : places + tarifs | Semi-statique (tarifs) + **temps réel** (dispo) | Jour | ❌ Aucune API centralisée | ⭐⭐⭐⭐⭐ Très élevée | Non (dépend des gardiens) |
| 3 | Affluence sur un spot de bivouac | **Temps réel déclaratif** | Heure | ❌ N'existe pas | ⭐⭐⭐⭐⭐ Très élevée | **Totalement** |
| 4 | Règles de bivouac locales | Semi-statique **juridique** zonée | Année | ❌ Éclaté sur 100+ sites | ⭐⭐⭐⭐ Élevée | Non (curation manuelle) |
| 5 | Commerces / restos ouverts | Statique + horaires (peu fiables) | Semaine | ⚠️ OSM (couverture inégale) | ⭐⭐ Faible | Oui (correction horaires) |
| 6 | Affluence d'un parcours depuis GPX | **Statistique inférée** | Jour | ❌ Non licenciable | ⭐⭐⭐⭐⭐ Très élevée | Oui + modèle |
| 7 | Campings à proximité | Statique | Mois | ✅ DATAtourisme, OSM | ⭐ Très faible | Non |

### Lecture stratégique de ce tableau

- **Ligne 1, 5, 7 : c'est de l'intégration, pas de l'innovation.** Faisable en quelques semaines. Nécessaire pour que l'app soit utile, mais aucune valeur défensive. À faire vite et bien, sans y passer 6 mois.
- **Ligne 4 : c'est ton vrai actif.** Personne n'a constitué une base structurée, géo-zonée et à jour de la réglementation bivouac française. C'est un travail de fourmi (donc coûteux, donc peu copiable), c'est ce qui manque le plus au randonneur, et c'est **entièrement réalisable sans utilisateurs** — donc sans problème de démarrage à froid. **C'est par là qu'il faut commencer.**
- **Lignes 3 et 6 : ce sont les fonctionnalités "Waze".** Elles ne fonctionnent qu'à partir d'une densité d'utilisateurs que tu n'auras pas avant 18 mois. Les promettre en V1 est le meilleur moyen de décevoir. Les concevoir dès maintenant dans l'architecture est en revanche indispensable.
- **Ligne 2 : à sortir du périmètre V1.** Explication détaillée en §3.2 — c'est un piège.

---

## 2. Analyse du marché existant

### 2.1 Cartographie concurrentielle

Le marché n'est pas "un marché de la rando" : c'est **cinq marchés distincts** qui se recouvrent partiellement.

| Segment | Acteurs | Modèle | Force | Faille exploitable |
|---|---|---|---|---|
| **Planification & inspiration** | Komoot, AllTrails, Visorando, Wikiloc, Openrunner | Freemium / abonnement | Base d'itinéraires massive, SEO, communauté | Pensés pour la sortie à la journée. Aucune logique d'itinérance (ravitaillement, eau, nuit) |
| **Navigation & cartographie** | iPhiGéNie, IGN Rando, Gaia GPS, Organic Maps / CoMaps, Topo GPS | Achat unique / abonnement | Fond de carte, offline solide | Cartes seules : aucune donnée "vivante" (affluence, ouverture, règles) |
| **Données terrain communautaires** | **refuges.info**, camptocamp, Dors Dehors | Associatif / open data | Données de très bonne qualité, licences ouvertes, communauté engagée | UX web datée, pas d'app native aboutie, périmètre limité (montagne), pas de temps réel |
| **Hébergement outdoor** | Park4Night, iOverlander, Homecamper, Campings.com | Freemium + abonnement | **Preuve que le modèle contributif fonctionne** (Park4Night = référence absolue en van) | Orientés véhicule/route. Inutilisables à pied en altitude |
| **Réservation refuge** | FFCAM, centrales régionales, sites individuels | Commission | Détiennent la disponibilité réelle | Fragmentation totale, pas d'API publique, technologiquement en retard |

### 2.2 La dynamique de marché actuelle : une vraie fenêtre

Trois faits récents à connaître et à utiliser dans ton pitch :

- **Komoot (45 millions d'utilisateurs annoncés, leader européen) a été racheté par Bending Spoons en mars 2025** pour près de 300 M€. Bending Spoons applique un schéma documenté et répété (Evernote, WeTransfer, Meetup, Vimeo, AOL) : rachat d'un produit mature, licenciements massifs, hausse des prix. Chez Komoot, la fonction "Send to Device" est passée derrière un abonnement Premium (~60 €/an) pour tous les nouveaux comptes, et les packs de région à l'unité ont été supprimés pour les nouveaux utilisateurs.
- **AllTrails est détenu par Permira depuis 2023**, avec une multiplication des fonctions payantes largement critiquée par sa base historique.
- **Il en résulte une demande explicite d'alternatives** dans la communauté (blogs spécialisés, forums de rando légère), avec un intérêt marqué pour les solutions open source et open data.

**Traduction produit :** ton positionnement le plus crédible n'est pas "l'app qui fait tout", c'est **"l'app d'itinérance qui ne trahira pas ses utilisateurs"** — données ouvertes, pas de tracking, prix lisible. C'est aussi le positionnement qui te permet d'obtenir gratuitement les partenariats data (parcs, refuges.info, offices de tourisme) qu'une app purement commerciale n'obtiendrait pas.

### 2.3 Concurrents directs à surveiller de près

- **refuges.info** — API publique gratuite, sans authentification, en lecture seule, données sous CC BY-SA 2.0 (avec possibilité de retour de données OSM en ODbL via la recherche). C'est à la fois ta **meilleure source** et ton concurrent le plus proche sur le périmètre refuges/points d'eau. Ne cherche pas à les concurrencer : construis dessus et contribue en retour. Une app qui pille une association contributive sans rien rendre se fait détruire publiquement par la communauté.
- **Dors Dehors** — carte collaborative refuges/bivouacs/points d'eau, croisement de ~18 sources, API publique, positionnement open source et sans publicité, ~7 000 refuges recensés. **C'est le concurrent le plus proche de ton idée initiale.** À analyser en profondeur : ce qu'ils couvrent bien, ce qu'ils ne font pas (a priori : pas de temps réel, pas de réglementation opposable, pas de logique d'itinérance multi-jours).
- **Park4Night** — le modèle contributif à étudier ligne par ligne. Ce qu'il faut en retirer : leur croissance est venue d'une **niche géographique + une communauté ultra-motivée**, pas d'une couverture mondiale d'emblée.

### 2.4 Pourquoi personne ne l'a fait — la réponse honnête

À dire clairement dans ton dossier de candidature, parce que c'est ce qui montre de la maturité :

1. **Le TAM est petit.** Le randonneur itinérant multi-jours en France, c'est de l'ordre de quelques centaines de milliers de personnes, avec une saisonnalité brutale (juin–septembre). Difficile de justifier une levée de fonds. **Mais c'est parfait pour un projet étudiant** : pas de géant qui viendra t'écraser.
2. **Le coût marginal de la donnée juridique est linéaire, pas logarithmique.** Chaque nouveau massif = du travail humain de curation. Ça ne "scale" pas comme un logiciel classique. C'est rédhibitoire pour un VC, c'est acceptable pour un projet patient et associatif.
3. **La responsabilité juridique fait peur.** Dire "cette eau est potable" ou "vous pouvez bivouaquer ici" engage. Les gros acteurs évitent. Voir §6.

---

## 3. Contraintes techniques, problématique par problématique

Pour chacune : la source, la limite réelle, et la solution retenue pour une V1.

### 3.1 Points d'eau

**Sources mobilisables**
- **OpenStreetMap via Overpass API** : tags `amenity=drinking_water`, `natural=spring`, `man_made=water_tap`, `amenity=water_point`, `man_made=water_well`. Licence ODbL.
- **refuges.info API** (`GET /api/bbox`, `GET /api/massif`) : points d'eau qualifiés par la communauté montagne, CC BY-SA 2.0.
- **BD TOPO / BD Carthage (IGN)** via la Géoplateforme (`data.geopf.fr`) : hydrographie, sources. Données publiques IGN libres et gratuites.
- **SISE-Eaux (ARS, data.gouv.fr)** : résultats de contrôle sanitaire des eaux distribuées — utile uniquement pour les points raccordés au réseau public (fontaines de village), inutile en altitude.

**Limites techniques réelles**

1. **Overpass n'est pas une base de production.** L'API est rate-limitée, sans SLA, et son usage est explicitement destiné à des requêtes ponctuelles. Une app qui interroge Overpass à chaque ouverture de carte se fera bloquer, et sera hors service dès que l'instance publique tombe.
   → **Solution :** ingestion périodique. On télécharge un extrait `.osm.pbf` (Geofabrik) et on l'importe dans PostGIS avec `osm2pgsql` ou `pyrosm`, en filtrant sur les tags utiles. Rafraîchissement hebdomadaire par cron. On sert ensuite depuis **notre** base. Overpass ne sert qu'en outil de développement et de contrôle qualité.

2. **La géométrie n'est pas l'information utile.** Une source cartographiée en 2013 peut être tarie depuis 2019. En août, c'est exactement l'information qui compte. **La position est un problème résolu ; l'état ne l'est pas.**
   → **Solution :** modèle à deux couches. Couche A = référentiel géométrique (open data, stable). Couche B = **observations horodatées** produites par les utilisateurs (`débit : bon / filet / à sec`, `date`, `auteur`, `photo`). L'UI n'affiche jamais un point "brut" : elle affiche *« Source du Pas — coulait bien, vérifié il y a 6 jours par 2 personnes »* ou *« aucune observation depuis 2 ans »*. **Cette distinction est le cœur technique du produit.**

3. **Le mot "potable" est un risque juridique majeur.** Aucune source non contrôlée par une ARS ne peut être déclarée potable, et une intoxication attribuée à ton app serait un problème existentiel.
   → **Solution :** modèle à trois états, jamais binaire :
   - `réseau_controle` — eau du réseau public (fontaine communale), avec mention de la source du contrôle ;
   - `naturel_non_controle` — **filtration ou traitement recommandé** (mention affichée systématiquement, non désactivable) ;
   - `deconseille` — signalements (troupeau en amont, mort d'animal, pollution).
   Plus une CGU explicite et une décharge non contournable au premier lancement.

4. **Le dédoublonnage multi-sources.** La même fontaine existe dans OSM, refuges.info et la BD TOPO, à 15 m d'écart, avec trois noms différents.
   → **Solution :** pipeline de *conflation* avec **provenance au niveau de l'attribut** (et non de l'objet) :
   ```
   1. Appariement candidat : ST_DWithin(a.geom, b.geom, 50) sur index GIST
   2. Score de similarité : similarity(a.nom, b.nom) via pg_trgm + compatibilité de type
   3. Fusion : entité maître + table source_link (source, id_externe, attributs apportés)
   4. Résolution de conflit : ordre de priorité configurable
      observation_utilisateur_récente > refuges.info > OSM > IGN
   ```
   Conserver la provenance par attribut est **non négociable** : c'est ce qui permet de répondre à "d'où vient cette info ?", d'honorer les obligations d'attribution des licences, et de retirer proprement une source si sa licence change.

---

### 3.2 Refuges : places disponibles et tarifs — **à exclure de la V1**

C'est la fonctionnalité la plus demandée et **c'est un piège.** Argumentaire à opposer à l'équipe produit :

**Pourquoi c'est très difficile**
- **Aucune API centralisée n'existe.** La disponibilité vit dans des systèmes hétérogènes : plateforme FFCAM, centrales départementales, logiciels privés, et pour beaucoup de refuges… un cahier papier et un téléphone.
- **Le scraping est fragile et juridiquement exposé.** Techniquement : une réservation à 3 champs derrière un CAPTCHA ou un flux applicatif changeant casse à chaque refonte de site — on parle de dizaines de scrapers à maintenir individuellement. Juridiquement : le scraping de bases de données protégées engage le droit *sui generis* du producteur de bases de données (art. L341-1 CPI), et l'extraction d'une partie substantielle est sanctionnable. Ajoute la responsabilité produit : afficher "3 places libres" et envoyer quelqu'un marcher 6 heures vers un refuge complet, en montagne, à la tombée de la nuit, est un risque sécurité, pas un bug d'affichage.
- **Les tarifs changent chaque saison** et comportent une combinatoire (adhérent/non-adhérent, demi-pension, réciprocité, enfants) qui rend toute normalisation coûteuse.

**Solution V1 — assumer de ne pas donner la disponibilité**
- Fiche refuge riche mais **statique** : altitude, capacité totale, période de gardiennage, fourchette tarifaire indicative avec date de dernière mise à jour, téléphone, lien direct vers la page de réservation officielle.
- **Bouton "Appeler le gardien"** avec un rappel : ici, le téléphone est le canal le plus fiable, et l'app l'assume.
- Champ "dernière info connue" alimenté par les utilisateurs : *« complet le 12/08 selon un randonneur »* — donnée déclarative, présentée comme telle.

**Solution V2 — inverser le sens du flux**
Ne pas essayer d'aspirer la donnée des refuges : leur **donner un outil**. Une interface gardien minimaliste (une page web, un bouton "complet ce soir / places restantes") en échange d'une visibilité gratuite. C'est exactement le modèle qui a fonctionné pour les plateformes de réservation. C'est lent, ça se fait refuge par refuge, mais c'est la seule voie durable — et c'est un excellent sujet de partenariat pour un projet étudiant (10 refuges pilotes sur un massif suffisent à démontrer le concept).

---

### 3.3 Affluence sur un spot de bivouac — le problème "Waze"

**Le problème central : le démarrage à froid.** Waze n'a de valeur que si des conducteurs sont déjà sur la route. Ton spot de bivouac dans le Queyras un mardi de juin aura, au mieux, 3 utilisateurs de ton app. Avec 0 contributeur, la donnée est vide ; avec une donnée vide, personne ne revient.

**Aggravations spécifiques à la montagne**
- **Pas de réseau.** Le lieu même où l'utilisateur produit l'information est celui où il ne peut pas la transmettre. → **L'architecture doit être offline-first, ce n'est pas une option** (voir §4.3).
- **Fenêtre temporelle très étroite.** L'information "il y a 6 tentes ici" n'a de valeur qu'entre 16h et 20h. Passé ce délai, elle est bruit.
- **Densité d'utilisateurs structurellement faible.** Un carrefour urbain voit 10 000 véhicules/jour ; un col de montagne, 40 randonneurs.

**Contre-mesures techniques et produit**

1. **Concentration géographique extrême.** Ne pas lancer sur la France. Lancer sur **un massif, une saison** (ex. : GR20, ou Vanoise, ou Queyras). Sur un GR très fréquenté en juillet-août, la densité de randonneurs est suffisante pour amorcer la boucle. C'est exactement la stratégie Uber ville-par-ville.
2. **Réduire la friction de contribution à ~2 secondes.** Un unique geste : *« combien de tentes autour de toi ? »* → `0 / 1-3 / 4-10 / 10+`. Pas de formulaire, pas de photo obligatoire, pas de compte requis pour la première contribution (compte anonyme device-based, rattachable ensuite).
3. **Prompt contextuel.** Détection locale (sur l'appareil, sans envoi de données) : utilisateur immobile > 20 min, entre 17h et 21h, à > 1 km d'une route → notification locale unique. Le déclencheur est local, donc gratuit en serveur, et fonctionne hors ligne.
4. **Agrégation avec seuil de k-anonymat.** Ne jamais afficher une contribution individuelle. Agréger sur une cellule spatiale (grille **H3** résolution 9–10, ~150 m) et une fenêtre temporelle, et n'afficher qu'à partir de **n ≥ 3** contributions. Cela répond simultanément à un besoin de qualité statistique et à une exigence RGPD (voir §6.3).
5. **Amorçage par des proxies statiques.** Tant qu'il n'y a pas de données, ne pas afficher "aucune donnée" — afficher un **indice de pression estimé**, calculé sans utilisateurs à partir de : distance au parking le plus proche, capacité du parking, vacances scolaires, jour de la semaine, météo, présence sur un GR balisé, proximité d'un refuge. Un simple modèle de régression ou même un score heuristique pondéré suffit, à condition de **l'étiqueter honnêtement comme une estimation**.

**Ce qu'il ne faut pas faire :** le tracking passif en arrière-plan. Techniquement possible, mais : consommation de batterie inacceptable en itinérance (la batterie *est* une ressource vitale en autonomie), permission "toujours" très mal acceptée sur iOS, et exposition RGPD maximale. Le déclaratif est plus pauvre mais soutenable.

---

### 3.4 Règles de bivouac — le vrai actif du projet

**Constat :** il n'existe **aucun jeu de données ouvert, national et structuré** de la réglementation du bivouac. L'information est éclatée entre 11 parcs nationaux (chacun avec ses arrêtés propres), ~60 parcs naturels régionaux, des centaines de réserves naturelles, des arrêtés préfectoraux (risque incendie), et des arrêtés municipaux. Elle est publiée en PDF, en pages web, parfois en cartes statiques.

Et cette réglementation est extrêmement hétérogène :
- Vanoise : bivouac autorisé uniquement à proximité immédiate des refuges gardés, sur emplacements désignés, avec réservation auprès du gardien.
- Écrins : tente de petite taille, 19h–9h, à plus d'une heure de marche des limites du cœur ou d'une route, avec des exceptions localisées (lacs de la Muzelle, du Lauvitel).
- Cévennes : à la belle étoile, avec des tronçons de GR spécifiquement interdits.
- Calanques et Port-Cros : **interdiction totale**, toute l'année.
- Réserve intégrale du Néouvielle : interdit alors même qu'elle est incluse dans le cœur des Pyrénées où le bivouac est autorisé — **la réglementation n'est pas hiérarchique, elle se superpose.**

**Conséquence architecturale :** ce n'est pas une base de données de points, c'est un **moteur de règles géo-temporelles avec superposition de zones**.

```
Modèle de données proposé

zone_reglementaire
  id, geom (MULTIPOLYGON, SRID 4326, index GIST)
  type_zone          -- parc_national_coeur | pnr | reserve | commune | zone_incendie
  priorite           -- entier : la règle la plus restrictive/spécifique l'emporte
  autorite           -- entité émettrice
  source_url, source_document, date_arrete, date_verification, verifie_par

regle_bivouac
  zone_id
  statut             -- interdit | autorise_conditionne | autorise | inconnu
  heure_debut, heure_fin           -- ex. 19:00 → 09:00
  distance_min_route_m / duree_marche_min
  contraintes[]      -- tente_legere_uniquement | sans_tente | emplacement_designe
                     -- | reservation_obligatoire | feu_interdit | chien_interdit
  periode_validite   -- daterange (saisonnalité, arrêtés temporaires)
  texte_officiel     -- extrait littéral, jamais reformulé
```

Requête d'évaluation : `ST_Contains` sur toutes les zones contenant le point, tri par priorité décroissante, **et affichage de toutes les règles applicables** — pas seulement la plus prioritaire. Le randonneur doit voir la superposition.

**Limites à assumer**
- **La constitution initiale est manuelle.** Compter 2 à 4 semaines de travail à temps partiel pour couvrir sérieusement les 11 parcs nationaux. Une LLM peut aider à extraire les règles depuis les PDF d'arrêtés, mais **chaque règle doit être relue et validée à la main** : c'est du juridique, l'hallucination n'est pas une option. Les géométries des zones protégées, elles, sont récupérables en open data (INPN, data.gouv.fr, parcs nationaux).
- **La donnée périme.** Un arrêté préfectoral incendie change en 48h. Les Écrins ont mené une consultation en 2026 sur l'introduction de quotas.
  → Champ `date_verification` obligatoire, revue systématique en mai avant chaque saison, et affichage explicite : *« règle vérifiée le 12/05/2026 »*. Une règle non vérifiée depuis > 12 mois est dégradée visuellement.
- **Responsabilité.** Ne jamais écrire "vous pouvez bivouaquer ici". Écrire : *« Réglementation applicable : [texte], source : arrêté n°X du parc, lien officiel »*. Tu es un **agrégateur d'information sourcée**, pas un conseil juridique. La distinction est fondamentale dans les CGU.

**Pourquoi c'est le bon point de départ :** c'est le seul livrable qui a de la valeur **avec zéro utilisateur**, qui est difficile à copier (travail manuel), qui répond à un besoin réel et anxiogène, et qui ouvre la porte à des partenariats avec les parcs — lesquels ont un intérêt direct à ce que la réglementation soit connue.

---

### 3.5 Commerces, restaurants et magasins ouverts

**Source :** OpenStreetMap (`shop=supermarket|convenience|bakery`, `amenity=restaurant|bar|pharmacy`, `opening_hours`).

**Limites**
- Couverture en zone rurale/montagne **très inégale**, et champ `opening_hours` souvent absent ou obsolète. La fermeture hebdomadaire de la seule épicerie du village n'est presque jamais renseignée.
- La syntaxe `opening_hours` est un mini-langage à part entière (`Mo-Sa 08:00-12:30,15:00-19:00; Su off; Jan 01 off`). Il faut une bibliothèque dédiée (`opening_hours.js`), pas une regex maison.
- **Google Places est tentant et coûteux à double titre** : coût par requête, et surtout des conditions d'utilisation qui restreignent fortement la mise en cache et la conservation des données côté client. Une app qui stocke des POI Google dans sa propre base est en infraction. À éviter en V1.

**Solution V1** : OSM pré-ingéré, affichage des horaires **avec la date de dernière modification OSM**, et bouton "cette info est fausse" qui alimente une file de corrections. Corollaire vertueux : reverser ces corrections dans OSM. Cela améliore la donnée pour tout le monde, crédibilise le projet auprès de la communauté, et **coûte moins cher que de maintenir sa propre base**.

**Piste V2** : Overture Maps Foundation (Meta/Microsoft/Amazon/TomTom), qui publie des jeux de POI sous licence permissive et pourrait devenir une meilleure base que Google pour ce cas d'usage.

---

### 3.6 Affluence d'un parcours à partir d'une trace GPX

Techniquement la fonctionnalité la plus intéressante — et la plus contrainte.

**Chaîne de traitement**
1. **Parsing GPX** — trivial, mais attention aux traces bruitées, aux points aberrants (dérive GPS en forêt) et aux fichiers de 50 000 points. Simplification Douglas-Peucker en amont.
2. **Map-matching** — projeter la trace sur le graphe de sentiers OSM. Ne pas réimplémenter : utiliser **Valhalla** (`/trace_attributes`) ou OSRM, auto-hébergés. Un algorithme de Viterbi maison sur graphe est un projet de plusieurs mois.
3. **Découpage en segments** et jointure avec des statistiques de fréquentation par segment.
4. **Restitution** : profil de fréquentation le long de l'itinéraire, avec identification des tronçons saturés.

**Le blocage : d'où vient la fréquentation par segment ?**

- **Strava** — la Global Heatmap est publiquement consultable et Strava Metro fournit des données bien plus riches, mais **Metro est réservé aux organismes publics d'aménagement** (agences de transport, collectivités), et la heatmap n'est utilisable librement que pour le tracé dans OSM ; tout autre usage non personnel nécessite un accord commercial avec Strava. **Ce n'est donc pas une option pour une app grand public.** Ne construis pas ton produit dessus.
- **Écocompteurs** — de nombreux départements, parcs et offices de tourisme publient en open data des comptages de passages sur sentiers. Couverture partielle mais **données réelles, licenciées ouvertement, et gratuites**. Excellente source d'étalonnage.
- **Tes propres traces utilisateurs** — la seule source pérenne. Même problème de démarrage à froid.

**Solution V1 : un modèle d'estimation assumé.** Score de fréquentation par segment calculé à partir de variables disponibles sans utilisateurs :

```
score = f(distance au parking, capacité parking, balisage GR/GRP,
          présence d'un point d'intérêt majeur (lac, sommet coté),
          dénivelé cumulé depuis l'accès, jour/vacances scolaires, météo)
```

Calibré sur les écocompteurs open data disponibles → tu obtiens un modèle simple (régression, ou gradient boosting si tu veux montrer une compétence ML) avec une **métrique d'erreur mesurable**. Affiché comme *« affluence estimée »*, avec le niveau de confiance. Puis remplacé progressivement par des données observées à mesure que la base d'utilisateurs grandit.

*Note pour ton dossier MSc : cette fonctionnalité, seule, constitue un excellent sujet de projet technique — pipeline de données, map-matching, modélisation, évaluation. C'est bien plus valorisable qu'un CRUD.*

---

### 3.7 Campings à proximité

Le plus simple. **DATAtourisme** (réseau ADN Tourisme, agrégé nationalement, **Licence Ouverte / Etalab**) fournit hébergements, campings, gîtes d'étape, avec une structuration correcte. Complété par OSM (`tourism=camp_site`).

Limites : fraîcheur variable des tarifs et des périodes d'ouverture, doublons entre sources (même pipeline de conflation qu'en §3.1). Aucune difficulté structurelle. **À traiter en 3 jours, pas en 3 semaines.**

---

## 4. Architecture technique proposée

### 4.1 Pile recommandée et justification

| Couche | Choix | Pourquoi ce choix |
|---|---|---|
| **Mobile** | React Native (Expo) + `@maplibre/maplibre-react-native` | Un seul code base iOS/Android. Le critère décisif n'est pas le langage mais **la maturité du rendu cartographique offline** : MapLibre Native est la seule brique libre solide sur ce point. Flutter est un choix équivalent si tu préfères Dart. |
| **Fond de carte** | MapLibre GL + **PMTiles** hébergés sur Cloudflare R2 ; IGN via `data.geopf.fr` pour le SCAN/Plan IGN | Voir §5.2 — c'est le poste où l'on ruine un projet sans s'en apercevoir. |
| **Backend** | Python + FastAPI | Le goulot d'étranglement du projet est le **pipeline de données géo** (conflation, ETL, modèle d'affluence), et l'écosystème Python (GeoPandas, Shapely, GDAL, osmium) y est sans rival. Un seul langage pour l'API et les traitements. |
| **Base de données** | PostgreSQL + **PostGIS** (+ `pg_trgm`) | Non négociable. Index GIST, `ST_DWithin`, `ST_Contains` : toutes tes requêtes sont spatiales. Une base non spatiale te condamne à réimplémenter PostGIS en pire. |
| **Cache** | Redis | Résultats de requêtes bbox, agrégats d'affluence. |
| **Stockage objet** | Cloudflare R2 | **Egress gratuit** — déterminant pour servir des photos et des tuiles. |
| **Auth** | Supabase Auth ou Clerk | À ne surtout pas développer soi-même. |
| **Hébergement V1** | Supabase (Postgres+PostGIS managé) + Fly.io / Scaleway | Réduit l'ops à quasi zéro en phase pilote. Migrable vers du Postgres managé classique ensuite. |

### 4.2 Architecture logique

```
                    ┌──────────────────────────────┐
   Sources externes │ OSM (.pbf hebdo) · refuges.info API      │
   (batch nocturne) │ IGN Géoplateforme · DATAtourisme         │
                    │ INPN zones protégées · écocompteurs      │
                    └───────────────┬──────────────────────────┘
                                    ▼
                        ┌───────────────────────┐
                        │  ETL / Conflation     │  Python, cron
                        │  dédoublonnage +      │
                        │  provenance/attribut  │
                        └───────────┬───────────┘
                                    ▼
   ┌───────────────────────────────────────────────────────────┐
   │  PostgreSQL + PostGIS                                     │
   │                                                           │
   │  [Couche A]  référentiel_poi     ← ODbL / CC-BY-SA        │
   │              zone_reglementaire  ← curation manuelle      │
   │                                                           │
   │  [Couche B]  observation         ← utilisateurs (nos données)
   │              affluence_agregee   ← H3 + fenêtre temps     │
   └───────────────────────────┬───────────────────────────────┘
                               ▼
                        ┌──────────────┐
                        │ API FastAPI  │ + Redis
                        └──────┬───────┘
                               ▼
        ┌──────────────────────────────────────────┐
        │  App mobile — SQLite local, offline-first │
        │  file d'attente de contributions          │
        └──────────────────────────────────────────┘
```

**La séparation Couche A / Couche B n'est pas cosmétique** — elle est imposée par les licences (§6.1) *et* par la logique produit (le référentiel est stable, les observations sont périssables).

### 4.3 Le hors-ligne : la contrainte structurante

C'est le point que la plupart des projets sous-estiment, et c'est le plus discriminant en montagne.

**Exigences**
- Téléchargement d'un **pack de massif** avant départ : tuiles vectorielles + tous les POI + toutes les règles de la zone, dans un SQLite embarqué. Ordre de grandeur : 50–300 Mo par massif selon le niveau de zoom.
- Contributions **enregistrées localement** et rejouées à la reconnexion, avec `client_generated_id` (UUID) pour l'idempotence — sans quoi une resynchronisation crée des doublons.
- Résolution de conflits : pour ce cas d'usage, un **last-write-wins horodaté par l'appareil suffit largement**. Les CRDT sont séduisants intellectuellement mais surdimensionnés ici : les contributions sont des faits indépendants, pas des éditions concurrentes du même document. *(Ne complexifie pas pour impressionner — savoir choisir la solution simple est justement ce qu'on évalue.)*
- **Attention légale :** la mise en cache hors ligne des fonds de carte IGN ou OSM est encadrée. Le cache utilisateur temporaire est généralement admis ; la redistribution de tuiles ne l'est pas. À vérifier dans les CGU de la Géoplateforme avant de proposer des packs téléchargeables incluant du SCAN IGN.

### 4.4 Scaling des données — les vrais points de tension

Contre-intuitif mais important pour ton pitch : **ce n'est pas le nombre d'utilisateurs qui fait mal, c'est la géométrie.**

| Tension | Symptôme | Traitement |
|---|---|---|
| Requêtes bbox sur POI | Latence en zone dense | Index GIST + cluster spatial + limite de zoom minimal + cache Redis par tuile de bbox arrondie |
| Volume de tuiles | Coût CDN | PMTiles = un seul fichier, requêtes HTTP Range, CDN → coût quasi nul |
| Historique d'affluence | Croissance linéaire infinie | Agrégation H3 + rétention courte du brut (30 j) puis agrégats saisonniers uniquement |
| Photos utilisateurs | **Le vrai poste de coût** | Redimensionnement à l'upload côté client, WebP, 3 variantes max, R2 (egress gratuit) |
| Pics saisonniers | ×10 en juillet-août | Autoscaling — et surtout : ne pas dimensionner à l'année sur le pic d'août |

---

## 5. Effet réseau, communauté et modération

### 5.1 La boucle de contribution

Waze fonctionne parce que **contribuer coûte moins que le bénéfice immédiat perçu**. À reproduire :

| Levier | Application concrète |
|---|---|
| **Réciprocité visible** | *« 3 randonneurs ont confirmé cette source cette semaine »* — l'utilisateur voit qu'il reçoit avant de donner |
| **Coût de contribution ~0** | 1 tap, hors ligne, sans compte obligatoire |
| **Moment opportun** | Prompt au bivouac (17h–21h), pas au retour à la maison |
| **Statut, pas points** | La communauté rando valorise l'expertise terrain, pas la gamification à badges. Un système de points façon Foursquare sonnera faux et attirera de mauvaises contributions |
| **Ancrage associatif** | Reverser dans OSM et créditer refuges.info transforme des concurrents en alliés |

### 5.2 Modération et fiabilité — à concevoir avant, pas après

- **Score de confiance** par observation : `f(fraîcheur, nb de confirmations indépendantes, réputation du contributeur, cohérence avec les autres sources)`. Affiché en clair.
- **Contrôles de plausibilité automatiques** : contribution géolocalisée à > 5 km de la position GPS de l'appareil, vitesse de déplacement incompatible entre deux contributions, volume anormal depuis un même appareil → mise en quarantaine.
- **Modération asymétrique.** Une contribution positive ("il y a de l'eau") est peu risquée. Une contribution négative ou une suppression l'est davantage. Exiger plus de confirmations pour un changement destructif.
- **Photos** : filtrage automatique (modèle NSFW léger) + signalement + suppression rapide. Obligation légale de réactivité sur les contenus illicites.

### 5.3 Le paradoxe éthique du bivouac — un sujet à traiter frontalement

**Révéler publiquement les bons spots de bivouac contribue à les détruire.** C'est exactement ce qui est arrivé à certains sites après leur viralisation sur les réseaux. Les parcs nationaux surveillent ce phénomène ; les Écrins ont ouvert en 2026 une consultation évoquant des quotas pour limiter la surfréquentation.

Si ton app devient l'outil qui concentre 200 tentes sur le même lac, tu auras les gestionnaires d'espaces protégés contre toi — et ils ont le pouvoir réglementaire.

**Réponses possibles, à choisir consciemment :**
- Ne pas afficher les spots au point près : afficher des **zones** de bivouac possible (précision 250–500 m) plutôt que des points GPS.
- Mettre en avant les **aires officielles** et les alternatives, plutôt que les spots secrets.
- Signaler activement la saturation *pour disperser*, pas pour concentrer.
- **Faire de cette prudence un argument de partenariat** avec les parcs : « nous sommes l'outil qui diffuse votre réglementation et répartit la pression ». C'est le meilleur levier d'accès à de la donnée officielle que tu auras.

C'est aussi, très concrètement, l'angle qui distinguera ton dossier de candidature : montrer que tu as identifié un effet externe négatif de ton propre produit et que tu l'as traité dans la conception.

---

## 6. Contraintes juridiques et de responsabilité

### 6.1 Licences — le piège du partage à l'identique (ODbL)

**À comprendre absolument avant d'écrire une ligne de code.**

- **OSM est sous ODbL**, qui impose le partage à l'identique **sur les bases de données dérivées**. Si tu fusionnes physiquement les données OSM et tes contributions utilisateurs dans une seule base, tu risques de devoir publier l'ensemble sous ODbL — y compris la donnée que tu as produite et qui constitue ton actif.
- **refuges.info est sous CC BY-SA 2.0**, avec une clause de partage à l'identique également, et une incompatibilité potentielle avec l'ODbL selon la manière dont les données sont combinées.
- **DATAtourisme et les données IGN sont sous Licence Ouverte / Etalab** : permissive, attribution simple, sans contamination.

**Conséquence architecturale directe :** la séparation Couche A / Couche B de §4.2 n'est pas un détail d'élégance. Elle permet d'argumenter que ton produit est une **œuvre produite** (*produced work*) affichant des données ODbL, et non une base dérivée, en maintenant les jeux de données séparés et joints à la présentation. **Fais valider ce point par un juriste avant toute levée de fonds ou toute commercialisation** — c'est le genre de sujet qui bloque une due diligence.

Le réflexe sain, indépendamment du juridique : **publier en retour**. Un projet outdoor qui reverse ses corrections dans OSM et crédite ses sources n'a quasiment aucun risque de conflit communautaire.

### 6.2 Responsabilité produit

| Risque | Mitigation |
|---|---|
| Intoxication (eau) | Jamais de mention "potable" pour une source non contrôlée ; filtration recommandée affichée systématiquement ; CGU acceptée au premier lancement |
| Verbalisation (bivouac) | Citation littérale du texte officiel + lien source + date de vérification ; jamais de formulation prescriptive |
| Accident / secours | Ne jamais se présenter comme un outil de sécurité. Renvoyer explicitement vers le 112 et les moyens de secours |
| Info périmée | Date de dernière vérification affichée sur **chaque** donnée, sans exception |

### 6.3 RGPD

- **La géolocalisation est une donnée personnelle**, et la position de bivouac est particulièrement sensible : elle révèle où quelqu'un dort, souvent seul, dans un lieu isolé. Traite-la comme telle.
- Minimisation : pas de tracking continu, floutage à la cellule H3 dès l'ingestion, rétention du brut limitée (30 jours), agrégats anonymes ensuite.
- Seuil de k-anonymat (n ≥ 3) avant tout affichage d'agrégat.
- Une **AIPD (analyse d'impact)** est probablement requise si tu traites de la géolocalisation à grande échelle. À anticiper, pas à découvrir.
- Hébergement en UE (Scaleway, OVH, ou régions européennes) : simplifie le dossier et cohérent avec le positionnement.

### 6.4 Propriété intellectuelle des itinéraires

Les tracés et le balisage des GR relèvent d'un régime de protection revendiqué par la FFRandonnée. Publier des traces GR détaillées est un sujet sensible qui a déjà donné lieu à des différends. **Contournement V1 :** ne pas se positionner comme fournisseur d'itinéraires. L'utilisateur importe sa propre trace GPX ; ton app l'enrichit. C'est à la fois plus sûr juridiquement et plus différenciant que de faire un énième catalogue de randos.

---

## 7. Coûts d'infrastructure — chiffrage à trois paliers

### 7.1 Estimations mensuelles

| Poste | Pilote (≤1 000 MAU) | Croissance (50 000 MAU) | Échelle (500 000 MAU) |
|---|---|---|---|
| Base PostGIS managée | 0–25 € (Supabase Pro) | 150–250 € (+ réplica lecture) | 800–1 500 € |
| API (conteneurs) | 10–20 € | 80–150 € | 600–1 200 € |
| Cache Redis | 0 € | 20–40 € | 150–300 € |
| Stockage objet (photos) | 2 € | 10–20 € | 100–200 € |
| Tuiles / CDN (PMTiles sur R2) | 0–5 € | 20–50 € | 150–400 € |
| Emails transactionnels + push | 0 € | 20 € | 100 € |
| Observabilité (Sentry, logs) | 0 € | 50–100 € | 300–600 € |
| Traitements batch / ETL | 5 € | 30 € | 150 € |
| **Total infrastructure** | **≈ 40–60 €/mois** | **≈ 400–700 €/mois** | **≈ 2 500–4 500 €/mois** |
| Comptes développeur | 99 $/an (Apple) + 25 $ (Google, une fois) | idem | idem |

**Ordre de grandeur : ~0,01 €/utilisateur actif/mois.** Un abonnement à 2 €/mois avec 3 % de conversion couvre l'infrastructure très largement. **Le coût d'infrastructure n'est pas le sujet.**

### 7.2 Le vrai piège : le fond de carte

C'est le poste qui fait exploser les budgets sans prévenir.

| Solution | Coût à 500 000 chargements de carte/mois |
|---|---|
| **Google Maps** | Le modèle a changé en 2026 : le crédit de 200 $/mois a été remplacé par un quota gratuit (~28 500 chargements) et des paliers d'abonnement, avec un dépassement autour de **7 $ / 1 000 chargements** → **plusieurs milliers d'euros/mois** |
| **Mapbox** | 50 000 chargements gratuits/mois, puis ~5 $ / 1 000 (dégressif au-delà de 200 000) → **de l'ordre de 2 000 $/mois** |
| **PMTiles auto-hébergé sur Cloudflare R2** | Egress R2 **gratuit** ; un cas documenté (Pinball Map, ~50–60 k chargements/mois) rapporte une première facture de **1,67 $**, puis proche de zéro. À ton échelle : **quelques dizaines d'euros au maximum** |

**Recommandation sans ambiguïté : MapLibre + PMTiles sur R2, dès le premier jour.** La différence est d'un facteur 50 à 100, et migrer plus tard coûte des semaines. Le fond IGN reste accessible en complément via `data.geopf.fr` (données publiques IGN gratuites), avec des quotas de requêtes à respecter — au-delà, un HTTP 429 est renvoyé pendant quelques secondes sur l'API concernée. Note également l'évolution du 15 juin 2026 limitant à deux couches par requête sur les services WFS et WMS-V.

### 7.3 Le poste de coût que personne ne budgète

```
Serveurs à 50 000 MAU ........................ ~600 €/mois
Curation + modération + support ..... 0,4 à 1 ETP ≈ 1 500–3 500 €/mois
```

**Le coût humain est 3 à 5 fois le coût technique.** C'est vrai pour tous les produits contributifs. Deux conséquences : ne jamais présenter un business plan où l'infrastructure est la ligne principale (ça décrédibilise immédiatement devant quelqu'un qui connaît le domaine), et concevoir la modération comme un problème produit — chaque heure de modération manuelle évitée par un bon design vaut plus que n'importe quelle optimisation serveur.

---

## 8. Feuille de route proposée

### V0 — Validation, 4 à 6 semaines, sans développement mobile

**Objectif : prouver que le besoin existe avant d'écrire du code.**

1. Constituer à la main la base réglementation bivouac des **11 parcs nationaux** (tableur structuré selon le schéma de §3.4). C'est déjà un livrable qui a de la valeur en soi.
2. Publier une **carte web statique** (MapLibre + GeoJSON sur un hébergement gratuit) croisant : zones réglementaires + points d'eau refuges.info + campings DATAtourisme, sur **un seul massif**.
3. Diffuser sur les canaux où vit la cible : forums de rando légère, subreddits rando, groupes GR20/GR10, communauté refuges.info.
4. **Métrique de validation :** 500 utilisateurs uniques en 4 semaines et ≥ 20 retours qualitatifs spontanés. Sous ce seuil, le besoin n'est pas assez fort — repositionne avant d'investir.

Coût : ~0 €. Compétences mobilisées : SQL, données géo, un peu de JS. **C'est aussi ton premier livrable technique montrable pour ta candidature.**

### V1 — Application mobile, 3 à 4 mois

**Périmètre volontairement restreint. Un massif. Deux fonctionnalités excellentes.**

- Carte offline (pack de massif téléchargeable)
- Points d'eau avec état et fraîcheur affichés
- Réglementation bivouac géolocalisée, sourcée, datée
- Campings et commerces (open data, best effort, clairement étiqueté)
- Contribution en 1 tap, hors ligne, avec file de synchronisation
- Fiches refuges statiques + appel direct au gardien
- **Explicitement hors périmètre :** disponibilité des refuges en temps réel, affluence temps réel, création d'itinéraires

### V2 — Effet réseau, 6 à 12 mois après V1

- Affluence : agrégats H3 dès que la densité le permet, jusque-là modèle d'estimation
- Import GPX + enrichissement du parcours (eau, ravitaillement, points de bivouac légaux, affluence estimée)
- Interface gardien de refuge (10 refuges pilotes)
- Extension à 2–3 massifs supplémentaires
- Partenariats parcs / offices de tourisme

### Indicateurs à suivre (et à mettre dans ton dossier)

| Indicateur | Cible V1 |
|---|---|
| Taux de contributeurs (contributeurs / actifs) | > 5 % (Wikipédia ≈ 1 %, Waze ≈ 10 % sur ses fonctions passives) |
| Fraîcheur médiane des observations d'un massif actif | < 30 jours en saison |
| Rétention J+30 en saison | > 25 % |
| Contributions par utilisateur actif et par sortie | > 1,5 |
| Coût d'infrastructure par utilisateur actif | < 0,02 € |

---

## 9. Ce qu'il faut viser pour une candidature en MSc Computer Science (rentrée 2027)

Tu candidates depuis un profil business. Le jury cherchera **une preuve d'aptitude technique réelle**, pas une idée bien présentée. Trois principes :

1. **Un projet vertical fini vaut mieux qu'un projet ambitieux inachevé.** Une V0 en production, avec des utilisateurs réels et des métriques, est infiniment plus convaincante qu'une maquette Figma d'une super-app.
2. **Documente les décisions techniques, pas les fonctionnalités.** Un article ou un README qui explique *pourquoi* PostGIS plutôt qu'une base non spatiale, *pourquoi* PMTiles plutôt que Mapbox (avec les chiffres), *pourquoi* le last-write-wins plutôt qu'un CRDT — c'est exactement ce qui distingue quelqu'un qui a fait du no-code de quelqu'un qui pense en ingénieur.
3. **Contribue à l'open source.** Reverser des données dans OSM, ouvrir ton dataset de réglementation bivouac sous Licence Ouverte, publier un petit paquet Python de conflation de POI : ce sont des traces publiques et vérifiables de compétence.

**Compétences à construire dans l'ordre, sur 12 mois :**

| Trimestre | Focus | Livrable |
|---|---|---|
| T1 | Python + SQL + Git | Scripts d'ingestion OSM/refuges.info fonctionnels |
| T2 | PostGIS + géomatique + Docker | Base de données déployée, API FastAPI en ligne |
| T3 | Frontend cartographique (MapLibre) | V0 web publique avec utilisateurs réels |
| T4 | Mobile (React Native) + tests + CI | Prototype V1 sur un massif |

**Ne dis jamais** en entretien « je veux faire l'app qui fait tout ». **Dis** : « j'ai identifié qu'aucune source structurée de la réglementation bivouac n'existait, je l'ai constituée, géo-zonée dans PostGIS, et exposée via une API — voici les données, voici le code, voici les 800 personnes qui l'ont utilisée cet été ». La seconde phrase est celle d'un ingénieur.

---

## 10. Risques principaux et questions ouvertes

| Risque | Gravité | Traitement |
|---|---|---|
| Dors Dehors couvre déjà le périmètre | **Élevée** | À auditer **cette semaine**. S'ils couvrent tout, pivoter vers l'itinérance multi-jours + réglementation, ou envisager une contribution/collaboration plutôt qu'une concurrence frontale |
| Démarrage à froid sur l'affluence | Élevée | Concentration géographique + modèle d'estimation en attendant |
| Contamination ODbL de ta base | Moyenne | Séparation stricte des couches, validation juridique |
| Saisonnalité (activité ÷10 en hiver) | Moyenne | Ne pas dimensionner l'infra sur le pic ; occuper l'hiver par la curation |
| Responsabilité (eau, réglementation) | Moyenne | Formulations non prescriptives, sources citées, CGU |
| Hostilité des gestionnaires d'espaces protégés | Moyenne | Les impliquer **avant** le lancement, pas après |
| Effort de curation sous-estimé | Élevée | Mesurer le temps réel de saisie sur 1 parc avant d'extrapoler aux 11 |

**Questions à trancher avant d'écrire du code :**

1. **Quel massif pour le pilote ?** Critères : densité de randonneurs itinérants en été, complexité réglementaire (pour démontrer la valeur), et ta capacité à y aller physiquement vérifier.
2. **Randonnée itinérante ou sortie à la journée ?** Ce sont deux produits différents. L'itinérance est un marché plus petit mais un besoin bien plus intense, et un terrain moins encombré.
3. **Association ou société ?** Le statut associatif facilite énormément l'accès aux données publiques, les partenariats avec les parcs, et l'acceptation par la communauté. Il complique la levée de fonds. Pour un projet destiné avant tout à porter une candidature, l'association est probablement le bon véhicule.
4. **Que se passe-t-il en octobre ?** La saisonnalité est le risque produit le plus sous-estimé. Y a-t-il un usage hors saison (préparation, planification hivernale) ?

---

## Sources principales

- refuges.info — documentation API : `https://www.refuges.info/api/doc/` (CC BY-SA 2.0, lecture seule, sans clé)
- Dors Dehors : `https://dorsdehors.com/`
- IGN Géoplateforme / Géoservices : `https://geoservices.ign.fr/` — services WMTS/WMS/WFS, CGU et quotas sur `cartes.gouv.fr`
- Parcs nationaux de France — réglementation bivouac : `https://www.parcsnationaux.fr/fr/des-decouvertes/visiter-et-semerveiller/la-reglementation-et-les-conseils/le-bivouac`
- Strava — Global Heatmap & Metro : `https://support.strava.com/hc/en-us/articles/216918877` et `https://metro.strava.com/faq`
- Cloudflare R2 — tarification et egress : `https://developers.cloudflare.com/r2/pricing/`
- Retour d'expérience migration Mapbox → PMTiles : `https://blog.pinballmap.com/2024/11/05/protomaps-tile-hosting/`
- Bending Spoons / Komoot — communiqué du 20 mars 2025 et analyses associées
- DATAtourisme (Licence Ouverte / Etalab), INPN (zones protégées), data.gouv.fr

*Les tarifs des fournisseurs cloud et cartographiques évoluent fréquemment : à revérifier avant tout chiffrage engageant.*
