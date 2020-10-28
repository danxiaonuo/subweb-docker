##########################################
#            安装依赖包                   #
##########################################
# 指定构建的基础镜像
FROM node:lts-alpine AS dependencies

ARG BUILD_DEPS="\
      git"
ENV BUILD_DEPS=$BUILD_DEPS

# ***** 安装依赖 *****
RUN set -eux \
   # 安装依赖包
   && apk add -U --update $BUILD_DEPS

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
