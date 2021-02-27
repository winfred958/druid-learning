# [Metadata storage](https://druid.apache.org/docs/latest/dependencies/metadata-storage.html)

## Segments 信息

- segment 元数据信息
  ```json
    {
        "dataSource":"wikipedia",
        "interval":"2012-05-23T00:00:00.000Z/2012-05-24T00:00:00.000Z",
        "version":"2012-05-24T00:10:00.046Z",
        "loadSpec":{
            "type":"s3_zip",
            "bucket":"bucket_for_segment",
            "key":"path/to/segment/on/s3"
        },
        "dimensions":"comma-delimited-list-of-dimension-names",
        "metrics":"comma-delimited-list-of-metric-names",
        "shardSpec":{"type":"none"},
        "binaryVersion":9,
        "size": size_of_segment,
        "identifier":"wikipedia_2012-05-23T00:00:00.000Z_2012-05-24T00:00:00.000Z_2012-05-23T00:10:00.046Z"
    }
  ```