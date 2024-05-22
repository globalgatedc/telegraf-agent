# telegraf-agent

## - Create Program Directories
``` Powershell
New-Item -ItemType Directory -Path 'C:\Program Files\' -Name Telegraf; New-Item -ItemType Directory -Path 'C:\Program Files\Telegraf' -Name conf;
```

## - Download .exe
```Powershell
cd 'C:\Program Files\Telegraf'; wget https://dl.influxdata.com/telegraf/releases/telegraf-1.30.0_windows_amd64.zip -UseBasicParsing -OutFile telegraf-1.30.0_windows_amd64.zip; Expand-Archive .\telegraf-1.30.0_windows_amd64.zip -DestinationPath 'C:\Program Files\Telegraf'; Remove-Item -Path 'C:\Program Files\Telegraf\telegraf-1.30.0_windows_amd64.zip';Move-Item -Path 'C:\Program Files\Telegraf\telegraf-1.30.0\telegraf.exe' -Destination 'C:\Program Files\Telegraf'; Remove-Item -Path 'C:\Program Files\Telegraf\telegraf-1.30.0' -Recurse
```
## - Set Enviroment Variables
```Powershell
$env:ORG_NAME = 'your organization name'; $env:INFLUX_URL = 'your influx url'; $env:BUCKET_NAME = 'your bucket name'; $env:BUCKET_TOKEN = 'your bucket token'
```

## - Download .conf
```Powershell
wget https://raw.githubusercontent.com/globalgatedc/telegraf-agent/main/telegraf.conf -UseBasicParsing -OutFile telegraf.conf -DestinationPath 'C:\Program Files\Telegraf\conf\'
```

## - Service Install 
```Powershell
.\telegraf.exe --service install --config 'C:\Program Files\Telegraf\conf\telegraf.conf'
```
