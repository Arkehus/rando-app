--
-- PostgreSQL database dump
--

-- Dumped from database version 16.4 (Debian 16.4-1.pgdg110+2)
-- Dumped by pg_dump version 16.4 (Debian 16.4-1.pgdg110+2)

SET statement_timeout = 0;
SET lock_timeout = 0;
SET idle_in_transaction_session_timeout = 0;
SET client_encoding = 'UTF8';
SET standard_conforming_strings = on;
SELECT pg_catalog.set_config('search_path', '', false);
SET check_function_bodies = false;
SET xmloption = content;
SET client_min_messages = warning;
SET row_security = off;

--
-- Name: tiger; Type: SCHEMA; Schema: -; Owner: appuser
--

CREATE SCHEMA tiger;


ALTER SCHEMA tiger OWNER TO appuser;

--
-- Name: tiger_data; Type: SCHEMA; Schema: -; Owner: appuser
--

CREATE SCHEMA tiger_data;


ALTER SCHEMA tiger_data OWNER TO appuser;

--
-- Name: topology; Type: SCHEMA; Schema: -; Owner: appuser
--

CREATE SCHEMA topology;


ALTER SCHEMA topology OWNER TO appuser;

--
-- Name: SCHEMA topology; Type: COMMENT; Schema: -; Owner: appuser
--

COMMENT ON SCHEMA topology IS 'PostGIS Topology schema';


--
-- Name: fuzzystrmatch; Type: EXTENSION; Schema: -; Owner: -
--

CREATE EXTENSION IF NOT EXISTS fuzzystrmatch WITH SCHEMA public;


--
-- Name: EXTENSION fuzzystrmatch; Type: COMMENT; Schema: -; Owner: 
--

COMMENT ON EXTENSION fuzzystrmatch IS 'determine similarities and distance between strings';


--
-- Name: postgis; Type: EXTENSION; Schema: -; Owner: -
--

CREATE EXTENSION IF NOT EXISTS postgis WITH SCHEMA public;


--
-- Name: EXTENSION postgis; Type: COMMENT; Schema: -; Owner: 
--

COMMENT ON EXTENSION postgis IS 'PostGIS geometry and geography spatial types and functions';


--
-- Name: postgis_tiger_geocoder; Type: EXTENSION; Schema: -; Owner: -
--

CREATE EXTENSION IF NOT EXISTS postgis_tiger_geocoder WITH SCHEMA tiger;


--
-- Name: EXTENSION postgis_tiger_geocoder; Type: COMMENT; Schema: -; Owner: 
--

COMMENT ON EXTENSION postgis_tiger_geocoder IS 'PostGIS tiger geocoder and reverse geocoder';


--
-- Name: postgis_topology; Type: EXTENSION; Schema: -; Owner: -
--

CREATE EXTENSION IF NOT EXISTS postgis_topology WITH SCHEMA topology;


--
-- Name: EXTENSION postgis_topology; Type: COMMENT; Schema: -; Owner: 
--

COMMENT ON EXTENSION postgis_topology IS 'PostGIS topology spatial types and functions';


--
-- Name: licence_type; Type: TYPE; Schema: public; Owner: appuser
--

CREATE TYPE public.licence_type AS ENUM (
    'ODBL',
    'CC_BY_SA',
    'LICENCE_OUVERTE',
    'DOMAINE_PUBLIC'
);


ALTER TYPE public.licence_type OWNER TO appuser;

--
-- Name: typepoi; Type: TYPE; Schema: public; Owner: appuser
--

CREATE TYPE public.typepoi AS ENUM (
    'eau',
    'refuge',
    'camping',
    'commerce'
);


ALTER TYPE public.typepoi OWNER TO appuser;

SET default_tablespace = '';

SET default_table_access_method = heap;

--
-- Name: alembic_version; Type: TABLE; Schema: public; Owner: appuser
--

