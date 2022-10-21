FROM rabbitmq:3.10-management

ARG RABBITMQ_PASSWORD
ENV RABBITMQ_PASSWORD $RABBITMQ_PASSWORD

RUN apt-get update && \
    apt-get install gettext-base -y --no-install-recommends && \
    rm -rf /var/lib/apt/lists/*
COPY definitions.json /etc/rabbitmq/definitions.json

# Subsitute RABBITMQ_PASSWORD in the definitions file
RUN envsubst < /etc/rabbitmq/definitions.json | tee /etc/rabbitmq/definitions.json > /dev/null