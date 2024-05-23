#!/bin/bash

set -e

# Criar diretórios do programa
echo "Criando diretórios do programa..."
mkdir -p /usr/local/telegraf/conf
echo "Diretórios criados com sucesso."

# Baixar o executável do Telegraf
echo "Baixando o executável do Telegraf..."
cd /usr/local/telegraf
wget https://dl.influxdata.com/telegraf/releases/telegraf-1.30.0_linux_amd64.tar.gz
echo "Executável baixado com sucesso."

# Extrair o arquivo tar.gz
echo "Extraindo o arquivo tar.gz..."
tar -xzf telegraf-1.30.0_linux_amd64.tar.gz
echo "Arquivo tar.gz extraído com sucesso."

# Mover o executável do Telegraf
echo "Movendo o executável do Telegraf..."
mv telegraf-1.30.0/usr/bin/telegraf .
rm -rf telegraf-1.30.0
echo "Executável movido com sucesso."

# Escolher o arquivo de configuração
echo "Escolha qual arquivo de configuração deseja baixar:"
echo "1- Somente Agent"
echo "2- AD e DNS"
echo "3- RDP e RDS"
echo "4- IIS e .NET e ASP.NET"
read -p "Digite o número correspondente à opção desejada: " option

case $option in
    1)
        configURL="https://raw.githubusercontent.com/globalgatedc/telegraf-agent/main/telegraf_agent.conf"
        ;;
    2)
        configURL="https://raw.githubusercontent.com/globalgatedc/telegraf-agent/main/telegraf_ad_dns.conf"
        ;;
    3)
        configURL="https://raw.githubusercontent.com/globalgatedc/telegraf-agent/main/telegraf_rdp_rds.conf"
        ;;
    4)
        configURL="https://raw.githubusercontent.com/globalgatedc/telegraf-agent/main/telegraf_iis_dotnet_aspnet.conf"
        ;;
    *)
        echo "Opção inválida. Saindo..."
        exit 1
        ;;
esac

# Baixar o arquivo de configuração
echo "Baixando o arquivo de configuração..."
wget $configURL -O /usr/local/telegraf/conf/telegraf.conf
echo "Arquivo de configuração baixado com sucesso."

# Ler o arquivo de configuração
telegrafConfPath="/usr/local/telegraf/conf/telegraf.conf"
telegrafConf=$(cat $telegrafConfPath)

# Substituir os placeholders no arquivo de configuração
read -p "Digite o nome do bucket: " bucketName
read -p "Digite o token do bucket: " bucketToken

telegrafConf=${telegrafConf//BUCKET_NAME/$bucketName}
telegrafConf=${telegrafConf//BUCKET_TOKEN/$bucketToken}

# Escrever o arquivo de configuração atualizado
echo "$telegrafConf" > $telegrafConfPath
echo "Arquivo de configuração atualizado com sucesso."

# Instalar o serviço
echo "Instalando o serviço..."
./telegraf --service install --config $telegrafConfPath
echo "Serviço instalado com sucesso."

# Iniciar o serviço
echo "Iniciando o serviço..."
service telegraf start
echo "Serviço iniciado com sucesso."

echo "Script concluído com sucesso."