CREATE TABLE public.alembic_version (
    version_num character varying(32) NOT NULL
);


ALTER TABLE public.alembic_version OWNER TO appuser;

--
-- Name: observation; Type: TABLE; Schema: public; Owner: appuser
--

CREATE TABLE public.observation (
    id uuid NOT NULL,
    poi_id uuid NOT NULL,
    type_obs character varying(50) NOT NULL,
    valeur jsonb NOT NULL,
    date timestamp with time zone NOT NULL,
    auteur_hash character varying(64) NOT NULL,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    updated_at timestamp with time zone DEFAULT now() NOT NULL
);


ALTER TABLE public.observation OWNER TO appuser;

--
-- Name: poi; Type: TABLE; Schema: public; Owner: appuser
--

CREATE TABLE public.poi (
    id uuid NOT NULL,
    type public.typepoi NOT NULL,
    nom character varying(255),
    geom public.geography(Point,4326) NOT NULL,
    source_id uuid NOT NULL,
    source_ref character varying(255) NOT NULL,
    date_import timestamp with time zone,
    date_verficiation timestamp with time zone,
    attributs jsonb NOT NULL,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    updated_at timestamp with time zone DEFAULT now() NOT NULL
);


ALTER TABLE public.poi OWNER TO appuser;

--
-- Name: regle_bivouac; Type: TABLE; Schema: public; Owner: appuser
--

CREATE TABLE public.regle_bivouac (
    id uuid NOT NULL,
    zone_id uuid NOT NULL,
    statut character varying(50) NOT NULL,
    heure_debut time without time zone,
    heure_fin time without time zone,
    distance_min_route_m integer,
    contraintes jsonb,
    texte_officiel character varying NOT NULL,
    periode_validite daterange,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    updated_at timestamp with time zone DEFAULT now() NOT NULL
);


ALTER TABLE public.regle_bivouac OWNER TO appuser;

--
-- Name: source; Type: TABLE; Schema: public; Owner: appuser
--

CREATE TABLE public.source (
    id uuid NOT NULL,
    nom character varying(255) NOT NULL,
    licence public.licence_type NOT NULL,
    url character varying(500),
    date_dernier_import timestamp with time zone,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    updated_at timestamp with time zone DEFAULT now() NOT NULL
);


ALTER TABLE public.source OWNER TO appuser;

--
-- Name: zone_reglementaire; Type: TABLE; Schema: public; Owner: appuser
--

CREATE TABLE public.zone_reglementaire (
    id uuid NOT NULL,
    nom character varying(255) NOT NULL,
    type_zone character varying(100) NOT NULL,
    priorite integer NOT NULL,
    geom public.geometry(MultiPolygon,4326) NOT NULL,
    autorite character varying(255),
    source_url character varying(500),
    source_document character varying(500),
    date_arrete date,
    date_verification timestamp with time zone,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    updated_at timestamp with time zone DEFAULT now() NOT NULL
);


ALTER TABLE public.zone_reglementaire OWNER TO appuser;

--
-- Data for Name: alembic_version; Type: TABLE DATA; Schema: public; Owner: appuser
--

COPY public.alembic_version (version_num) FROM stdin;
f754c7e979b6
\.


--
-- Data for Name: observation; Type: TABLE DATA; Schema: public; Owner: appuser
--

COPY public.observation (id, poi_id, type_obs, valeur, date, auteur_hash, created_at, updated_at) FROM stdin;
\.


--
-- Data for Name: poi; Type: TABLE DATA; Schema: public; Owner: appuser
--

COPY public.poi (id, type, nom, geom, source_id, source_ref, date_import, date_verficiation, attributs, created_at, updated_at) FROM stdin;
\.


--
-- Data for Name: regle_bivouac; Type: TABLE DATA; Schema: public; Owner: appuser
--

COPY public.regle_bivouac (id, zone_id, statut, heure_debut, heure_fin, distance_min_route_m, contraintes, texte_officiel, periode_validite, created_at, updated_at) FROM stdin;
\.


