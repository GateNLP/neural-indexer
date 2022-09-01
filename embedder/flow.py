from jina import Flow

MODEL_NAME = "sentence-transformers/distiluse-base-multilingual-cased-v2"


def generate_flow(
    executor_suffix, embedder_additional_uses_with, replicas, embedder_additional_args
):
    embedder_uses_with = {
        "pretrained_model_name_or_path": MODEL_NAME,
        **embedder_additional_uses_with,
    }

    f = Flow(
        port=52592,
        monitoring=True,
        port_monitoring=9090,
        protocol="HTTP",
        no_crud_endpoints=True,
    ).add(
        uses=("jinahub+docker://TransformerTorchEncoder/latest" + executor_suffix),
        name="embedder",
        port_monitoring=9091,
        volumes="huggingface:/root/.cache/huggingface",
        uses_with=embedder_uses_with,
        env={"JINA_LOG_LEVEL": "INFO"},
        replicas=replicas,
        **embedder_additional_args
    )

    f.expose_endpoint("/embed", summary="Embed a document")

    return f
