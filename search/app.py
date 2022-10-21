from fastapi import FastAPI
from fastapi.staticfiles import StaticFiles
from lib import embed, search_generate
from lib.config import config
from pydantic import BaseModel
from starlette.responses import FileResponse

app = FastAPI()

app.mount("/assets", StaticFiles(directory="assets"), name="assets")


@app.get("/")
async def home():
    return FileResponse("index.html")


class SearchQuery(BaseModel):
    query: str
    k: int
    num_candidates: int


class SavedSearchResponse(BaseModel):
    id: str


@app.get("/api/health")
async def health():
    return {"status": "healthy"}


@app.get("/api/config")
async def route_config():
    return {"index_pattern_id": config.index_pattern_id}


@app.post("/api/search")
async def search(query: SearchQuery) -> SavedSearchResponse:
    embedding = embed.embed(query.query)

    search_obj = search_generate.generate_saved_search(
        embedding, query.k, query.num_candidates
    )
    saved_search_id = search_generate.save_search(search_obj)

    return {"saved_search_id": saved_search_id}