--
-- Data for Name: source; Type: TABLE DATA; Schema: public; Owner: appuser
--

COPY public.source (id, nom, licence, url, date_dernier_import, created_at, updated_at) FROM stdin;
\.


--
-- Data for Name: spatial_ref_sys; Type: TABLE DATA; Schema: public; Owner: appuser
--

COPY public.spatial_ref_sys (srid, auth_name, auth_srid, srtext, proj4text) FROM stdin;
\.


--
-- Data for Name: zone_reglementaire; Type: TABLE DATA; Schema: public; Owner: appuser
--

COPY public.zone_reglementaire (id, nom, type_zone, priorite, geom, autorite, source_url, source_document, date_arrete, date_verification, created_at, updated_at) FROM stdin;
\.


--
-- Data for Name: geocode_settings; Type: TABLE DATA; Schema: tiger; Owner: appuser
--

COPY tiger.geocode_settings (name, setting, unit, category, short_desc) FROM stdin;
\.


--
-- Data for Name: pagc_gaz; Type: TABLE DATA; Schema: tiger; Owner: appuser
--

COPY tiger.pagc_gaz (id, seq, word, stdword, token, is_custom) FROM stdin;
\.


--
-- Data for Name: pagc_lex; Type: TABLE DATA; Schema: tiger; Owner: appuser
--

COPY tiger.pagc_lex (id, seq, word, stdword, token, is_custom) FROM stdin;
\.


--
-- Data for Name: pagc_rules; Type: TABLE DATA; Schema: tiger; Owner: appuser
--

COPY tiger.pagc_rules (id, rule, is_custom) FROM stdin;
\.


--
-- Data for Name: topology; Type: TABLE DATA; Schema: topology; Owner: appuser
--

COPY topology.topology (id, name, srid, "precision", hasz) FROM stdin;
\.


--
-- Data for Name: layer; Type: TABLE DATA; Schema: topology; Owner: appuser
--

COPY topology.layer (topology_id, layer_id, schema_name, table_name, feature_column, feature_type, level, child_id) FROM stdin;
\.


--
-- Name: topology_id_seq; Type: SEQUENCE SET; Schema: topology; Owner: appuser
--

SELECT pg_catalog.setval('topology.topology_id_seq', 1, false);


--
-- Name: alembic_version alembic_version_pkc; Type: CONSTRAINT; Schema: public; Owner: appuser
--

ALTER TABLE ONLY public.alembic_version
    ADD CONSTRAINT alembic_version_pkc PRIMARY KEY (version_num);


--
-- Name: observation observation_pkey; Type: CONSTRAINT; Schema: public; Owner: appuser
--

ALTER TABLE ONLY public.observation
    ADD CONSTRAINT observation_pkey PRIMARY KEY (id);


--
-- Name: poi poi_pkey; Type: CONSTRAINT; Schema: public; Owner: appuser
--

ALTER TABLE ONLY public.poi
    ADD CONSTRAINT poi_pkey PRIMARY KEY (id);


--
-- Name: regle_bivouac regle_bivouac_pkey; Type: CONSTRAINT; Schema: public; Owner: appuser
--

ALTER TABLE ONLY public.regle_bivouac
    ADD CONSTRAINT regle_bivouac_pkey PRIMARY KEY (id);


--
-- Name: source source_pkey; Type: CONSTRAINT; Schema: public; Owner: appuser
--

ALTER TABLE ONLY public.source
    ADD CONSTRAINT source_pkey PRIMARY KEY (id);


--
-- Name: zone_reglementaire zone_reglementaire_pkey; Type: CONSTRAINT; Schema: public; Owner: appuser
--

ALTER TABLE ONLY public.zone_reglementaire
    ADD CONSTRAINT zone_reglementaire_pkey PRIMARY KEY (id);


