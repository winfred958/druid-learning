# Config Verify & Tuning

## DirectMemory Verify
 - verifyDirectMemory: Druid 堆外内存校验
    - MaxDirectMemory least = druid.processing.buffer.sizeBytes * (druid.processing.numMergeBuffers + druid.processing.numThreads +1)
        - ```text
          "Not enough direct memory. Please adjust 
              -XX:MaxDirectMemorySize,
              druid.processing.buffer.sizeBytes,
              druid.processing.numThreads,
              or druid.processing.numMergeBuffers:maxDirectMemory[%,d],
          memoryNeeded[%,d] = druid.processing.buffer.sizeBytes[%,d] * (druid.processing.numMergeBuffers[%,d] + druid.processing.numThreads[%,d] + 1)"
          ```
    - 或者 SET -XX:MaxDirectMemorySize = 25% * (-Xmx)jvm heap size
        - ```text
          "Unable to determine max direct memory size. If druid.processing.buffer.sizeBytes is explicitly configured, 
          then make sure to set -XX:MaxDirectMemorySize to at least \"druid.processing.buffer.sizeBytes * 
          (druid.processing.numMergeBuffers[%,d] + druid.processing.numThreads[%,d] + 1)\", 
          or else set -XX:MaxDirectMemorySize to at least 25% of maximum jvm heap size.",
          ```
## DirectMemory About 
 - druid.processing.buffer.sizeBytes
    - (auto max 1G), (middleManager, historical)中间结果计算, 聚合
        - historical: ~500M
        - broker: ~500M
        - middleManager: ~100M
 - druid.processing.numThreads
    - [1, number of core -1]
 - druid.processing.numMergeBuffers
    - max(2, druid.processing.numThreads / 4)
 - JVM MaxDirectMemory
    - least = druid.processing.buffer.sizeBytes * (druid.processing.numMergeBuffers + druid.processing.numThreads +1)
 - druid.server.http.numThreads
    - max(10, (Number of cores * 17) / 16 + 2) + 30
    
