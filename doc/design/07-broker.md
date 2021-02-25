# [Broker Process](https://druid.apache.org/docs/latest/design/broker.html)

## Configuration

## HTTP endpoints

## Overview

```text
解析其他进程发布到zookeeper中的元数据, 确定segment 所在节点, 然后分发请求到historical或middleManager所在的节点.
合并结果集, 计算并返回
```

### Forwarding queries

1. 大部分druid request 都包含时间区间. 同样的, Druid segments 被时间戳(区间)分区分布在集群中,
   分区粒度 [granularitySpec](https://druid.apache.org/docs/latest/ingestion/index.html#granularityspec).
   一个查询会匹配到多个segments, 这些segments可能分布在集群不同节点,不同进程中. 因此查询会碰到多个进程.
2. 为了决定request转发给哪个进程, Broker 先根据 zookeeper 中的信息构建一个 segments所在节点的全局视图. zookeeper 维护了 historical 和 ingestion peon(
   fork自middleManager) 进程所服务的segments 列表, Broker 将转发request到相应的进程.

### Caching

1. Broker 进程有 LRU 缓存失效策略, Broker cache 每个 segments 的结果集. 这个cache可以是 local 的也可以是 远程分布式缓存例如 memcached.
2. 当cache中不存在segments是会请求 historical 获取 the segments.
3. realtime segments 永远不会被缓存. 因为实时 segments 是实时变化的, 所以映射到实时segments的请求总是被直接转发到 realtime segments.

### Running

```text
org.apache.druid.cli.Main server broker
```