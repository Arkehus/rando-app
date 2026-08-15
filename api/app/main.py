from fastapi import FastAPI

from app.routers import health

app = FastAPI(
    title="Rando API",
    description="API backend de l'application d'intinérence montagne",
    version="0.1.0",
)

app.include_router(health.router)


@app.get("/")
def root():
    return {"message": "API en ligne. Documentation interactive sur /docs."}
