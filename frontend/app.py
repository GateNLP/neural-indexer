from fastapi import FastAPI
from fastapi.staticfiles import StaticFiles
from starlette.responses import FileResponse
from lib import embed, search_generate
from lib.config import config
from pydantic import BaseModel



app = FastAPI()

app.mount("/assets", StaticFiles(directory="assets"), name="assets")

@app.get("/")
async def home():
    return FileResponse("index.html")

class SearchQuery(BaseModel):
    query: str

class SavedSearchResponse(BaseModel):
    id: str

@app.get("/api/config")
async def route_config():
    return {
        "kibana_root": config.kibana_external_host,
        "index_pattern_id": config.index_pattern_id
    }

@app.post("/api/search")
async def search(query : SearchQuery) -> SavedSearchResponse:
    embedding = embed.embed(query.query)

    search_obj = search_generate.generate_saved_search(embedding)
    saved_search_id = search_generate.save_search(search_obj)

    return {"saved_search_id": saved_search_id}
