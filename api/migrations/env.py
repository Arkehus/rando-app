import os
import sys
from logging.config import fileConfig
from pathlib import Path

from sqlalchemy import engine_from_config, pool

from geoalchemy2 import alembic_helpers

from alembic import context

sys.path.append(str(Path(__file__).resolve().parents[1]))

from app.models import Base

# this is the Alembic Config object, which provides
# access to the values within the .ini file in use.
config = context.config

# Interpret the config file for Python logging.
# This line sets up loggers basically.
if config.config_file_name is not None:
    fileConfig(config.config_file_name)

# Lit l'URL de connexion depuis la variable d'environnement plutôt que
# depuis alembic.ini, pour ne jamais committer de mot de passe.
config.set_main_option("sqlalchemy.url", os.environ["DATABASE_URL"])

# add your model's MetaData object here for 'autogenerate' support
target_metadata = Base.metadata


def include_object(_object, name, type_, _reflected, _compare_to):
    """N'gérer que les tables déclarées dans nos modèles. PostGIS et son
    extension TIGER créent une trentaine de tables système au démarrage
    du conteneur — aucune ne doit être touchée par nos migrations."""
    if type_ == "table":
        return name in Base.metadata.tables
    return True


def run_migrations_offline() -> None:
    """Run migrations in 'offline' mode.

    This configures the context with just a URL
    and not an Engine, though an Engine is acceptable
    here as well. By skipping the Engine creation
    we don't even need a DBAPI to be available.

    Calls to context.execute() here emit the given string to the
    script output.
    """
    url = config.get_main_option("sqlalchemy.url")
    context.configure(
        url=url,
        target_metadata=target_metadata,
        literal_binds=True,
        dialect_opts={"paramstyle": "named"},
    )

    with context.begin_transaction():
        context.run_migrations()


def run_migrations_online() -> None:
    """Run migrations in 'online' mode.

    In this scenario we need to create an Engine
    and associate a connection with the context.
    """
    connectable = engine_from_config(
        config.get_section(config.config_ini_section, {}),
        prefix="sqlalchemy.",
        poolclass=pool.NullPool,
    )

    with connectable.connect() as connection:
        context.configure(
            connection=connection,
            target_metadata=target_metadata,
            include_object=include_object,
            render_item=alembic_helpers.render_item,
        )

        with context.begin_transaction():
            context.run_migrations()


if context.is_offline_mode():
    run_migrations_offline()
else:
    run_migrations_online()