FROM neo4j:2025.06.2-enterprise

## For json logging
COPY --chown=neo4j:neo4j ./config/server-logs.xml /var/lib/neo4j/conf/server-logs.xml

## Plugins
RUN mv /var/lib/neo4j/labs/apoc*core.jar /var/lib/neo4j/plugins/apoc_core.jar \
 && mv /var/lib/neo4j/products/neo4j-graph-data-science*.jar /var/lib/neo4j/plugins/neo4j-graph-data-science.jar \
 && mv /var/lib/neo4j/products/bloom-plugin-*.jar /var/lib/neo4j/plugins/bloom.jar

## Licenses
COPY --chown=neo4j:neo4j ./private/gds.license /gds.license
COPY --chown=neo4j:neo4j ./private/bloom.license /bloom.license