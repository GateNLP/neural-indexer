import logging
import os

from jina import Flow


def generate_flow(
    executor_suffix, embedder_additional_uses_with, replicas, embedder_additional_args
):
    model = os.environ.get("EMBEDDING_MODEL", None)

    if model is None:
        logging.error("Model is not defined in env, set it using `EMBEDDING_MODEL`")
        exit(1)

    embedder_uses_with = {
        "pretrained_model_name_or_path": os.environ["EMBEDDING_MODEL"],
        **embedder_additional_uses_with,
    }

    f = Flow(
        port=52592,
        monitoring=True,
        port_monitoring=9090,
        protocol="HTTP",
        no_crud_endpoints=True,
        cors=True,
        name="Tweet Ingest Embedder",
        title="Tweet Ingest Embedder",
        description="Embeds documents with {}".format(
            embedder_uses_with["pretrained_model_name_or_path"]
        ),
    ).add(
        uses=(
            "docker://ghcr.io/freddyheppell/transformer-torch-encoder-cu113:latest"
            + executor_suffix
        ),
        name="embedder",
        port_monitoring=9090,
        volumes="huggingface:/root/.cache/huggingface",
        uses_with=embedder_uses_with,
        env={"JINA_LOG_LEVEL": "INFO"},
        replicas=replicas,
        **embedder_additional_args,
    )

    f.expose_endpoint("/embed", summary="Embed a document")

    return f
