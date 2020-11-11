# [Initializing the new metadata store](https://druid.apache.org/docs/latest/operations/metadata-migration.html#initializing-the-new-metadata-store)

## MySQL
```shell script
cd ${DRUID_ROOT}

java \
 -classpath "lib/*" \
 -Dlog4j.configurationFile=conf/druid/cluster/_common/log4j2.xml \
 -Ddruid.extensions.directory="extensions" \
 -Ddruid.extensions.loadList=[\"mysql-metadata-storage\"] \
 -Ddruid.metadata.storage.type=mysql org.apache.druid.cli.Main tools metadata-init \
 --connectURI="<mysql-uri>" \
 --user <user> \
 --password <pass> \
 --base druid
```

 
