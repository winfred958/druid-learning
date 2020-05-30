# Design
 - ```text
   Druid 是一个多进程, 分布式, 被设计成云友好且易操作.
   每一个Druid进程都能独立的配置和独立伸缩, 给你最大的自由度.
   这样的实际同样增强了容错能力: 一个组件失效不会直接影响其他组件.
   ```

# Process and Servers

Druid 有几种进程类型, 如下:
 - [Coordinator](./05-Coordinator-Process.md)
 - Overload
 - Broker
 - Router
 - [Historical](./06-Historical-Process.md)
 - MiddleManager 
 
Druid 进程能被任意部署, 但是为了部署简单, 我们推荐区分三种Server Type: 
 - Master
    - Run Coordinator and Overload process.
 - Query
    - Run Broker and optional Router process.
 - Data
    - Run Historical and MiddleManager process.

# External dependencies

# Deep storage
 - Druid 使用 deep storage 存储ingested数据, deep storage 可以是hdfs, s3 等分布式文件系统.
 - Druid 使用 deep storage 仅作为后台进程间(historical)数据传输.
 - To respond to queries(响应查询), historical 不能read from deep storage, 而是从historical本地磁盘获取segment. 这意味着Druid 查询时不需要访问 deep storage. 也意味着在deep storage和historical之间, 必须有足够的磁盘空间(local disk),用来 load 指定时间段的segment.
 - Deep storage 是druid 弹性, 容错的重要的组成部分. Druid 能 bootstrap from deep storage 在个别 historical 丢失状态时.
 - 详细, 请看[Deep Storage](#)
# Metadata storage
# Zookeeper
# Storage design
## [Datasources and segments](https://druid.apache.org/docs/latest/design/architecture.html#datasources-and-segments)
## [Indexing and handoff](https://druid.apache.org/docs/latest/design/architecture.html#indexing-and-handoff)
## [Segment identifiers](https://druid.apache.org/docs/latest/design/architecture.html#segment-identifiers)