@echo off
:: 获取Grafana和InfluxDB的完整路径
set serviceName1=Grafana
set serviceApp1="%cd%\grafana-8.3.3\bin\grafana-server.exe"
set serviceName2=InfluxDB
set serviceApp2="%cd%\influxdb-1.7.3_windows_amd64\influxdb-1.7.3-1\start.bat"
:: 获取jmeter和jdk的完整路径
set jmeterPath="%cd%\apache-jmeter-5.4"
set jdkPath="%cd%\jdk1.8.0_271"
set TelegrafConf="%cd%\telegraf_install_for_windows\telegraf.conf"
set telegrafPath="%cd%\telegraf_install_for_windows"

cls
title Grafana、InfluxDB自动安装
echo.
echo.
echo "    ______            _       __        "
echo "   / ____/___  ____  (_)___  / /_       "
echo "  / __/ / __ \/ __ \/ / __ \/ __/       "
echo " / /___/ /_/ / /_/ / / / / / /_         "
echo "/_____/ .___/\____/_/_/ /_/\__/         "
echo "    _/_/        __        ____          "
echo "   /   | __  __/ /_____  /  _/___  _____"
echo "  / /| |/ / / / __/ __ \ / // __ \/ ___/"
echo " / ___ / /_/ / /_/ /_/ // // / / (__  ) "
echo "/_/  |_\__,_/\__/\____/___/_/ /_/____/  "
echo.
echo 解压文件中...
unzip grafana-8.3.3.zip
unzip influxdb-1.7.3_windows_amd64.zip
unzip telegraf_install_for_windows.zip
echo 解压完成...
echo ***************开始创建压测监控服务*****************
echo Creating Grafana service...
.\nssm.exe install Grafana %serviceApp1%
echo Starting service...
.\nssm.exe start Grafana
sc query "Grafana" |findstr /i "RUNNING" >nul &&echo Success，Grafana is RUNNING！ ||echo Starting Failed (>_<)..
echo Creating InfluxDB service...
.\nssm.exe install InfluxDB %serviceApp2%
echo Starting service...
.\nssm.exe start InfluxDB
sc query "InfluxDB" |findstr /i "RUNNING" >nul &&echo Success，InfluxDB is RUNNING！ ||echo Starting Failed (>_<)..
echo ***************压测监控服务创建完毕*****************
echo.
echo.
echo *****************开始配置压测环境*******************
timeout /T 3
title Jmeter自动安装
if "%JAVA_HOME%"=="" (
if "%JMETER_HOME%"=="" (
goto installAll
) else (
goto installJdk
)
) else (
if "%JMETER_HOME%"=="" (
goto installJmeter
) else (
echo 检测到本机已安装JDK和JMETER！跳过步骤中...
goto end
)
)

:installAll
echo ************检测到本机未安装JDK和JMETER*************
echo.
echo 正在创建JAVA_HOME变量...
setx JAVA_HOME "%jdkPath%" /M
echo.
echo 正在创建JMETER_HOME变量...
setx JMETER_HOME "%jmeterPath%" /M
echo.
echo Path变量添加中...
setx Path "%Path%;%%JAVA_HOME%%\bin;%%JAVA_HOME%%\jre\bin;%%JMETER_HOME%%\bin" /M
echo.
echo CLASSPATH变量添加中...
setx CLASSPATH "%CLASSPATH%;%%JAVA_HOME%%\lib\dt.jar;%%JAVA_HOME%%\lib\tools.jar;%%JMETER_HOME%%\lib\ext\ApacheJMeter_core.jar;%%JMETER_HOME%%\lib\jorphan.jar" /M
echo.
echo **************JDK、JMETER安装配置完成***************
echo.
goto end

:installJmeter
echo ***************检测到本机未安装JMETER***************
echo.
echo 正在创建JMETER_HOME变量...
setx JMETER_HOME "%jmeterPath%" /M
echo.
echo Path变量添加中...
setx Path "%Path%;%%JMETER_HOME%%\bin" /M
echo.
echo CLASSPATH变量添加中...
setx CLASSPATH "%CLASSPATH%;%%JMETER_HOME%%\lib\ext\ApacheJMeter_core.jar;%%JMETER_HOME%%\lib\jorphan.jar" /M
echo.
echo *****************JMETER安装配置完成*****************

echo.
goto end

:installJdk
echo *****************检测到本机未安装JDK****************
echo 正在创建JAVA_HOME变量...
setx JAVA_HOME "%jdkPath%" /M
echo.
echo Path变量添加中...
setx Path "%Path%;%%JAVA_HOME%%\bin;%%JAVA_HOME%%\jre\bin" /M
echo.
echo CLASSPATH变量中...
setx CLASSPATH "%CLASSPATH%;%%JAVA_HOME%%\lib\dt.jar;%%JAVA_HOME%%\lib\tools.jar" /M
echo.
echo ******************JDK安装配置完成*******************
echo.
goto end

echo.

