# Setup

Modify prometheus.yml scrape config

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

Remark: Node and relationship counts are not enabled by default, add with:
```parameters
metrics.filter=*bolt.connections*,*bolt.messages_received*,*bolt.messages_started*,*dbms.pool.bolt.free,*dbms.pool.bolt.total_size,*dbms.pool.bolt.total_used,*dbms.pool.bolt.used_heap,*causal_clustering.core.is_leader,*causal_clustering.core.last_leader_message,*causal_clustering.core.replication_attempt,*causal_clustering.core.replication_fail,*check_point.duration,*check_point.total_time,*cypher.replan_events,*ids_in_use*,*pool.transaction.*.total_used,*pool.transaction.*.used_heap,*pool.transaction.*.used_native,*store.size*,*transaction.active_read,*transaction.active_write,*transaction.committed*,*transaction.last_committed_tx_id,*transaction.peak_concurrent,*transaction.rollbacks*,*page_cache.hit*,*page_cache.page_faults,*page_cache.usage_ratio,*vm.file.descriptors.count,*vm.gc.time.*,*vm.heap.used,*vm.memory.buffer.direct.used,*vm.memory.pool.g1_eden_space,*vm.memory.pool.g1_old_gen,*vm.pause_time,*vm.thread*,*db.query.execution*,*.neo4j.count.relationship,*.neo4j.count.node
```


## Start
```shell
docker-compose up
```

## Grafana

Navigate to localhost:3000 
- Default user/pass: admin/admin
- Import dashboard.json