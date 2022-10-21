from pydantic import BaseSettings

class Settings(BaseSettings):
    index_pattern_id: str
    elastic_username: str = 'elastic'
    elastic_password: str
    kibana_host: str
    jina_gateway_url: str

config = Settings()