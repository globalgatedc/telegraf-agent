
Windows download
```
Invoke-WebRequest -Uri https://raw.githubusercontent.com/globalgatedc/telegraf-agent/refs/heads/main/telegraf.ps1 -OutFile telegraf.ps1
```

Linux download

WGET
```
wget https://raw.githubusercontent.com/globalgatedc/telegraf-agent/refs/heads/main/telegraf.sh && chmod +x telegraf.sh && sudo ./telegraf.sh && rm -rf ./telegraf.sh
```

CURL
```
curl  https://raw.githubusercontent.com/globalgatedc/telegraf-agent/refs/heads/main/telegraf.sh && chmod +x telegraf.sh && sudo ./telegraf.sh && rm -rf ./telegraf.sh
```
