if [ x${ELASTIC_PASSWORD} == x ]; then
    echo "Set the ELASTIC_PASSWORD environment variable in the .env file";
    exit 1;
elif [ x${KIBANA_PASSWORD} == x ]; then
    echo "Set the KIBANA_PASSWORD environment variable in the .env file";
    exit 1;
fi;

if [ ! -f config/certs/ca.zip ]; then
    echo "Creating CA";
    bin/elasticsearch-certutil ca --silent --pem -out config/certs/ca.zip;
    unzip config/certs/ca.zip -d config/certs;
fi;

if [ ! -f config/certs/certs.zip ]; then
    echo "Creating certs";
    chown -R root:root config/certs;
    bin/elasticsearch-certutil cert --silent --pem -out config/certs/certs.zip --in cert_setup/instances.yml --ca-cert config/certs/ca/ca.crt --ca-key config/certs/ca/ca.key;
    unzip config/certs/certs.zip -d config/certs;
fi;

echo "Setting file permissions"
chown -R root:root config/certs;
find config/certs -type d -exec chmod 750 \{\} \;;
find config/certs -type f -exec chmod 640 \{\} \;;

echo "Waiting for Elasticsearch availability";
until curl -s --cacert config/certs/ca/ca.crt https://es01:9200 | grep -q "missing authentication credentials"; do sleep 30; done;


echo "Setting kibana_system password";
until curl -s -X POST --cacert config/certs/ca/ca.crt -u "elastic:${ELASTIC_PASSWORD}" -H "Content-Type: application/json" https://es01:9200/_security/user/kibana_system/_password -d "{\"password\":\"${KIBANA_PASSWORD}\"}" | grep -q "^{}"; do sleep 10; done;

echo "Waiting for Kibana availability";
until curl -s -u "elastic:${ELASTIC_PASSWORD}" http://kibana:5601/api/status | grep -q "All services are available"; do sleep 30; done;

echo "Waiting for Metricbeat to create its dashboards";
until curl -s -u "elastic:${ELASTIC_PASSWORD}" http://kibana:5601/api/data_views | grep -q "metricbeat-"; do sleep 30; done;

echo "Importing saved objects";
curl -s -X POST -u "elastic:${ELASTIC_PASSWORD}" http://kibana:5601/api/saved_objects/_import -H "kbn-xsrf: true" --form file=@saved_objects.ndjson;

echo "\nAll done!";
