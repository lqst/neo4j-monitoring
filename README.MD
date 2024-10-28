# About
Playground for Metrics (prometheus, grafana) and Logging (promtail, loki and grafana)


# Docker Setup

Modify prometheus.yml scrape config


Create docker network (optional)
```shell
docker network create neo4jnetwork
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

Remark: Node and relationship counts are not enabled by default, add with:
```parameters
metrics.filter=*bolt.connections*,*bolt.messages_received*,*bolt.messages_started*,*dbms.pool.bolt.free,*dbms.pool.bolt.total_size,*dbms.pool.bolt.total_used,*dbms.pool.bolt.used_heap,*causal_clustering.core.is_leader,*causal_clustering.core.last_leader_message,*causal_clustering.core.replication_attempt,*causal_clustering.core.replication_fail,*check_point.duration,*check_point.total_time,*cypher.replan_events,*ids_in_use*,*pool.transaction.*.total_used,*pool.transaction.*.used_heap,*pool.transaction.*.used_native,*store.size*,*transaction.active_read,*transaction.active_write,*transaction.committed*,*transaction.last_committed_tx_id,*transaction.peak_concurrent,*transaction.rollbacks*,*page_cache.hit*,*page_cache.page_faults,*page_cache.usage_ratio,*vm.file.descriptors.count,*vm.gc.time.*,*vm.heap.used,*vm.memory.buffer.direct.used,*vm.memory.pool.g1_eden_space,*vm.memory.pool.g1_old_gen,*vm.pause_time,*vm.thread*,*db.query.execution*,*.neo4j.count.relationship,*.neo4j.count.node
```

Remark: for neo4j 5.x use:
```parameters
metrics.filter=*bolt.connections*,*bolt.messages_received*,*bolt.messages_started*,*dbms.pool.bolt.free,*dbms.pool.bolt.total_size,*dbms.pool.bolt.total_used,*dbms.pool.bolt.used_heap,*cluster.core.is_leader,*cluster.core.last_leader_message,*cluster.core.replication_attempt,*cluster.core.replication_fail,*cluster.core.last_applied,*cluster.core.last_appended,*check_point.duration,*check_point.total_time,*cypher.replan_events,*ids_in_use*,*pool.transaction.*.total_used,*pool.transaction.*.used_heap,*pool.transaction.*.used_native,*store.size*,*transaction.active_read,*transaction.active_write,*transaction.committed*,*transaction.last_committed_tx_id,*transaction.peak_concurrent,*transaction.rollbacks*,*page_cache.hit*,*page_cache.page_faults,*page_cache.usage_ratio,*vm.file.descriptors.count,*vm.gc.time.*,*vm.heap.used,*vm.memory.buffer.direct.used,*vm.memory.pool.g1_eden_space,*vm.memory.pool.g1_old_gen,*vm.pause_time,*vm.thread*,*db.query.execution*,*.neo4j.count.relationship,*.neo4j.count.node,*.cypher.replan_wait_time
```


## Start prometheus and kibana
```shell
docker-compose -f monitoring-compose.yml up
```

## Grafana dashboard

Navigate to localhost:3000 
- Default user/pass: admin/admin
- Import dashboard_5.json (for metics dashboard)
- Import querydashboard_5.json  (for query log dashboard)


## Start neo4j
```shell
docker compose -f cluster-compose.yml up
```

## Create demo database

Enable all servers from cypher shell
```cypher
show servers;
enable server "uuid";
enable server "uuid";
```

Create a demo database with topology
```cypher
create database demo topology 3 primaries 2 secondaries;
```


## Run firefox + vnc
docker run --network neo4jnetwork -p 8080:8080 -p 5900:5900 msjpq/firefox-vnc

connect with remote ripple or some other vnc client



## GDS notes

Setting up the database with 1 primary and 1 secondary
```cypher 
show servers yield serverId, name, address return *;
+---------------------------------------------------------------------------------------------------------+
| serverId                               | name                                   | address               |
+---------------------------------------------------------------------------------------------------------+
| "320a3c06-59da-47dc-8eaf-e69b6618e5c5" | "320a3c06-59da-47dc-8eaf-e69b6618e5c5" | "neo4j-server-5:7687" |
| "353d7a95-72eb-4edb-8cc7-212a01ac8e24" | "353d7a95-72eb-4edb-8cc7-212a01ac8e24" | "neo4j-server-4:7687" |
| "66b2e876-db14-4753-b451-2428f14aa1c1" | "66b2e876-db14-4753-b451-2428f14aa1c1" | "neo4j-server-1:7687" |
| "9079b113-c5f0-4886-8ab5-d10dea8875f5" | "9079b113-c5f0-4886-8ab5-d10dea8875f5" | "neo4j-server-3:7687" |
| "fa52a014-9fb3-49a2-8c63-9e7ac64f948f" | "fa52a014-9fb3-49a2-8c63-9e7ac64f948f" | "neo4j-server-2:7687" |
+---------------------------------------------------------------------------------------------------------+


