# hdfs 作为DeepStorage
### conf/druid/_common/common.runtime.properties
- 已经存在项
  - druid.extensions.loadList=["druid-hdfs-storage"]
  - druid.storage.type=hdfs
# cos 作为DeepStorage
### conf/druid/_common/common.runtime.properties
- 已经存在项
  - druid.extensions.loadList=["druid-hdfs-storage"]
  - druid.storage.type=hdfs
- 需要修改项
  - druid.storage.storageDirectory=cosn://\<BucketName\>-\<AppId>/\<path\>/druid/segments
### conf/druid/_common/hdfs-site.xml
- copy 集群的 hdfs-site.xml, 增加cos认证信息(如果没有的话)

### druid配置cos步骤
```markdown
3个步骤:
  1. hadoop开启COS访问
  2. 编写EMR引导脚本并上传COS
  3. 配置EMR引导脚本
详细操作步骤请看下文
```
- 1.控制台自助开启COS (创建但未开启 COS 的集群)
  - 文档: [https://cloud.tencent.com/document/product/589/40366](https://cloud.tencent.com/document/product/589/40366)
  - 配置完成后, EMR会自动在hadoop配置文件/usr/local/service/hadoop/etc/hadoop/core-site.xml 增加如下cos配置信息
    - ```xml
      <configuration>
       <property>
           <name>fs.cos.buffer.dir</name>
           <value>/data/emr/hdfs/tmp</value>
       </property>
       <property>
           <name>fs.cos.local_block_size</name>
           <value>2097152</value>
       </property>
       <property>
           <name>fs.cos.userinfo.appid</name>
           <value>1258469122</value>
       </property>
       <property>
           <name>fs.cos.userinfo.region</name>
           <value>bj</value>
       </property>
       <property>
           <name>fs.cos.userinfo.secretId</name>
           <value>xxxxxxxxxxxxxxxxxxxxxxxxx</value>
       </property>
       <property>
           <name>fs.cos.userinfo.secretKey</name>
           <value>xxxxxxxxxxxxxxxxxxxxxxxxx</value>
       </property>
       <property>
           <name>fs.cos.userinfo.useCDN</name>
           <value>false</value>
       </property>
       <property>
           <name>fs.cosn.block.size</name>
           <value>67108864</value>
       </property>
       <property>
           <name>fs.cosn.impl</name>
           <value>org.apache.hadoop.fs.cosnative.NativeCosFileSystem</value>
       </property>
       <property>
           <name>fs.cosn.local_block_size</name>
           <value>2097152</value>
       </property>
       <property>
           <name>fs.cosn.tmp.dir</name>
           <value>/data/emr/hdfs/tmp/hadoop_cos</value>
       </property>
       <property>
           <name>fs.cosn.userinfo.region</name>
           <value>ap-beijing</value>
       </property>
      </configuration>
      ```
  - 至此, 就可以使用hdfs命令访问cos数据
    - hadoop fs -ls cosn://\<BucketName\>-\<AppId>/\<path\>
- 2.编写EMR引导操作脚本, 并上传至cos
  - 步骤1, 中hadoop已经集成了cos, 现在只需要软链接hadoop配置至druid _common配置中; 然后修改druid.storage.storageDirectory路径至cos
    - 例如, druid.storage.storageDirectory=cosn://emr-druid-deep-test-1258469122/druid/segment
  - 参考脚本, 其中**druid.storage.storageDirectory需要根据实际COS路径修改**
    - ```shell script
      #!/bin/bash
      
      # 1. 替换 DeepStorage 为 COS 路径, 文档地址: https://cloud.tencent.com/document/product/589/43556#.E4.BD.BF.E7.94.A8-cos
      # sed 替换hdfs路径为cos路径, sed -i '/<目标行>/s/<需要替换的内容>/<替换后内容>/g' <目标文件>
      sed -i '/^druid.storage.storageDirectory/s/druid.storage.storageDirectory.*/druid.storage.storageDirectory=cosn:\/\/emr-druid-deep-test-1258469122\/druid\/segment/g' /usr/local/service/druid/conf/druid/_common/common.runtime.properties
      
      # 2. druid的hdfs(cos)配置, 针对扩容节点
      ln -s /usr/local/service/hadoop/etc/hadoop/core-site.xml    /usr/local/service/druid/conf/druid/_common/core-site.xml
      ln -s /usr/local/service/hadoop/etc/hadoop/hdfs-site.xml    /usr/local/service/druid/conf/druid/_common/hdfs-site.xml
      ln -s /usr/local/service/hadoop/etc/hadoop/mapred-site.xml  /usr/local/service/druid/conf/druid/_common/mapred-site.xml
      ln -s /usr/local/service/hadoop/etc/hadoop/yarn-site.xml    /usr/local/service/druid/conf/druid/_common/yarn-site.xml
      ```
  - 脚本上传至cos
- 3.配置EMR引导操作脚本, (选择 - 集群启动前)
  - EMR引导操作文档
    - [https://cloud.tencent.com/document/product/589/35656](https://cloud.tencent.com/document/product/589/35656)
