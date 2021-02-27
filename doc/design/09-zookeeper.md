# [zookeeper](https://druid.apache.org/docs/latest/dependencies/zookeeper.html)

## zookeeper 在druid的主要职责

1. 用于 realtime segment 发布到 historical过程的协调.
    - historical publish (announcementsPath), 将会创建 ephemeral znode
        - ```text
          {druid.zk.paths.announcementsPath}/{druid.host}
          ```
    - Which signifies that they exist. 随后将会创建 permanent znode
        - ```text
          {druid.zk.paths.servedSegmentsPath}/{druid.host}
          ```
    - historical 加载了 segment, 将会附加 ephemeral znodes
        - ```text
          {druid.zk.paths.servedSegmentsPath}/{druid.host}/_segment_identifier_
          ```
2. coordinator 和 historical 通信,  load/drop segment. 
   - 当 coordinator 确定由哪个historical加载或drop指定的segment, 将会写 ephemeral znode.
      - ```text
         {druid.zk.paths.loadQueuePath}/_host_of_historical_process/_segment_identifier
        ```