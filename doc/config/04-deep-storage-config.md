# DeepStorage config
- 目录
    - [druid使用local hdfs作为DeepStorage](https://github.com/winfred958/druid-learning/blob/master/doc/config/04-deep-storage-config.md#11-%E8%BD%AF%E9%93%BE%E6%8E%A5%E6%9C%AC%E5%9C%B0hadoop%E9%85%8D%E7%BD%AE%E6%96%87%E4%BB%B6%E5%88%B0-druid-common%E7%9B%AE%E5%BD%95)
    - [druid使用remote hdfs作为DeepStorage](https://github.com/winfred958/druid-learning/blob/master/doc/config/04-deep-storage-config.md#2-druid%E4%BD%BF%E7%94%A8remote-hdfs%E4%BD%9C%E4%B8%BAdeepstorage)
    - [cos作为DeepStorage](https://github.com/winfred958/druid-learning/blob/master/doc/config/04-deep-storage-config.md#3-cos%E4%BD%9C%E4%B8%BAdeepstorage)

## 1. druid使用本地hdfs作为DeepStorage

#### 1.1. 软链接本地hadoop配置文件到 druid common目录
- 参考脚本
    - ```shell
      cd /usr/local/service/druid/conf/druid/_common/
      ln -s /usr/local/service/hadoop/etc/hadoop/core-site.xml core-site.xml
      ln -s /usr/local/service/hadoop/etc/hadoop/hdfs-site.xml hdfs-site.xml
      ```
#### 1.2. 控制台配置segments存储路径, ${DRUID_HOME}/conf/druid/_common/common.runtime.properties
- 已经存在项
    - druid.extensions.loadList=["druid-hdfs-storage"]
    - druid.storage.type=hdfs
#### 1.3 配置下发, 重启 middleManager historical

## 2. druid使用remote hdfs作为DeepStorage

```markdown
方案一. 修改druid集群 hdfs默认配置(不推荐, 方案暂时不可行)
- 会使druid本地hdfs不可用
- 控制台配置下发有默认值, 集群 dfs.nameservices 等, 关键参数不允许随意修改, 所以此方案暂时不可行
方案二. copy remote hdfs config -> druid common config目录
- 缺点, 扩容麻烦(可以采用EMR引导操作解决, 可以在druid启动前从远程(cos)下载配置)
```

### 2.1 download remote hdfs config 保存到本地IDE修改关键配置(如果需要的话)
### 2.2 remote hdfs config copy到  druid common 目录
- **注意**, 针对cos的配置
    - ```text
      EMR Druid 目前版本默认包含cos配置并且进行了优化封装
      copy 配置时需要注意EMR版本间的差异, cos 需要和druid 本地配置保持一致, 必要时需要手动修改cos配置
      ```
- cos详细配置请看第3部分 [cos作为DeepStorage](https://github.com/winfred958/druid-learning/blob/master/doc/config/04-deep-storage-config.md#3-cos%E4%BD%9C%E4%B8%BAdeepstorage)

### 2.3 配置EMR引导操作, 目的是在集群扩容时自动下载指定的hadoop配置
#### 2.3.1 上传hadoop配置到druid集群同地域的cos目录(该目录为用户自定义, 存放配置文件目录)
- 上传配置到自定义cos目录
- 记录文件地址
#### 2.3.2 编写引导操作脚本, 并且上传到druid集群同地域的cos目录(用该目录为用户自定义, 存放引导脚本的目录)
- 编写shell脚本, 脚本功能为下载 cos文件(步骤2.3产生)放置到druid common 配置目录
    - 脚本参考, 注意 ${BUKET_NAME} ${APP_ID} 等为变量, 需要替换为实际值
        - ```shell script
          #!/bin/bash
          # 删除druid本地hdfs配置
          rm /usr/local/service/druid/conf/druid/_common/*-site.xml
          cd /usr/local/service/druid/conf/druid/_common/
          # 下载hdfs配置
          wget https://${BUKET_NAME}-${APP_ID}.cos.${REGION_TAG}.myqcloud.com/${FOLDER}/core-site.xml
          wget https://${BUKET_NAME}-${APP_ID}.cos.${REGION_TAG}.myqcloud.com/${FOLDER}/hdfs-site.xml
          wget https://${BUKET_NAME}-${APP_ID}.cos.${REGION_TAG}.myqcloud.com/${FOLDER}/yarn-site.xml
          wget https://${BUKET_NAME}-${APP_ID}.cos.${REGION_TAG}.myqcloud.com/${FOLDER}/mapred-site.xml
          ```
#### 2.3.3 配置EMR引导操作, [EMR 引导操作文档](https://cloud.tencent.com/document/product/589/35656)      
- 引导时机选择 
    - 选择 - 集群启动前

## 3. cos作为DeepStorage
```text
文档编写时间2020年12月25日
目前版本创建的druid集群默认支持cos
以下是默认配置
```
### 3.1. conf/druid/_common/common.runtime.properties
- cos 依赖druid-hdfs-storage扩展
    - druid.extensions.loadList=["druid-hdfs-storage"]
    - druid.storage.type=hdfs
- 需要修改项
    - druid.storage.storageDirectory=cosn://\<BucketName\>-\<AppId>/\<path\>/druid/segments

### 3.2. druid集群cos配置信息
- 目前版本, EMR已经默认开启COS(dependency-jar: /usr/local/service/hadoop/share/hadoop/common/lib/hadoop-temrfs-*.jar)
    - EMR会自动在hadoop配置文件/usr/local/service/hadoop/etc/hadoop/core-site.xml 增加如下cos相关配置信息
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
              <value>${appId}</value>
            </property>
            <property>
              <name>fs.cos.userinfo.region</name>
              <value>gz</value>
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
              <name>fs.cosn.credentials.provider</name>
              <value>org.apache.hadoop.fs.auth.EMRInstanceCredentialsProvider</value>
              <description>EMR提供,避免明文认证</description>
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
              <name>fs.cosn.upload.buffer</name>
              <value>mapped_disk</value>
            </property>
            <property>
              <name>fs.cosn.upload.buffer.size</name>
              <value>-1</value>
            </property>
            <property>
              <name>fs.cosn.userinfo.region</name>
              <value>ap-guangzhou</value>
            </property>
          </configuration>
          ```
    - 至此, 就可以使用hdfs命令访问cos数据
        - hadoop fs -ls cosn://\<BucketName\>-\<AppId>/\<path\>
        - hadoop --config ${HADOOP_CONF_DIR} fs -ls cosn://\<BucketName\>-\<AppId>/\<path\>
  
### 3.2. EMR中COS配置详解, 参考[hadoop-cos](https://github.com/tencentyun/hadoop-cos)

| 序号 | key | required | default value  | 描述 |
| :---- | :---- | :----: | :---- | :---- |
| 1  | fs.cos.buffer.dir            | yes | /data/emr/hdfs/tmp | 用于缓冲文件上传 |
| 2  | fs.cos.local_block_size      | no | 2097152 | 默认读取 block size |
| 3  | fs.cos.userinfo.appid        | yes | ${appId} | appid |
| 4  | fs.cos.userinfo.region       | yes | region id | 集群所在地域 |
| 5  | fs.cos.userinfo.useCDN       | no | false |  |
| 6  | fs.cosn.block.size           | no | 134217728(128M) | CosN 文件系统 block size。 默认 134217728(128M)|
| 7  | fs.cosn.credentials.provider | no | org.apache.hadoop.fs.auth.EMRInstanceCredentialsProvider | EMR认证方式 [EMRInstanceCredentialsProvider](https://github.com/tencentyun/hadoop-cos/blob/master/src/main/java/org/apache/hadoop/fs/auth/EMRInstanceCredentialsProvider.java) ; 配置 SecretId 和 SecretKey 的获取方式。当前支持五种获取方式：1.org.apache.hadoop.fs.auth.SessionCredential Provider：从请求 URI 中获取 secret id 和 secret key。 其格式为：cosn://{secretId}:{secretKey}@examplebucket-1250000000/； 2.org.apache.hadoop.fs.auth.SimpleCredentialProvider： 从 core-site.xml 配置文件中读取 fs.cosn.userinfo.secretId 和 fs.cosn.userinfo.secretKey 来获取 SecretId 和 SecretKey； 3.org.apache.hadoop.fs.auth.EnvironmentVariableCredential Provider：从系统环境变量 COS_SECRET_ID 和 COS_SECRET_KEY 中获取； 4.org.apache.hadoop.fs.auth.CVMInstanceCredentials Provider：利用腾讯云云服务器（CVM）绑定的角色，获取访问 COS 的临时密钥； 5.org.apache.hadoop.fs.auth.CPMInstanceCredentialsProvider： 利用腾讯云黑石物理机（CPM）绑定的角色，获取访问 COS 的临时密钥。|
| 8  | fs.cosn.impl                 | yes | org.apache.hadoop.fs.cosnative.NativeCosFileSystem | cosn 对 FileSystem 的实现类，固定为 org.apache.hadoop.fs.CosFileSystem。 |
| 9  | fs.cosn.local_block_size     |  | 2097152 |  |
| 10 | fs.cosn.tmp.dir              | no | /data/emr/hdfs/tmp/hadoop_cos | 请设置一个实际存在的本地目录，运行过程中产生的临时文件会暂时放于此处。 |
| 11 | fs.cosn.upload.buffer        | no | mapped_disk | CosN 文件系统上传时依赖的缓冲区类型。当前支持三种类型的缓冲区：非直接内存缓冲区（non_direct_memory），直接内存缓冲区（direct_memory），磁盘映射缓冲区（mapped_disk）。非直接内存缓冲区使用的是 JVM 堆内存，直接内存缓冲区使用的是堆外内存，而磁盘映射缓冲区则是基于内存文件映射得到的缓冲区。 |
| 12 | fs.cosn.upload.buffer.size   | no | -1 | CosN 文件系统上传时依赖的缓冲区大小，如果指定为-1，则表示不限制缓冲区。若不限制缓冲区大小，则缓冲区的类型必须为 mapped_disk。如果指定大小大于0，则要求该值至少大于等于一个 block 的大小。兼容原有配置 fs.cosn.buffer.size。 |
| 13 | fs.cosn.userinfo.region      | yes | ap-guangzhou | 	请填写待访问存储桶的地域信息，枚举值请参见 地域和访问域名 中的地域简称，例如：ap-beijing、ap-guangzhou 等。兼容原有配置：fs.cosn.userinfo.region。 |
 
