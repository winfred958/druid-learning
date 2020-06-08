#
## Overview
- overload coordinator 节点对计算资源要求较小.
- historical, middleManager, broker 节点比较吃资源.
    - broker, middleManager 主要吃CPU和内存资源.
    - historical 主要吃内存和磁盘.
- broker 数量主要用于查询的并行度.
## 硬件选择
- master server, 主要考虑CPU RAM (标准型) 例如: [AWS m5.2xlarge](https://aws.amazon.com/ec2/instance-types/m5/)
    - CPU 8 vCPUs
    - RAM 31 GB RAM
- data server, 主要考虑CPU RAM SSD (内存型 SSD) 例如: [AWS i3.4xlarge](https://aws.amazon.com/ec2/instance-types/i3/)
    - CPU 16 vCPUs +
    - RAM 128G ~ 256G
    - SSD 1.2T ~ 2*1.9T 
- query server, 主要考虑CPU RAM (标准型) 例如: [AWS m5.2xlarge](https://aws.amazon.com/ec2/instance-types/m5/)
    - CPU 8 vCPUs
    - RAM 31 GB RAM