@echo off
echo Stopping services...
.\nssm.exe stop Grafana
.\nssm.exe stop InfluxDB
.\nssm.exe stop telegraf
echo Removing Grafana and InfluxDB...
.\nssm.exe remove Grafana confirm
.\nssm.exe remove InfluxDB confirm
.\nssm.exe remove telegraf confirm
timeout /t 5
exit