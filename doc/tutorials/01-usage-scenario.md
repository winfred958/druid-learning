# Druid 使用场景
## 1. Druid 应用领域
 - 点击流分析
 - 网络监测数据分析
 - IoT以及服务端监控指标存储
 - 供应链分析
 - 数字营销/广告分析
 - BI/OLAP
## 2.适用场景 [When should I use Druid?](https://druid.apache.org/docs/latest/design/index.html#when-should-i-use-druid)
 - Insert 频率高, update 少.
 - 大多数查询都是聚合查询 (group by agg).
 - 查询延迟目标在100ms至秒级.
 - 数据有时间戳.
 - 星型模型, 只有一个fact表 join 维表的场景.
 - 对fact表数据快速的**聚合计算和排序**
 - 想加载kafka, hdfs, local file, object storage数据.
## 3.不适用场景
 - 使用 primary key 进行低延时的update, Druid支持流式写入不支持流式(实时)update. Druid update是使用后台批处理完成的.
 - 离线报表系统, 对延时不敏感
 - 你想用雪花模型, join 多个fact table.