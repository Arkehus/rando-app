import uuid
from datetime import datetime

from sqlalchemy import String, DateTime, ForeignKey
from sqlalchemy.dialects.postgresql import UUID as PG_UUID, JSONB
from sqlalchemy.orm import Mapped, mapped_column

from app.models.base import Base, TimestampMixin


class Observation(Base, TimestampMixin):
    __tablename__ = "observation"

    id: Mapped[uuid.UUID] = mapped_column(PG_UUID(as_uuid=True), primary_key=True, default=uuid.uuid4)
    poi_id: Mapped[uuid.UUID] = mapped_column(PG_UUID(as_uuid=True), ForeignKey("poi.id"))
    type_obs: Mapped[str] = mapped_column(String(50))
    valeur: Mapped[dict] = mapped_column(JSONB)
    date: Mapped[datetime] = mapped_column(DateTime(timezone=True))
    auteur_hash: Mapped[str] = mapped_column(String(64))