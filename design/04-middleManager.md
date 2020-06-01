# [MiddleManager Process](https://druid.apache.org/docs/latest/design/middlemanager.html)

## Configuration
 - For Apache Druid MiddleManager Process Configuration, see [Indexing Service Configuration](https://druid.apache.org/docs/latest/configuration/index.html#middlemanager-and-peons).
## HTTP endpoints
 - For a list of API endpoints supported by the MiddleManager, please see the [API reference](https://druid.apache.org/docs/latest/operations/api-reference.html#middlemanager).
## Overview
 - MiddleManager 进程是一个管理已经提交task的worker process.
 - MiddleManager 负责创建 Peon, 分配task给单个的JVM进程Peon, 这样做的原因是为了资源和日志的隔离.
 - Each [Peon](https://druid.apache.org/docs/latest/design/peons.html) 一次只能运行一个task, a middleManager 有多个 Peons.
## Running
 - ```text
   org.apache.druid.cli.Main server middleManager
   ```

 # Peons
 ## Configuration
  - For Apache Druid Peon Configuration, see Peon Query Configuration and Additional Peon Configuration.
 
 ## HTTP endpoints
  - For a list of API endpoints supported by the Peon, please see the Peon API reference.
  - Peons run a single task in a single JVM. MiddleManager is responsible for creating Peons for running tasks. Peons should rarely (if ever for testing purposes) be run on their own.
 
 ## Running
 - The Peon should very rarely ever be run independent of the MiddleManager unless for development purposes.
 - ```text
   org.apache.druid.cli.Main internal peon <task_file> <status_file>
   ```
 - The task file contains the task JSON object. The status file indicates where the task status will be output.