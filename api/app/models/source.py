# Clé primaire en UUID
from app.models.base import Base, TimestampMixin
import uuid
from sqlalchemy.dialects.postgresql import UUID as PG_UUID
from datetime import datetime
import enum
from sqlalchemy import Enum as SAEnum
from sqlalchemy import String, DateTime
from sqlalchemy.orm import Mapped, mapped_column

class LicenceType(str, enum.Enum):
    ODBL = "ODbL 1.0"
    CC_BY_SA = "CC BY-SA 2.0"
    LICENCE_OUVERTE = "Licence Ouverte / Etalab 2.0"
    DOMAINE_PUBLIC = "Domaine public"

class Source(Base, TimestampMixin):
    __tablename__ = "source"

    id: Mapped[uuid.UUID] = mapped_column(PG_UUID(as_uuid=True), primary_key=True, default=uuid.uuid4)
    nom: Mapped[str] = mapped_column(String(255))
    licence: Mapped[LicenceType] = mapped_column(SAEnum(LicenceType, name="licence_type"))
# Texte optionnel (peut être NULL)
    url: Mapped[str | None] = mapped_column(String(500), nullable=True)
    date_dernier_import: Mapped[datetime | None] = mapped_column(DateTime(timezone=True), nullable=True)


