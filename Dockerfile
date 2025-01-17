FROM golang:1.22 AS builder

WORKDIR /app

COPY . .

ENV GOPROXY=https://goproxy.cn,direct

# 编译注入器
RUN cd ./injector \
        && GOOS=windows GOARCH=amd64 go build -ldflags="-s -w" -o injector.exe . \
        && cd .. \
        && mv ./injector/injector.exe ./res \
        && rm -rf ./injector

FROM furacas/wine-vnc-box:latest

# 安装必要工具，包括 winbind（提供 ntlm_auth）
RUN sudo apt-get update && sudo apt-get install -y winbind lsof

# 验证 ntlm_auth
RUN ntlm_auth --version

## 安装 notify-send
#RUN sudo apt-get install -y libnotify-bin

# install lsof
RUN sudo apt-get install -y lsof

# 清理环境
RUN sudo rm -rf /tmp/.X*-lock

# 根据传入参数安装微信和wxhelper.dll
ARG WECHAT_URL=https://github.com/lich0821/WeChatFerry/releases/download/v39.3.5/WeChatSetup-3.9.11.25.exe
ARG SDK_URL=https://github.com/lich0821/WeChatFerry/releases/download/v39.3.5/v39.3.5.zip

WORKDIR /home/app

# 复制编译好的注入器
COPY --from=builder /app/res/injector.exe .wine/drive_c/

# 加载注入器
RUN sudo chown app:app .wine/drive_c/injector.exe && sudo chmod a+x .wine/drive_c/injector.exe

# 下载微信
ADD ${WECHAT_URL} .wine/drive_c/WeChatSetup.exe
RUN sudo chown app:app .wine/drive_c/WeChatSetup.exe  && sudo chmod a+x .wine/drive_c/WeChatSetup.exe

# 复制 sdk 目录中的 .dll 文件到工作目录
COPY ./sdk .wine/drive_c/

RUN ls -lah .wine/drive_c/

# 安装微信
COPY install-wechat.sh .
RUN sudo chmod a+x install-wechat.sh && WINEPREFIX=/home/app/.wine ./install-wechat.sh

RUN rm -rf .wine/drive_c/WeChatSetup.exe && rm -rf install-wechat.sh

#COPY version.exe version.exe

# Port for WeChatFerry command
EXPOSE 8001
# Port for WeChatFerry message
EXPOSE 8002

EXPOSE 8080 5900

COPY launch.sh /
RUN sudo chmod +x /launch.sh
ENV WINEPREFIX=/home/app/.wine
CMD ["/launch.sh"]