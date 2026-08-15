import uuid
from datetime import date, datetime, time
from typing import Any

from geoalchemy2 import Geometry
from sqlalchemy import String, DateTime, Date, ForeignKey, Integer, Time
from sqlalchemy.dialects.postgresql import UUID as PG_UUID, JSONB, DATERANGE
from sqlalchemy.orm import Mapped, mapped_column, relationship

from app.models.base import Base, TimestampMixin


class ZoneReglementaire(Base, TimestampMixin):
    __tablename__ = "zone_reglementaire"

    id: Mapped[uuid.UUID] = mapped_column(PG_UUID(as_uuid=True), primary_key=True, default=uuid.uuid4)
    nom: Mapped[str] = mapped_column(String(255))
    type_zone: Mapped[str] = mapped_column(String(100))
    priorite: Mapped[int] = mapped_column(Integer, default=0)
    geom: Mapped[Any] = mapped_column(Geometry(geometry_type="MULTIPOLYGON", srid=4326))
    autorite: Mapped[str | None] = mapped_column(String(255), nullable=True)
    source_url: Mapped[str | None] = mapped_column(String(500), nullable=True)
    source_document: Mapped[str | None] = mapped_column(String(500), nullable=True)
    date_arrete: Mapped[date | None] = mapped_column(Date, nullable=True)
    date_verification: Mapped[datetime | None] = mapped_column(DateTime(timezone=True), nullable=True)

    regles: Mapped[list["RegleBivouac"]] = relationship(back_populates="zone")


class RegleBivouac(Base, TimestampMixin):
    __tablename__ = "regle_bivouac"

    id: Mapped[uuid.UUID] = mapped_column(PG_UUID(as_uuid=True), primary_key=True, default=uuid.uuid4)
    zone_id: Mapped[uuid.UUID] = mapped_column(PG_UUID(as_uuid=True), ForeignKey("zone_reglementaire.id"))
    statut: Mapped[str] = mapped_column(String(50))
    heure_debut: Mapped[time | None] = mapped_column(Time, nullable=True)
    heure_fin: Mapped[time | None] = mapped_column(Time, nullable=True)
    distance_min_route_m: Mapped[int | None] = mapped_column(Integer, nullable=True)
    contraintes: Mapped[dict | None] = mapped_column(JSONB, nullable=True)
    texte_officiel: Mapped[str] = mapped_column(String)
    periode_validite: Mapped[Any | None] = mapped_column(DATERANGE, nullable=True)

    zone: Mapped["ZoneReglementaire"] = relationship(back_populates="regles")