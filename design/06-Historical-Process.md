# [Historical Process](https://druid.apache.org/docs/latest/design/historical.html)

## [Loading and serving segments](https://druid.apache.org/docs/latest/design/historical.html#loading-and-serving-segments)
 1. 每1个 Historical进程维护了1个和Zookeeper的长连接并且watch 1个可配置的Znode一遍获取最新的segment信息. Historical进程间不通信, 也不与Coordinator直接进程通信, 而是依赖 Zookeeper协调.
 2.  