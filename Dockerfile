##########################################
#            安装依赖包                   #
##########################################
# 指定构建的基础镜像
FROM node:lts-alpine AS dependencies

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

# ***** 安装依赖 *****
RUN set -eux \
<<<<<<< HEAD
   # 安装依赖包
   && apk add -U --update $BUILD_DEPS
=======
   # 更新源地址
   && apk update \
   # 更新系统并更新系统软件
   && apk upgrade && apk upgrade \
   && apk add -U --update $BUILD_DEPS \
   # 更新时区
   && ln -sf /usr/share/zoneinfo/${TZ} /etc/localtime \
   # 更新时间
   && echo ${TZ} > /etc/timezone

>>>>>>> parent of d245a26... Update Dockerfile

# 克隆源码运行安装
RUN set -eux \
    && git clone --progress https://github.com/CareyWang/sub-web.git /sub-web

# 工作目录
WORKDIR /app

RUN set -eux \
    && cp /sub-web/package.json /app \
    && yarn install

# ##############################################################################
    
##########################################
#            构建运行环境                 #
##########################################
FROM dependencies AS build
WORKDIR /app
RUN set -eux \
    && cp -rf /sub-web/* . /app \
    && yarn build

# ##############################################################################


##########################################
#         构建基础镜像                    #
##########################################
# 
# 指定创建的基础镜像
FROM alpine:latest

COPY --from=build /app/dist /www
