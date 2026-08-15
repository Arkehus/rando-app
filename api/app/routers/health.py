from fastapi import APIRouter
from sqlalchemy import text

from app.db import engine

router = APIRouter(prefix="/health", tags=["Health"])


@router.get("/")
def health():
    return {"status": "ok"}


@router.get("/db")
def health_db():
    try:
        with engine.connect() as conn:
            version = conn.execute(text("SELECT PostGIS_Version();")).scalar()
        return {"status": "ok", "postgis_version": version}
    except Exception as esc:
        return {"status": "error", "error": str(esc)}
