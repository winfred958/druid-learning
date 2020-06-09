# 集群配置
## 1. master node
## 2. data node
- ### 1. middleManager
    - vim ${DRUID_HOME}/conf/druid/cluster/data/middleManager/runtime.properties 

        | key  | value  | describe |
        | --- | --- | --- |
        | druid.worker.capacity  | 4 | middleManager 所能启动的peon进程数(ingestion task数) |
        | druid.indexer.runner.javaOpts  | -server -Xms1g -Xmx1g -XX:MaxDirectMemorySize=1g -Duser.timezone=UTC -Dfile.encoding=UTF-8 -XX:+ExitOnOutOfMemoryError -Djava.util.logging.manager=org.apache.logging.log4j.jul.LogManager | peon进程的jvm参数
        | druid.indexer.fork.property.druid.processing.numMergeBuffers | 2 | buffer数 |
        | druid.indexer.fork.property.druid.processing.buffer.sizeBytes | 100000000 | buffer size |
        | druid.indexer.fork.property.druid.processing.numThreads | 1 | peon进程的线程数 |
- ### 2. historical
    - vim ${DRUID_HOME}/conf/druid/cluster/data/historical/runtime.properties 
## 3. query node