# druid数据迁移 (MetaDB: MySQL, DeepStorage: hdfs)

## DeepStorage Migration

### Copy segments from old deep storage to new deep storage.

# 全量迁移

## Metadata Migration

- segments
- rules
- config
- datasource
- supervisors

### Derby 可以直接使用工具[Derby migration](https://druid.apache.org/docs/latest/operations/export-metadata.html)

# Druid 单数据源迁移

## 1. DeepStorage 迁移

- 直接copy segment数据
    - hadoop distcp -update hdfs://<SOURCE_HDFS>/druid/segments/<DATASOURCE_NAME> hdfs://<TARGET_HDFS>/druid/segments/<
      DATASOURCE_NAME>

## 2. Metadata 迁移

### 2.1 Source Metadata DB

1. 查看表 druid.druid_segments

- 记录 segment MAX start end time
- 记录 segment MIN start end time

2. 导出需要迁移的segment元数据

- mysqldump --host=<source> --port=<source> --user=<source> -p'<source>' -t druid druid_segments --where=" dataSource
  = '<DATASOURCE_NAME>' AND end < '<迁移截断时间点>'" > ./transform-druid_segments.sql

### 2.2 Target Metadata DB

1. 备份数据

- mysqldump --host=<source> --port=<source> --user=<source> -p'<source>' -t druid druid_segments --where=" dataSource
  = '<DATASOURCE_NAME>'" > ./backup-druid_segments.sql

2. 查看表 druid.druid_segments

- 记录 segment MAX start end time
- 记录 segment MIN start end time

3. 和 **2.1步骤 确认迁移截断时间点**
4. 修改 transform-druid_segments.sql, 替换hdfs路径的 nameservice

- vim transform-druid_segments.sql
    - :%s/<SOURCE_HDFS>/<TARGET_HDFS>/g

5. 元数据迁移 Target DB

- mysqldump --host=<source> --port=<source> --user=<source> -p'<source>' --execute="use druid; source
  transform-druid_segments.sql"

## 3. Load 数据到 historical, (Target Druid)

1. druid ui, DataSource页面
2. 点击 Reload data by interval

- segment MIN time/<迁移截断时间点>

3. 等待reload
