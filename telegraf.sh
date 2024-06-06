#!/bin/bash

set -e

if [ "$EUID" -ne 0 ]; then
	echo "This script must be run as root. Please use sudo or log in as root."
	exit 1
fi

OS=$(uname -s | tr A-Z a-z)

case $OS in
linux)
	source /etc/os-release
	case $ID in
	debian | ubuntu | mint)
		pkg_mng=apt
		;;

	fedora | rhel | centos)
		pkg_mng=yum
		;;

	arch | manjaro)
		pkg_mng=pacman
		;;

	*)
		echo -n "unsupported linux distro"
		;;
	esac
	;;

*)
	echo -n "unsupported OS"
	;;
esac

case $pkg_mng in
apt)
	DEBIAN_FRONTEND=noninteractive
	curl -s https://repos.influxdata.com/influxdata-archive_compat.key >influxdata-archive_compat.key
	echo '393e8779c89ac8d958f81f942f9ad7fb82a25e133faddaf92e15b16e6ac9ce4c influxdata-archive_compat.key' | sha256sum -c && cat influxdata-archive_compat.key | gpg --dearmor | tee /etc/apt/trusted.gpg.d/influxdata-archive_compat.gpg >/dev/null
	echo 'deb [signed-by=/etc/apt/trusted.gpg.d/influxdata-archive_compat.gpg] https://repos.influxdata.com/debian stable main' | tee /etc/apt/sources.list.d/influxdata.list
	apt-get update && apt-get install --no-install-recommends --no-upgrade -y telegraf
	;;
yum)
	cat <<EOF | tee /etc/yum.repos.d/influxdb.repo
[influxdb]
name = InfluxData Repository - Stable
baseurl = https://repos.influxdata.com/stable/\$basearch/main
enabled = 1
gpgcheck = 1
gpgkey = https://repos.influxdata.com/influxdata-archive_compat.key
EOF
	yum install telegraf
	;;
pacman)
	pacman -S telegraf
	;;
esac

# # Escolher o arquivo de configuração
echo "Escolha qual arquivo de configuração deseja baixar:"
echo "1- Somente Agent"
read -p "Digite o número correspondente à opção desejada: " option

case $option in
1)
	configURL="https://raw.githubusercontent.com/globalgatedc/telegraf-agent/main/telegraf.conf"
	;;
*)
	echo "Opção inválida. Saindo..."
	exit 1
	;;
esac

# Baixar o arquivo de configuração
echo "Baixando o arquivo de configuração..."
wget $configURL -O /etc/telegraf/telegraf.conf
echo "Arquivo de configuração baixado com sucesso."

# Ler o arquivo de configuração
telegrafConf="/etc/telegraf/telegraf.conf"

# Substituir os placeholders no arquivo de configuração
read -p "Digite o nome do bucket: " bucketName
read -p "Digite o token do bucket: " bucketToken

sed -i "s/BUCKET_NAME/$bucketName/g" $telegrafConf
sed -i "s/BUCKET_TOKEN/$bucketToken/g" $telegrafConf

# echo "Script concluído com sucesso."
