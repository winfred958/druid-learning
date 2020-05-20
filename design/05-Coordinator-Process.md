# Coordinator Process

## [Overview](https://druid.apache.org/docs/latest/design/coordinator.html#overview)
 - Coordinator 进程主要负责 segment 的管理和分配. 具体的说, Coordinator进程与Historical进程通信, 根据配置load/drop segment.
     - Coordinator 负责 load new segment, drop outdated segment
     - 确保 segment 的 replica数正确.
     - moving/balancing segment 在 Historical Node 之间, 确保Historical均匀的加载. 
 - Coordinator 周期性的运行,周期可配置.每一次运行都会评估集群当前状态,然后决定采取的适当操作.
    - coordinator 和 broker, historical 进程一样, 维护当前集群信息到Zookeeper集群的连接
    - coordinator 还维护一个DB连接, 该数据库包含关于, 已使用segment(loaded segment)和加载规则(load ruler)的信息
 - Segment 分配规则
    - 在一些未指派historical 进程的segments, Historical 首先会根据 tier 的容量排序, 容量小的historical有最高优先级.
    - 未指派的segment总是分配给容量最小的historical进程, 以保持进程(节点)之间的平衡.
    - Coordinator 不直接与historical进程通信 在分配新segment时候.
        - coordinator创建一些关于new segment的临时信息在historical 进程将要加载的的队列路径.
        - 一旦遇到请求, historical进程将load segments
        
## [Cleaning up segments](https://druid.apache.org/docs/latest/design/coordinator.html#cleaning-up-segments)
Coordinator 会周期性的运行, 比较数据库中记录的used segment和historical节点的segment进行比较, Coordinator发送请求至historical节点, unload 没有使用的segment 或 segments信息已经从元数据库中移除的segments.
Segments 被 overshadowed(segments version ard too old and their data has been replaced by newer segments) 将被标记为 unused, 在Coordinator下一个周期被 historical unload.
## [Segment availability](https://druid.apache.org/docs/latest/design/coordinator.html#segment-availability)
 1. 如果 a historical process restart 或 由于其他一些原因 becomes unavailable, Coordinator 将会notice 到这个historical进程已经 missing, 把这个historical节点的segments标记为 dropped.
 2. 

## [Balancing segment load](https://druid.apache.org/docs/latest/design/coordinator.html#balancing-segment-load)
 1. 为了确保 segments 在 historical节点均匀的分配, coordinator进程 会周期的检查每个historical总的segments大小.
 2. 对于集群中的每一个 historical tier, coordinator 进程将确认historical利用率最高(highest utilization)的和historical利用率最低(lowest utilization)的.
 3. high low 利用率之间的差异如果超过某个阈值, 则将 a number of segments 从利用率最高的historical移动到利用率最低的historical.
 4. 每个周期, 从一个historical移动到另一个historical的segments数量上有配置限制.
 5. 被移动的segments是随机选择的, 并且仅在结果利用率计算表明最高和最低服务器之间的百分比差异减小时才移动。
