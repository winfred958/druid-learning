# [Segments](https://druid.apache.org/docs/latest/design/segments.html)
 - Druid 把 index 信息存储在以time分区的 segment file 中. 
 - 在基本的设置中,每一个时间间隔创建一个segment file,其中 time interval 可以在 [granularityspec](https://druid.apache.org/docs/latest/ingestion/index.html#granularityspec) 中配置 
 - 维持segment file 在 300M ~ 700M在负载很高的情况下很重要, 如果segment file 大于这个区间, 需要调整partitionsSpec 下的 targetPartitionSize, 更多信息请查看 [Batch ingestion](https://druid.apache.org/docs/latest/ingestion/hadoop.html#partitionsspec)
 
## Segment 物理文件组织方式
- druid/segment-cache/${datasource}/2020-05-16T01:00:00.000Z_2020-05-16T02:00:00.000Z/2020-05-14T23:01:00.217/${xxxId}/
    - 00000.smoosh
    - factory.json
    - meta.smoosh
    - version.bin