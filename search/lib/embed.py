import requests
from .config import config


def embed(text):
    embed_obj = {"data": [{"text": text}]}

    req = requests.post(f"{config.jina_gateway_url}/embed", json=embed_obj)
    resp = req.json()
    embedding = resp["data"][0]["embedding"]

    return embedding
