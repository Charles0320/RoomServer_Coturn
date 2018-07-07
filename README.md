启动RoomServer_Coturn步骤：
1、./setup.sh 运行设置脚本
2、配置coturn启动参数，位置/etc/turnserver.conf
  (1)zookeeper-server zookeeper服务器地
  (2)listening-port coturn端口默认为3478
  (3)listening-ip 内网ip
  (4)external-ip 外网ip
3、启动coturn
  (1)手动启动
  systemctl start avchat-turnserver.service
 （2）当系统重启时候，服务自启动