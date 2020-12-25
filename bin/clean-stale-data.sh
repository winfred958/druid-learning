#!/bin/bash

CORRENT_PATH=$(
  cd "$(dirname "$0")"
  pwd
)

CLEAN_HOUR_MIN=12
CLEAN_HOUR_MAX=24

BASE_PATH="hdfs:///druid/segments"

$(date +"%Y%m%dT%H")

function is_exist_hdfs() {
  hadoop fs -test -e "$1"
  return $?
}

function clean_from_hdfs() {
  CMD=$(
    cat <<EOF
hadoop fs -rm -r ${1}
EOF
  )
  echo -e "${CMD}"
  ${CMD}
  return $?
}

##########################
## 清理
##########################

for ((i = ${CLEAN_HOUR_MIN}; i < ${CLEAN_HOUR_MAX}; i++)); do
  SUB_DIR=$(date +"%Y%m%dT%H" -d -${i}hour)
  NEED_DELETE_PATH="${BASE_PATH}/*/${SUB_DIR}*"
  IS_EXIST_HDFS=is_exist_hdfs "${NEED_DELETE_PATH}"

  if [[ "${IS_EXIST_HDFS}" == "0" ]]; then
    echo -e "存在: ${NEED_DELETE_PATH}"
    clean_from_hdfs "${NEED_DELETE_PATH}"
  else
    echo -e "不存在: ${NEED_DELETE_PATH}"
  fi
done
