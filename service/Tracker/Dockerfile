# 使用最新版 centos
FROM alpine:latest

LABEL version="v5.11"

# 定义作者
MAINTAINER "2418952171@qq.com"

# 初始化环境变量
ENV FASTDFS_PATH=/opt/fdfs \
    FASTDFS_BASE_PATH=/var/fdfs \
    PORT= \
    GROUP_NAME= \
    TRACKER_SERVER=

RUN sed -i 's/dl-cdn.alpinelinux.org/mirrors.ustc.edu.cn/g' /etc/apk/repositories

RUN apk update

# 安装需要的依赖
RUN apk add --no-cache git gcc make perl libc-dev coreutils

#create the dirs to store the files downloaded from internet
# 初始化所需要的文件夹
RUN mkdir -p ${FASTDFS_PATH}/libfastcommon \
 && mkdir -p ${FASTDFS_PATH}/fastdfs \
 && mkdir ${FASTDFS_BASE_PATH}



################################# libfastcommon ######################################
# 安装 libfastcommon
# 这个是基础环境必须安装
# libfastcommon是从 FastDFS 和 FastDHT 中提取出来的公共 C 函数库，基础环境，安装即可
# 指定工作目录开始安装
WORKDIR ${FASTDFS_PATH}/libfastcommon

RUN git clone --branch V1.0.38 --depth 1 https://github.com/happyfish100/libfastcommon.git ${FASTDFS_PATH}/libfastcommon \
 && ./make.sh \
 && ./make.sh install \
 && rm -rf ${FASTDFS_PATH}/libfastcommon

# libfastcommon.so 默认安装到了/usr/lib64/libfastcommon.so,但是FastDFS主程序设置的lib目录是/usr/local/lib,所以此处需要重新设置软链接(类似于Windows的快捷方式):
#RUN ln -s /usr/lib64/libfastcommon.so /usr/local/lib/libfastcommon.so \
#    && ln -s /usr/lib64/libfastcommon.so /usr/lib/libfastcommon.so \
#    && ln -s /usr/lib64/libfdfsclient.so /usr/local/lib/libfdfsclient.so \
#    && ln -s /usr/lib64/libfdfsclient.so /usr/lib/libfdfsclient.so

################################# libfastcommon 安装完毕 ######################################


################################# FastDFS ######################################
# 切换工作目录
WORKDIR ${FASTDFS_PATH}/fastdfs

# 克隆最新版的 fastdfs
RUN git clone --branch V5.11 --depth 1 https://github.com/happyfish100/fastdfs.git ${FASTDFS_PATH}/fastdfs \
 && ./make.sh \
 && ./make.sh install \
 && rm -rf ${FASTDFS_PATH}/fastdfs

RUN ln -s /usr/bin/fdfs_trackerd /usr/local/bin  \
 && ln -s /usr/bin/stop.sh /usr/local/bin \
 && ln -s /usr/bin/restart.sh /usr/local/bin

# 卸载不需要的软件减小镜像大小
RUN apk del git

# 写入配置文件到容器
COPY ./conf/tracker.conf /etc/fdfs/
COPY ./conf/http.conf /etc/fdfs/

# 写入启动脚本到容器
COPY ./service/start.sh /usr/bin/

#设置启动脚本可执行权限
RUN chmod 777 /usr/bin/start.sh

ENTRYPOINT ["/usr/bin/start.sh"]

# 启动服务
CMD ["tracker"]