RENAME SERVER '320a3c06-59da-47dc-8eaf-e69b6618e5c5' TO 'neo4j-server-5';
RENAME SERVER '353d7a95-72eb-4edb-8cc7-212a01ac8e24' TO 'neo4j-server-4';
RENAME SERVER '66b2e876-db14-4753-b451-2428f14aa1c1' TO 'neo4j-server-1';
RENAME SERVER '9079b113-c5f0-4886-8ab5-d10dea8875f5' TO 'neo4j-server-3';
RENAME SERVER 'fa52a014-9fb3-49a2-8c63-9e7ac64f948f' TO 'neo4j-server-2';

// I want my demo database to be on server 1 as primary and server 5 as secondary (GDS)
ALTER SERVER 'neo4j-server-2' SET OPTIONS {deniedDatabases:['demo']};
ALTER SERVER 'neo4j-server-3' SET OPTIONS {deniedDatabases:['demo']};
ALTER SERVER 'neo4j-server-4' SET OPTIONS {deniedDatabases:['demo']};

create database demo topology 1 primary 1 secondary;

```

Generate some data and run gds:

```cypher 

create (:Element{name:"Service 1"})<-[:LINK]-(:Element{name:"LB"})-[:LINK]->(:Element{name:"Service 2"});

// connect with bolt to server 5: 
// cypher-shell -a bolt://neo4j-server-5:7687 -d demo
// cypher-shell -a neo4j://neo4j-server-5:7687?tags=gds -d demo

call gds.graph.project('g1','*','*');
call gds.pageRank.write('g1', {writeProperty: 'pagerank'});

```

# Kubernetes (rancher desktop)

## Some setup
```shell
kubectl config set-context --current --namespace=neo4j
docker build -f Neo4j.dockerfile -t neo4jcustom:v01 .
```

## Neo4j
```shell
# deploy server1.yaml with:
helm install neo4j-test neo4j/neo4j --namespace neo4j -f server1.yaml
```

## Prometheus
```shell
kubectl create namespace monitoring
kubectl config set-context --current --namespace=monitoring
```

Create config map and deployment for Prometheus
```shell
kubectl create -f prometheus-config-map.yaml
kubectl create -f prometheus-deployment.yaml 
kubectl create -f prometheus-service.yaml --namespace=monitoring
```

Port forward to access Prometheus
Useful for debugging, service can also be accessed on http://localhost:30000/
```shell
port-forward prometheus...[check pod name] 8080:9090 -n monitoring
```


## Grafan
Create config map and deployment for Grafana
(still in monitoring namespace)

```shell
kubectl create -f grafana-config-map.yaml
kubectl create -f grafana-deployment.yaml 
kubectl create -f grafana-service.yaml --namespace=monitoring
```

```shell
kubectl delete -f grafana-config-map.yaml
kubectl delete -f grafana-deployment.yaml 
kubectl delete -f grafana-service.yaml --namespace=monitoring
```