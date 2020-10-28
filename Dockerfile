##########################################
#            构建运行环境                 #
##########################################
# 指定构建的基础镜像
FROM node:lts-alpine AS builder

# 作者描述信息
MAINTAINER danxiaonuo
# 时区设置
ARG TZ=Asia/Shanghai
ENV TZ=$TZ

ARG BUILD_DEPS="\
      tzdata \
      curl \
      git \
      wget \
      bash"
ENV BUILD_DEPS=$BUILD_DEPS

# 修改源地址
RUN sed -i 's/dl-cdn.alpinelinux.org/mirrors.aliyun.com/g' /etc/apk/repositories
# ***** 安装依赖 *****
RUN set -eux \
   # 更新源地址
   && apk update \
   # 更新系统并更新系统软件
   && apk upgrade && apk upgrade \
   && apk add -U --update $BUILD_DEPS \
   # 更新时区
   && ln -sf /usr/share/zoneinfo/${TZ} /etc/localtime \
   # 更新时间
   && echo ${TZ} > /etc/timezone


# 克隆源码运行安装
RUN set -eux \
    && git clone --progress https://github.com/CareyWang/sub-web.git

# 工作目录
WORKDIR /app

RUN set -eux \
    && cp /root/sub-web/package.json /app \
    && yarn install \
    && cp /root/sub-web/* /app \
    && yarn build

# ##############################################################################


##########################################
#         构建基础镜像                    #
##########################################
# 
# 指定创建的基础镜像
FROM alpine:latest

COPY --from=build /app/dist /www
