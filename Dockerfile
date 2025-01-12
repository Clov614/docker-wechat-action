# FROM fedora:latest
FROM fedora:41
LABEL describe="Fedora for WeChat, base on LXDE, Wine, xRDP, WeChatFerry."

WORKDIR /root
# 安装基础运行环境和Go开发环境
RUN dnf groupinstall -y "LXDE" \
        && dnf install -y wine \
        && dnf install -y xrdp \
        && dnf clean all
# 复制本地资料文件
COPY ./res ./res
#COPY ./package/v*.zip ./res
COPY ./injector ./injector

## WECHAT_URL: 微信安装包下载地址
#ARG WECHAT_URL=https://github.com/lich0821/WeChatFerry/releases/download/v39.3.5/WeChatSetup-3.9.11.25.exe
## SDK_URL: WeChatFerry SDK 下载地址
#ARG SDK_URL=https://github.com/lich0821/WeChatFerry/releases/download/v39.3.5/v39.3.5.zip

## 下载 SDK 压缩包并解压
#RUN mkdir -p ./res \
#        && curl -o ./res/sdk.zip ${SDK_URL} \
#        && unzip -o ./res/sdk.zip -d ./res \
#        && rm ./res/sdk.zip
COPY ./sdk/* ./res/


RUN mkdir ./package
## 下载微信安装包
#RUN curl -o ./package/WeChatSetup.exe ${WECHAT_URL} || exit 1

# 安装编译器，编译注入器，完成后清理源码/临时文件/编译器
RUN dnf install -y go \
        && cd ./injector \
        && GOOS=windows go build \
        && cd .. \
        && mv ./injector/injector.exe ./res \
        && rm -rf ./injector \
        && rm -rf .cache/go-build \
        && dnf remove -y gcc \
        && dnf clean all
# 部署运行环境
RUN echo "root:123" | chpasswd \
        && mkdir ~/Desktop \
        && mv res/*.desktop ~/Desktop

# Port for xRDP
EXPOSE 3389
# Port for WeChatFerry command
EXPOSE 8001
# Port for WeChatFerry message
EXPOSE 8002

ENTRYPOINT ["./res/entrypoint.sh"]
CMD ["bash"]

