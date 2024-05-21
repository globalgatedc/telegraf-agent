# telegraf-agent

## - Create Program Directories
``` Powershell
New-Item -ItemType Directory -Path "C:\Program Files\" -Name Telegraf; New-Item -ItemType Directory -Path "C:\Program Files\Telegraf" -Name conf;
```

## - Download .exe
```Powershell
cd C:/Program Files/Telegraf; wget https://dl.influxdata.com/telegraf/releases/telegraf-1.30.0_windows_amd64.zip -UseBasicParsing -OutFile telegraf-1.30.0_windows_amd64.zip; Expand-Archive .\telegraf-nightly_windows_amd64.zip -DestinationPath 'C:\Program Files\Telegraf'
```

## - Download .conf
wget 

## - Service Install 
```Powershell
.\telegraf.exe --service install --config 'C:\Program Files\Telegraf\conf\telegraf.conf'
```
