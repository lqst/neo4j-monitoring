# Setup

## Minikube tricks
Create docker network
```shell
docker network create neo4jnetwork
```

Mount the config folder to the minikube docker host
```shell
minikube mount config:/config
```

## Neo4j Conf

Docker:
```parameters
-e NEO4J_metrics_prometheus_enabled=true \
-e NEO4J_metrics_prometheus_endpoint=0.0.0.0:2004 \
```

Or in neo4j conf:
```parameters
metrics.prometheus.enabled=true
metrics.prometheus.endpoint=0.0.0.0:2004
```

## Grafana

192.168.64.3:3000