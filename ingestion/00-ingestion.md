# Ingestion

## Overview
- 所有数据在druid中都被组织成segment, 这些segment是文件, 通常每个segment有几百万行, 在druid中加载数据被称为ingest或index, 包括从从source读取数据并建立segment.
- 在大多数 ingestion method中, 数据加载工作是由 Druid MiddleManager(indexer process)进程负责的. 一个例外是基于Hadoop的摄入, 在这种请看下, 这些工作是使用Yarn上的 MapReduce作业完成的(MR启动和监控过程中仍然涉及到 MiddleManager).
- Segment 生成并存储在 [deep storage](https://druid.apache.org/docs/latest/dependencies/deep-storage.html) 中, Historical 进程将加载它们, 有关工作原理请看[Storage design](https://druid.apache.org/docs/latest/design/architecture.html#storage-design).

 