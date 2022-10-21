from datetime import datetime
import json
import copy
import requests
from requests.auth import HTTPBasicAuth
from .config import config


def load_template_file(template):
    with open(f"data/{template}") as f:
        return json.load(f)


search_template = load_template_file("search-template.json")
search_source_template = load_template_file("search-source-template.json")


def generate_saved_search(embedding):
    search_source = copy.deepcopy(search_source_template)
    search_source["knn"]["query_vector"] = embedding
    search_source_s = json.dumps(search_source)

    saved_search = copy.deepcopy(search_template)
    saved_search["attributes"]["kibanaSavedObjectMeta"][
        "searchSourceJSON"
    ] = search_source_s

    saved_search["attributes"]["title"] = f"UI Search {datetime.now()}"

    for i in range(len(saved_search["references"])):
        saved_search["references"][i]["id"] = config.index_pattern_id

    return saved_search


def save_search(search_obj):
    auth = HTTPBasicAuth(config.elastic_username, config.elastic_password)
    headers = {"kbn-xsrf": "true"}
    req = requests.post(
        f"{config.kibana_host}/api/saved_objects/search",
        auth=auth,
        json=search_obj,
        headers=headers,
    )
    resp = req.json()
    id = resp["id"]
    return id
