# Overlord Process

## Configuration

- For Apache Druid Overlord Process Configuration, see Overlord Configuration.

## HTTP endpoints

- For a list of API endpoints supported by the Overlord, please see the API reference.

## Overview

- Overload 进程负责接收任务, 协调任务分布, 为任务创建锁, 返回任务状态给调用方.
    - is responsible for accepting tasks and returning statuses to callers
    - coordinating task distribution
    - creating locks around tasks
- Overload 可以配置两种运行模式 local or remote:
    - local (default)
        - Overload 既负责 creating Peons 也负责 executing task. 用于简单工作流.
    - remote
        - Overlord and middleManager 分别运行在各自独立的进程.
        - 如果需要使用index service as the single endpoint, 推荐这种使用方式.

## Overload Console

- The Overload provides a UI for managing tasks and workers.
- For more details,
  请看 [overload console](https://druid.apache.org/docs/latest/operations/management-uis.html#overlord-console)

## Blacklisted workers

- 如果 middleManager 任务失败数量超过阈值, Overload 将会把这个middleManager加入黑名单.