# Config Verify

## DirectMemory Verify
 - verifyDirectMemory: Druid  进程启动时
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
    - (auto max 1G)
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