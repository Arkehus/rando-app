from app.models.base import Base, TimestampMixin
import uuid
from datetime import datetime
from sqlalchemy import String, DateTime, ForeignKey, Enum
from sqlalchemy.dialects.postgresql import UUID as PG_UUID, JSONB
from sqlalchemy.orm import Mapped, mapped_column
from geoalchemy2 import Geography
from geoalchemy2.elements import WKBElement
import enum


class typePOI(str, enum.Enum):
    eau = "eau"
    refuge = "refuge"
    camping = "camping"
    commerce = "commerce"

class POI(Base, TimestampMixin):
    __tablename__ = "poi"

    id: Mapped[uuid.UUID] = mapped_column(PG_UUID(as_uuid=True), primary_key=True, default=uuid.uuid4)
    type: Mapped[typePOI] = mapped_column(Enum(typePOI))
    nom: Mapped[str] = mapped_column(String(255), nullable=True)
    geom : Mapped[WKBElement] = mapped_column(Geography(geometry_type="POINT", srid=4326))
    source_id: Mapped[uuid.UUID] = mapped_column(PG_UUID(as_uuid=True), ForeignKey("source.id"))
    source_ref : Mapped[str] = mapped_column(String(255))
    date_import: Mapped[datetime | None] = mapped_column(DateTime(timezone=True), nullable=True)
    date_verficiation: Mapped[datetime | None] = mapped_column(DateTime(timezone=True), nullable=True)
    attributs: Mapped[dict] = mapped_column(JSONB)