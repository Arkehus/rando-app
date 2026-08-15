-- Idempotent : peut être relancé sans erreur si les rôles existent déjà
DO $$
BEGIN
    IF NOT EXISTS (SELECT FROM pg_roles WHERE rolname = 'api_readonly') THEN
        CREATE USER api_readonly WITH PASSWORD 'readonly_devpass';
    END IF;
    IF NOT EXISTS (SELECT FROM pg_roles WHERE rolname = 'etl_writer') THEN
        CREATE USER etl_writer WITH PASSWORD 'etl_devpass';
    END IF;
END
$$;

GRANT CONNECT ON DATABASE rando TO api_readonly;
GRANT USAGE ON SCHEMA public TO api_readonly;
GRANT SELECT ON ALL TABLES IN SCHEMA public TO api_readonly;
ALTER DEFAULT PRIVILEGES IN SCHEMA public GRANT SELECT ON TABLES TO api_readonly;

GRANT ALL PRIVILEGES ON ALL TABLES IN SCHEMA public TO etl_writer;