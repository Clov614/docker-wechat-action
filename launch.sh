#!/bin/bash
# WeChatFerry微信启动器，注入dll并启动微信
# XXX: 容器删除并重启后，保存在宿主机的程序和用户数据可以被复用。
# XXX: 但注册表被重置，导致sdk找不到微信程序。所以需要重新导入注册表。
# XXX: 也可以通过重新安装程序解决此问题。
PWD=$(cd `dirname $0`; pwd)
cd $PWD

echo "USER=$USER"

## 注册表备份文件
#reg_file="$WINEPREFIX/drive_c/users/app/AppData/Roaming/Tencent/WeChat/wechat.reg"
#
## 检查注册表，判断微信相关键是否存在
#chk_reg="wine reg query \"HKEY_CURRENT_USER\\Software\\Tencent\\WeChat\""
#echo "Check regedit..."
#eval $chk_reg
#if [ $? -ne 0 ]; then
#  if [ ! -f "$reg_file" ]; then
#    echo "请先安装微信!"
#    notify-send "WeChatFerry" "未找到程序，请先运行WeChatSetup安装微信"
#    exit 1
#  fi
#  echo "Init regedit"
#  notify-send "WeChatFerry" "发现注册表备份文件，还原注册表"
#  import_reg="wine regedit /s $reg_file"
#  eval $import_reg
#elif [ ! -f "$reg_file" ]; then
#  echo "备份注册表"
#  notify-send "WeChatFerry" "备份注册表"
#  paths=( \
#    "HKEY_LOCAL_MACHINE\\SOFTWARE\\Microsoft\\Windows\\CurrentVersion\\Uninstall\\WeChat" \
#    "HKEY_CURRENT_USER\\Software\\Tencent" \
#    "HKEY_USERS\\S-1-5-21-0-0-0-1000\\Software\\Classes\\weixin" \
#    "HKEY_USERS\\S-1-5-21-0-0-0-1000\\Software\\Tencent" \
#    "HKEY_USERS\\S-1-5-21-0-0-0-1000\\Software\\WeChatAppEx" \
#  )
#  for p in ${paths[*]}; do
#    bac_reg="wine reg export \"$p\" \"$PWD/reg.tmp\""
#    eval $bac_reg
#    cat "$PWD/reg.tmp" >> "$reg_file"
#    rm "$PWD/reg.tmp"
#  done
#fi

# 启动注入器，并传递参数 8001 和 true
echo "Run injector"
echo "WeChatFerry" "正在启动注入器"
run="wine 'C:\\injector.exe' 8001 true"
eval $run
echo "Injector exit!"

