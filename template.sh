#!/bin/bash

ES_HOST=${ES_HOST:-localhost:9200}
CREDS=${CREDS:--u ${ES_USER}:${ES_PASSWORD}}

if [ -n "$DELETE_EXISTING_TEMPLATE" ]; then
  curl -sXDELETE ${CREDS} 'http://'$ES_HOST'/_template/pcap-template'
  echo ""
fi

if [ -n "$DELETE_ALL_INDEXES" ]; then
  curl -sXGET ${CREDS} 'http://'$ES_HOST'/_cat/indices?v' | grep pcap | while read line; do
    index="$(echo $line | awk '{print $3}')"
    curl -sXDELETE ${CREDS} 'http://'$ES_HOST'/'$index
    echo ""
  done
  echo ""
fi

curl -H "Content-Type: application/json" -sXPUT ${CREDS} 'http://'$ES_HOST'/_template/pcap-template' --data-binary '{
    "index_patterns": [ "pcap-*" ],
    "index.mapping.total_fields.limit" : "5000",
    "index.highlight.max_analyzed_offset": 100000
}'

echo ""

while true; do

curl -sXGET ${CREDS} 'http://'$ES_HOST'/_cat/indices?v' | grep pcap | while read line; do
  index="$(echo $line | awk '{print $3}')"
    curl -H "Content-Type: application/json" -sXPUT ${CREDS} 'http://'$ES_HOST'/'$index'/_settings' --data-binary '{
    "index" : {
      "mapping.total_fields.limit" : "5000",
      "highlight.max_analyzed_offset": 100000
     }
}'
    curl -H "Content-Type: application/json" -sXGET ${CREDS} 'http://'$ES_HOST'/'$index'/_settings'
  done

echo ""

curl -H "Content-Type: application/json" -sXGET ${CREDS} 'http://'$ES_HOST'/_template/pcap-template'

echo ""

  sleep 300

done
