# Windows一键安装压测环境
## 一键安装包含如下内容
- Jdk-1.8
- JMeter-5.4
- Grafana-8.3.3
- InfluxDB-1.7.3
- Telegraf

## 使用方法
### **安装**
1. 运行install.bat脚本</br>
![01](https://github.com/Winston1997/Perf_Test_Enviroment_WinSetup/blob/master/IMG/01.png)</br>
2. 确认安装完成</br>
![02](https://github.com/Winston1997/Perf_Test_Enviroment_WinSetup/blob/master/IMG/02.png)</br>
3. 验证JMeter安装</br>
![03](https://github.com/Winston1997/Perf_Test_Enviroment_WinSetup/blob/master/IMG/03.png)</br>
4. 验证Grafana安装:访问http://127.0.0.1:3000 默认登录账号和密码：admin/11111</br>
![04](https://github.com/Winston1997/Perf_Test_Enviroment_WinSetup/blob/master/IMG/04.png)</br>
5. 验证Telegraf安装（这个是用来监控压测性能的）</br>
![06](https://github.com/Winston1997/Perf_Test_Enviroment_WinSetup/blob/master/IMG/06.png)</br>
![07](https://github.com/Winston1997/Perf_Test_Enviroment_WinSetup/blob/master/IMG/07.png)</br>
能监控到本机数据则表明压测环境安装配置没有问题。
>注意：安装脚本执行完成后，请不要移动此文件夹的位置，否则通过环境变量创建的jmeter和java将会获取不到导致无法启动压测工具。

### **卸载**
1. 运行uninstall.bat脚本</br>
![08](https://github.com/Winston1997/Perf_Test_Enviroment_WinSetup/blob/master/IMG/08.png)</br>