ARG STACK_VERSION
FROM docker.elastic.co/logstash/logstash:${STACK_VERSION}

# Logstash 8.4.0 comes with v4.4.3 of this plugin
# Update to v4.4.4 because of this issue:
# https://github.com/logstash-plugins/logstash-input-file/pull/312
# This will no longer be necessary when v4.4.4 is included in a release of Logstash 
RUN bin/logstash-plugin install --version 4.4.4 logstash-input-file