--
-- Name: idx_poi_geom; Type: INDEX; Schema: public; Owner: appuser
--

CREATE INDEX idx_poi_geom ON public.poi USING gist (geom);


--
-- Name: idx_zone_reglementaire_geom; Type: INDEX; Schema: public; Owner: appuser
--

CREATE INDEX idx_zone_reglementaire_geom ON public.zone_reglementaire USING gist (geom);


--
-- Name: observation observation_poi_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: appuser
--

ALTER TABLE ONLY public.observation
    ADD CONSTRAINT observation_poi_id_fkey FOREIGN KEY (poi_id) REFERENCES public.poi(id);


--
-- Name: poi poi_source_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: appuser
--

ALTER TABLE ONLY public.poi
    ADD CONSTRAINT poi_source_id_fkey FOREIGN KEY (source_id) REFERENCES public.source(id);


--
-- Name: regle_bivouac regle_bivouac_zone_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: appuser
--

ALTER TABLE ONLY public.regle_bivouac
    ADD CONSTRAINT regle_bivouac_zone_id_fkey FOREIGN KEY (zone_id) REFERENCES public.zone_reglementaire(id);


--
-- Name: SCHEMA public; Type: ACL; Schema: -; Owner: pg_database_owner
--

GRANT USAGE ON SCHEMA public TO api_readonly;


--
-- Name: TABLE alembic_version; Type: ACL; Schema: public; Owner: appuser
--

GRANT SELECT ON TABLE public.alembic_version TO api_readonly;
GRANT ALL ON TABLE public.alembic_version TO etl_writer;


--
-- Name: TABLE geography_columns; Type: ACL; Schema: public; Owner: appuser
--

GRANT SELECT ON TABLE public.geography_columns TO api_readonly;
GRANT ALL ON TABLE public.geography_columns TO etl_writer;


--
-- Name: TABLE geometry_columns; Type: ACL; Schema: public; Owner: appuser
--

GRANT SELECT ON TABLE public.geometry_columns TO api_readonly;
GRANT ALL ON TABLE public.geometry_columns TO etl_writer;


--
-- Name: TABLE observation; Type: ACL; Schema: public; Owner: appuser
--

GRANT SELECT ON TABLE public.observation TO api_readonly;
GRANT ALL ON TABLE public.observation TO etl_writer;


--
-- Name: TABLE poi; Type: ACL; Schema: public; Owner: appuser
--

GRANT SELECT ON TABLE public.poi TO api_readonly;
GRANT ALL ON TABLE public.poi TO etl_writer;


--
-- Name: TABLE regle_bivouac; Type: ACL; Schema: public; Owner: appuser
--

GRANT SELECT ON TABLE public.regle_bivouac TO api_readonly;
GRANT ALL ON TABLE public.regle_bivouac TO etl_writer;


--
-- Name: TABLE source; Type: ACL; Schema: public; Owner: appuser
--

GRANT SELECT ON TABLE public.source TO api_readonly;
GRANT ALL ON TABLE public.source TO etl_writer;


--
-- Name: TABLE spatial_ref_sys; Type: ACL; Schema: public; Owner: appuser
--

GRANT SELECT ON TABLE public.spatial_ref_sys TO api_readonly;
GRANT ALL ON TABLE public.spatial_ref_sys TO etl_writer;


--
-- Name: TABLE zone_reglementaire; Type: ACL; Schema: public; Owner: appuser
--

GRANT SELECT ON TABLE public.zone_reglementaire TO api_readonly;
GRANT ALL ON TABLE public.zone_reglementaire TO etl_writer;


--
-- Name: DEFAULT PRIVILEGES FOR TABLES; Type: DEFAULT ACL; Schema: public; Owner: appuser
--

ALTER DEFAULT PRIVILEGES FOR ROLE appuser IN SCHEMA public GRANT SELECT ON TABLES TO api_readonly;


--
-- PostgreSQL database dump complete
--