## 基本优化 [Basic cluster tuning](https://druid.apache.org/docs/latest/operations/basic-cluster-tuning.html)
- ### [Historical](https://druid.apache.org/docs/latest/operations/basic-cluster-tuning.html#historical)
    - #### Heap size
        - 一般经验调整 historical heap size = 0.5G * number of CPU cores, 上限~24G.
            - 注意: 这个不是确定historical heap size 的硬性指标
        - heap 太大会导致GC暂停时间过长, 设置上限~24G是为了避免这种情况.
        - 如果在 historical 启动cache, cache 将在 heap 中分配. 大小由 **druid.cache.sizeInBytes** 决定.
        - Historical out of heap 可能表明配置错误或使用模式导致集群超载.
    - #### Processing Threads and Buffers
        - 请看[General Guidelines for Processing Threads and Buffers](https://druid.apache.org/docs/latest/operations/basic-cluster-tuning.html#processing-threads-buffers) 部分,综合描述了processing thread/buffer配置.
        - **druid.processing.numThreads**
            - 控制用户查询结果处理线程池的大小. 这个线程池限制了可以并发处理的查询数.
            - 设置过小cpu利用率不足, 设置过大造成不必要的线程切换, 通常设置为
                - number of cores -1
        - **druid.processing.buffer.sizeBytes** 
            - 控制分配给处理线程的堆外缓冲区大小
            - 为每个线程分配缓冲区, 一般 500M到1G之间
            - TopN和Group By 查询使用这些缓冲区存储中间结果, **随着缓冲区大小的增加, 一次可以处理更多的数据**
        - **druid.processing.numMergeBuffers**
            - GroupBy V2 query 使用额外的堆外缓冲池来 merge 查询结果.
            - processing.numMergeBuffers 与 processing.numThreads 1:4
    - #### Direct Memory Sizing
        - 当 historical 进程处理query时, 它必须打开多个segment, 这需要 direct memory space, 这个在 [segment decompression buffers](https://druid.apache.org/docs/latest/operations/basic-cluster-tuning.html#segment-decompression) 有描述.
            - Segment decompression
                - 当查询或合并segment时候, 都需要打开segment读取, druid 为每个 column 分配 64K 大小的 off-heap decompression buffer.
                - 因此, 在segment 读取的时候, 会有 direct memory 开销(64K * segment column数量 * segment数量)
            - **计算Direct Memory的公式如下**
                - (druid.processing.numThreads + druid.processing.numMergeBuffers + 1) * druid.processing.buffer.sizeBytes
                - +1 是一个模糊的估值, 用于解释 segment decompression buffers.
    - #### Connection pool sizing
    - #### Segment Cache Size
        - **druid.server.maxSize**
            - 控制Coordinator分配给Historical的segment总大小
        - **druid.segmentCache.locations**
            - 指定segment存储在Historical中的位置
            - 这些位置的磁盘可用空间总和应等于druid.server.maxSize
            - Segment 被Historical 进程利用 memory-mapped技术加载到 free system memory中, System cache 不存在才会从磁盘加载.
            - 因此,druid.server.maxSize 应该确保不会给Historical分配过多的segment, **随着(free system memory / druid.server.maxSize)比例增大, 可以提高查询性能**.
    - #### Number of Historical
        - Historical数量取决于集群有多少数据, 为了更好的性能, 你需要足够的 Historical 以便维持很好的(free system memory / druid.server.maxSize)比例, 就像Segment Cache Size描述的那样.
        - 有少量的大服务器通常比有大量的小服务器要好, 只要有足够的容错能力来满足需求.
    - #### SSD storage
        - Historical 推荐使用ssd, 因为Historical 需要cache segment (memory-mapped).
    - #### Total memory usage
        - 使用以下准则来估算内存用量
            - Heap:
                - (0.5GB * number of CPU cores) + (2 * total size of lookup maps) + druid.cache.sizeInBytes
            - Direct Memory:
                - (druid.processing.numThreads + druid.processing.numMergeBuffers + 1) * druid.processing.buffer.sizeBytes
        - Historical 将利用 available free system memory 采样 memory-mapping 加载磁盘数据. 为了更好的查询性能, 需要保证(free system memory / druid.server.maxSize)比例, 以便cache 更多的 segment 在内存中.
    - #### Segment sizes matter
        - **确保segment size 在 300M~700M**, 以便获得最佳性能
        - [segment size optimization](https://druid.apache.org/docs/latest/operations/segment-optimization.html)
- ### [Broker](https://druid.apache.org/docs/latest/operations/basic-cluster-tuning.html#broker)
    - #### Heap size
        - heap 在 Broker的作用:
            - 部分未merge的来自Historical查询结果
            - The segment timeline: 包含当前所有 available segment的位置信息 --- 哪个Historical serving 哪些segment.
            - Cached segment metadata: 包含每个segment的metadata.
        - Broker heap 需要根据segment数量伸缩
            - heap size根据数据大小和使用模式决定, 如果集群servers 小于15, 那么 4G~8G是一个很好的开始
            - servers ~100, 将需要Broker heaps of 30G~60G
        - **Broker cache enable, cache 将会被存储在heap中, 大小取决于 druid.cache.sizeInBytes**
    - #### Direct memory size
        - On the Broker, direct memory 取决于多少merge buffers(用来merge GroupBy), Broker 通常不需要处理线程或缓冲区, 因为查询结果在heap合并到 http线程中.
            - druid.processing.buffer.sizeBytes
                - can be set to 500MB
            - druid.processing.numThreads
                -  set this to 1 (the minimum allowed)
            - druid.processing.numMergeBuffers
                - set this to the same value as on Historicals or a bit higher. >= historical的numMergeBuffers
    - #### Connection pool sizing
        - [General Connection Pool Guidelines](https://druid.apache.org/docs/latest/operations/basic-cluster-tuning.html#connection-pool)
        - On the Broker, 确保 druid.broker.http.numConnections 总和估值要低于 Historical 的 druid.server.http.numThreads
        - 优化集群让每个Historical can accept 50 个 queries 和 10 个非查询, 并相应的调整代理参数, 这是一个合理的起点.
    - #### Broker backpressure
        - xx
    - #### Number of brokers
        - 1:15 的broker与historical比例, 是个合理的点
        - 如果需要broker HA, 至少2个broker
    - #### Total memory usage
        - 评估总的 memory 可以用以下指导方针:
            - Heap: allocated heap size
            - Direct Memory: (druid.processing.numThreads + druid.processing.numMergeBuffers + 1) * druid.processing.buffer.sizeBytes
- ### [MiddleManager](https://druid.apache.org/docs/latest/operations/basic-cluster-tuning.html#middlemanager) 
    - MiddleManager 是一个轻量进程, 控制和管理 启动的 ingestion task
    - #### MiddleManager heap sizing
        - MiddleManager 本身不需要太多资源, 通常设置 ~128M
    - #### SSD storage
        - MiddleManager 推荐使用SSD, MiddleManager launch task handle segment 存储在磁盘上, 对磁盘IO有要求.
    - #### Task Count
        - MiddleManager **最大 launch 的task数由 druid.worker.capacity 控制**.
        - worker 进程数量取决于集群需要启动多少个并发task, 单个MiddleManager能启动的task数取决于系统资源大小.
        - 可以申请更多MiddleManager节点提高集群task容量.
    - #### Task configuration
        - ingestion task 配置, task 需要执行 query和 ingestion, 因此需要比MiddleManager更多的资源.
        - ##### Task heap sizing
            - 1G heap 通常足够了
        - ##### Lookups
            - 如果使用lookups,
        - ##### Task processing threads and buffers
            - task 进程比historical保存更少的数据,所以 1 ~ 2 个线程就够了
                - druid.indexer.fork.property.druid.processing.numThreads: 1~2
                - druid.indexer.fork.property.druid.processing.numMergeBuffers: 2
                - druid.indexer.fork.property.druid.processing.buffer.sizeBytes: 100M
        - ##### Direct memory sizing
            - 上面描述的 processing buffer 和 merge buffer 都是direct memory buffers.
            - 当处理查询任务时, 必须打开 segment 进行读取, 也需要一些 direct memory,在[segment decompression buffers](https://druid.apache.org/docs/latest/operations/basic-cluster-tuning.html#segment-decompression) 有描述.
            - ingestion task 也需要 merge 部分 ingestion results, 需要 direct memory 空间. [segment merging.](https://druid.apache.org/docs/latest/operations/basic-cluster-tuning.html#segment-merging) 
            - 计算direct memory公式: (druid.processing.numThreads + druid.processing.numMergeBuffers + 1) * druid.processing.buffer.sizeBytes
        - ##### Connection pool sizing
    - #### Total memory usage
    
        