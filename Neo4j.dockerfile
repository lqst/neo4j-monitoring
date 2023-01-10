FROM neo4j:5-enterprise

## For json logging
COPY --chown=neo4j:neo4j ./config/server-logs.xml /var/lib/neo4j/conf/server-logs.xml