:end
echo.
echo **************修改注册表Tcpip端口参数***************
timeout /T 3
echo 重置MaxUserPort参数...
reg add "HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\Services\Tcpip\Parameters" /v "MaxUserPort" /t REG_DWORD /d 0x0000fffe /f
echo 重置TcpTimedWaitDelay参数...
reg add "HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\Services\Tcpip\Parameters" /v "TcpTimedWaitDelay" /t REG_DWORD /d 0x0000001e /f
echo **********************修改完成**********************
echo.
echo *************开始为本机安装telegraf监控*************
timeout /T 5
rem 自动获取ip
echo 正在获取本机ip...
for /f "tokens=16" %%i in ('ipconfig ^|find /i "ipv4"') do set ip=%%i
echo 获取成功，ip=%ip%
echo 正在重置配置文件...
echo [global_tags] >%TelegrafConf%
echo.>>%TelegrafConf%
echo [agent] >>%TelegrafConf%
echo  interval = "10s" >>%TelegrafConf%
echo  round_interval = true >>%TelegrafConf%
echo  metric_batch_size = 1000 >>%TelegrafConf%
echo  metric_buffer_limit = 10000 >>%TelegrafConf%
echo  collection_jitter = "0s" >>%TelegrafConf%
echo  flush_interval = "10s" >>%TelegrafConf%
echo  flush_jitter = "0s" >>%TelegrafConf%
echo  precision = "0s" >>%TelegrafConf%
echo  hostname = "%ip%" >>%TelegrafConf%
echo  omit_hostname = false >>%TelegrafConf%
echo.>>%TelegrafConf%
echo [[outputs.influxdb]] >>%TelegrafConf%
echo   urls = ["http://127.0.0.1:8086"] >>%TelegrafConf%
echo   database = "telegraf" >>%TelegrafConf%
echo   retention_policy = "" >>%TelegrafConf%
echo   username = "admin" >>%TelegrafConf%
echo   password = "11111" >>%TelegrafConf%
echo.>>%TelegrafConf%
echo [[inputs.cpu]] >>%TelegrafConf%
echo  percpu = true >>%TelegrafConf%
echo  totalcpu = true >>%TelegrafConf%
echo  collect_cpu_time = false >>%TelegrafConf%
echo  report_active = false >>%TelegrafConf%
echo  core_tags = false >>%TelegrafConf%
echo.>>%TelegrafConf%
echo [[inputs.disk]] >>%TelegrafConf%
echo  ignore_fs = ["tmpfs", "devtmpfs", "devfs", "iso9660", "overlay", "aufs", "squashfs"] >>%TelegrafConf%
echo.>>%TelegrafConf%
echo [[inputs.mem]] >>%TelegrafConf%
echo.>>%TelegrafConf%
echo [[inputs.system]] >>%TelegrafConf%
echo.>>%TelegrafConf%
echo    [[inputs.win_perf_counters.object]] >>%TelegrafConf%
echo      ObjectName = "LogicalDisk" >>%TelegrafConf%
echo      Instances = ["*"] >>%TelegrafConf%
echo      Counters = [ >>%TelegrafConf%
echo       "%% Idle Time", >>%TelegrafConf%
echo      ] >>%TelegrafConf%
echo      Measurement = "win_disk" >>%TelegrafConf%
echo.>>%TelegrafConf%
echo   [[inputs.win_perf_counters.object]] >>%TelegrafConf%
echo     ObjectName = "PhysicalDisk" >>%TelegrafConf%
echo     Instances = ["*"] >>%TelegrafConf%
echo     Counters = [ >>%TelegrafConf%
echo       "Disk Read Bytes/sec", >>%TelegrafConf%
echo       "Disk Write Bytes/sec", >>%TelegrafConf%
echo       "Disk Reads/sec", >>%TelegrafConf%
echo       "Disk Writes/sec", >>%TelegrafConf%
echo     ] >>%TelegrafConf%
echo     Measurement = "win_diskio" >>%TelegrafConf%
echo.>>%TelegrafConf%
echo  [[inputs.win_perf_counters.object]] >>%TelegrafConf%
echo     ObjectName = "Network Interface" >>%TelegrafConf%
echo     Instances = ["*"] >>%TelegrafConf%
echo    Counters = [ >>%TelegrafConf%
echo       "Bytes Received/sec", >>%TelegrafConf%
echo       "Bytes Sent/sec", >>%TelegrafConf%
echo     ] >>%TelegrafConf%
echo     Measurement = "win_net" >>%TelegrafConf%
echo.
echo 正在创建telegraf服务...
md "C:\Program Files\Telegraf"
copy %TelegrafConf% "C:\Program Files\Telegraf\"
%telegrafPath%\telegraf.exe --service install 
%telegrafPath%\telegraf.exe --service start
echo Telegraf监控服务启动成功!
echo **********************安装完成**********************
echo 正在清理压缩包...
del/f/s/q grafana-8.3.3.zip
del/f/s/q influxdb-1.7.3_windows_amd64.zip
del/f/s/q telegraf_install_for_windows.zip
echo.
echo.
echo 本地Grafana平台请访问：http://127.0.0.1:3000 登录账号：admin 初始密码：11111
echo 请通过命令行键入：jmeter 或从当前目录下jmeter的bin目录启动jmeter
echo ****************************************************
echo ******************压测环境配置完成******************
echo *请不要擅自移动此文件夹的位置哦！GOOD BYE!╰(*°▽°*)╯*
echo ****************************************************

pause
exit