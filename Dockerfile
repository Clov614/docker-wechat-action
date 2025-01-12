FROM golang:1.22 as builder

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

# 清理环境
RUN sudo rm -rf /tmp/.X0-lock

# install lsof
RUN sudo apt-get install -y lsof

# 根据传入参数安装微信和wxhelper.dll
ARG WECHAT_URL=https://github.com/lich0821/WeChatFerry/releases/download/v39.3.5/WeChatSetup-3.9.11.25.exe
ARG SDK_URL=https://github.com/lich0821/WeChatFerry/releases/download/v39.3.5/v39.3.5.zip

WORKDIR /home/app/.wine/drive_c

# 复制编译好的注入器
COPY --from=builder /app/res/injector.exe injector.exe

# 加载注入器
RUN sudo chown app:app injector.exe && sudo chmod a+x injector.exe

# 下载微信
ADD ${WECHAT_URL} WeChatSetup.exe
RUN sudo chown app:app WeChatSetup.exe  && sudo chmod a+x WeChatSetup.exe

# 下载 sdk.zip
ADD ${SDK_URL} sdk.zip

# 解压 sdk.zip 并设置号权限
RUN unzip /home/app/.wine/drive_c/sdk.zip -d /home/app/.wine/drive_c/ \
    && rm /home/app/.wine/drive_c/sdk.zip \
    && chown -R app:app /home/app/.wine/drive_c/sdk.dll \
    && chown -R app:app /home/app/.wine/drive_c/spy.dll \
    && chown -R app:app /home/app/.wine/drive_c/spy_debug.dll

RUN ls -lah

# 安装微信
COPY install-wechat.sh install-wechat.sh

RUN sudo chmod a+x install-wechat.sh && ./install-wechat.sh

RUN rm -rf WeChatSetup.exe && rm -rf install-wechat.sh

#COPY version.exe version.exe

# Port for WeChatFerry command
EXPOSE 8001
# Port for WeChatFerry message
EXPOSE 8002

EXPOSE 8080 5900

COPY cmd.sh /cmd.sh

RUN sudo chmod +x /cmd.sh

CMD ["/cmd.sh"]