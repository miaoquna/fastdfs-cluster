#!/bin/sh
#set -e

# 监控程序
if [ "$1" = "monitor" ] ; then
  # 当环境变量中设置了服务器地址时，修改客户端配置文件中的服务器地址
  if [ -n "$TRACKER_SERVER" ] ; then  
    sed -i "s|tracker_server=.*$|tracker_server=${TRACKER_SERVER}|g" /etc/fdfs/client.conf
  fi
  fdfs_monitor /etc/fdfs/client.conf
  exit 0
# storage 服务
elif [ "$1" = "storage" ] ; then
  FASTDFS_MODE="storage"
# tracker 服务
else 
  FASTDFS_MODE="tracker"
fi

# 修改端口
if [ -n "$PORT" ] ; then  
    sed -i "s|^port=.*$|port=${PORT}|g" /etc/fdfs/"$FASTDFS_MODE".conf
fi

if [ -n "$TRACKER_SERVER" ] ; then  

sed -i "s|tracker_server=.*$|tracker_server=${TRACKER_SERVER}|g" /etc/fdfs/storage.conf
sed -i "s|tracker_server=.*$|tracker_server=${TRACKER_SERVER}|g" /etc/fdfs/client.conf

fi

if [ -n "$GROUP_NAME" ] ; then  

sed -i "s|group_name=.*$|group_name=${GROUP_NAME}|g" /etc/fdfs/storage.conf

fi 

# 初始化进程日志文件地址
FASTDFS_LOG_FILE="${FASTDFS_BASE_PATH}/logs/${FASTDFS_MODE}d.log"
# 初始化进程 PID 文件地址
PID_NUMBER="${FASTDFS_BASE_PATH}/data/fdfs_${FASTDFS_MODE}d.pid"

echo "try to start the $FASTDFS_MODE node..."

# 删除已有的日志文件
if [ -f "$FASTDFS_LOG_FILE" ]; then 
	rm "$FASTDFS_LOG_FILE"
fi

# 启动 fastdfs
fdfs_${FASTDFS_MODE}d /etc/fdfs/${FASTDFS_MODE}.conf start

# 设置循环等待，如果没有查找到 pid 文件创建成功继续等待，最大循环次数5次
TIMES=5
while [ ! -f "$PID_NUMBER" -a $TIMES -gt 0 ]
do
    sleep 1s
	TIMES=`expr $TIMES - 1`
done


# 如果 fastdfs 启动成功打印启动时间
if [ $TIMES -gt 0 ]; then
     echo "the ${FASTDFS_MODE} node started successfully at $(date +%Y-%m-%d_%H:%M)"
	
    # 打印日志文件详细地址方便查询
     echo "please have a look at the log detail at $FASTDFS_LOG_FILE"
	
 	 # 保证容器后台运行
     tail -F --pid=`cat $PID_NUMBER` /dev/null
     #
     #tail -f "$FASTDFS_LOG_FILE"
# 启动失败
else
    echo "the ${FASTDFS_MODE} node started failed at $(date +%Y-%m-%d_%H:%M)"
    echo "please check the error message in the log file $FASTDFS_LOG_FILE"
fi
