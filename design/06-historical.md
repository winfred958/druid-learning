# [Historical Process](https://druid.apache.org/docs/latest/design/historical.html)

## [Loading and serving segments](https://druid.apache.org/docs/latest/design/historical.html#loading-and-serving-segments)
 1. 每1个 Historical进程维护了1个和Zookeeper的长连接并且watch 1个可配置的Znode一遍获取最新的segment信息. Historical进程间不通信, 也不与Coordinator直接进程通信, 而是依赖 Zookeeper协调.
 2. Coordinator进程负责分配 new segments 给Historical进程. 分派是通过创建ZK 临时节点在historical节点关联的路径下/druid/loadQueue/${historical_host}:${historical_port}, 写入segments信息. 更多的Coordinator怎样分配segment给Historical, 请看[Coordinator](https://druid.apache.org/docs/latest/design/coordinator.html)
 3. 当Historical进程接收到 a new load queue 条目(segment), historical将首先检查local disk directory(就是 segment-cache)关于这个segment信息.
    - 如果本地cache不存在这个segment, historical将会从Zookeeper下载关于new segment的metadata. 这个metadata包含segment位于deep storage的何处以及如何解压缩和处理的规范.更多信息请看[segment](https://druid.apache.org/docs/latest/design/segments.html)
    - 一旦Historical进程完成1个segment的处理, 这个segment就会Zookeeper的 saved segment path 声明. 这个时候segment就和用于查询.
    
## [Loading and serving segments from cache](https://druid.apache.org/docs/latest/design/historical.html#loading-and-serving-segments-from-cache)
 1. 如果a local cache entry已经存在, Historical进程将直接从磁盘读取这个segment的二进制文件并加载.
 2. segment cache会被加载在Historical进程首次启动的时候. 在初始化时, Historical进程 会从头到尾search cache directory 并且立即加载找到的segment. 这个特性是为了在 Historical进程上线时 segment be queried.