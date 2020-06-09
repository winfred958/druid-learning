# Config Verify

## DirectMemory Verify
 - verifyDirectMemory: Druid 堆外内存校验
    - MaxDirectMemory least = druid.processing.buffer.sizeBytes * (druid.processing.numMergeBuffers + druid.processing.numThreads +1)
        -  ```text
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
- ### historical
    - #### Heap size
        - 一般经验调整 historical heap size = 0.5G * number of CPU cores, 上限~24G.
            - 注意: 这个不是确定historical heap size 的硬性指标
        - heap 太大会导致GC暂停时间过长, 设置上限~24G是为了避免这种情况.
        - 如果在 historical 启动cache, cache 将在 heap 中分配. 大小由 **druid.cache.sizeInBytes** 决定.
        - Historical out of heap 可能表明配置错误或使用模式导致集群超载.
    - #### Processing Threads and Buffers
        - 请看[General Guidelines for Processing Threads and Buffers ](https://druid.apache.org/docs/latest/operations/basic-cluster-tuning.html#processing-threads-buffers)
        - druid.processing.numThreads
            - 控制用户查询结果处理线程池的大小. 这个线程池限制了可以并发处理的查询数.
        - druid.processing.buffer.sizeBytes 
            - 控制分配给处理线程的堆外缓冲区大小
            - 为每个线程分配缓冲区, 一般 500M到1G之间
            - TopN和Group By 查询使用这些缓冲区存储中间结果, 随着缓冲区大小的增加, 一次可以处理更多的数据
        