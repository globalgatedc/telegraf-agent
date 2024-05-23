# Criar diretorios do programa
Write-Host "Criando diretorios do programa..."
New-Item -ItemType Directory -Path 'C:\Program Files\' -Name Telegraf -ErrorAction Stop
New-Item -ItemType Directory -Path 'C:\Program Files\Telegraf' -Name conf -ErrorAction Stop
Write-Host "Diretorios criados com sucesso."

# Baixar o executavel do Telegraf
Write-Host "Baixando o executavel do Telegraf..."
cd 'C:\Program Files\Telegraf'
try {
    wget https://dl.influxdata.com/telegraf/releases/telegraf-1.30.0_windows_amd64.zip -UseBasicParsing -OutFile telegraf-1.30.0_windows_amd64.zip -ErrorAction Stop
    Write-Host "Executavel baixado com sucesso."
} catch {
    Write-Host "Erro ao baixar o executavel do Telegraf: $_" -ForegroundColor Red
    exit 1
}

# Extrair o arquivo zip
Write-Host "Extraindo o arquivo zip..."
try {
    Expand-Archive .\telegraf-1.30.0_windows_amd64.zip -DestinationPath 'C:\Program Files\Telegraf' -Force -ErrorAction Stop
    Write-Host "Arquivo zip extraido com sucesso."
} catch {
    Write-Host "Erro ao extrair o arquivo zip: $_" -ForegroundColor Red
    exit 1
}

# Remover o arquivo zip
Write-Host "Removendo o arquivo zip..."
try {
    Remove-Item -Path 'C:\Program Files\Telegraf\telegraf-1.30.0_windows_amd64.zip' -ErrorAction Stop
    Write-Host "Arquivo zip removido com sucesso."
} catch {
    Write-Host "Erro ao remover o arquivo zip: $_" -ForegroundColor Red
    exit 1
}

# Mover o executavel do Telegraf
Write-Host "Movendo o executavel do Telegraf..."
try {
    Move-Item -Path 'C:\Program Files\Telegraf\telegraf-1.30.0\telegraf.exe' -Destination 'C:\Program Files\Telegraf' -Force -ErrorAction Stop
    Write-Host "Executavel movido com sucesso."
} catch {
    Write-Host "Erro ao mover o executavel do Telegraf: $_" -ForegroundColor Red
    exit 1
}

# Remover diretorio de extracao
Write-Host "Removendo diretorio de extracao..."
try {
    Remove-Item -Path 'C:\Program Files\Telegraf\telegraf-1.30.0' -Recurse -ErrorAction Stop
    Write-Host "Diretorio de extracao removido com sucesso."
} catch {
    Write-Host "Erro ao remover o diretorio de extracao: $_" -ForegroundColor Red
    exit 1
}

# Escolher o arquivo de configuracao
Write-Host "Escolha qual arquivo de configuracao deseja baixar:"
Write-Host "1- Somente Agent"
Write-Host "2- AD e DNS"
Write-Host "3- RDP e RDS"
Write-Host "4- IIS e .NET e ASP.NET"
$option = Read-Host "Digite o numero correspondente a opcao desejada"

switch ($option) {
    '1' {
        $configURL = 'https://raw.githubusercontent.com/globalgatedc/telegraf-agent/main/telegraf.conf'
    }
    '2' {
        $configURL = 'https://raw.githubusercontent.com/globalgatedc/telegraf-agent/main/telegraf-ad-dns.conf'
    }
    '3' {
        $configURL = 'https://raw.githubusercontent.com/globalgatedc/telegraf-agent/main/telegraf-rdp-rds.conf'
    }
    '4' {
        $configURL = 'https://raw.githubusercontent.com/globalgatedc/telegraf-agent/main/telegraf-iis-dotnet.conf'
    }
    default {
        Write-Host "Opcao invalida. Saindo..." -ForegroundColor Red
        exit 1
    }
}

# Baixar o arquivo de configuracao
Write-Host "Baixando o arquivo de configuracao..."
try {
    wget $configURL -UseBasicParsing -OutFile 'C:\Program Files\Telegraf\conf\telegraf.conf' -ErrorAction Stop
    Write-Host "Arquivo de configuracao baixado com sucesso."
} catch {
    Write-Host "Erro ao baixar o arquivo de configuracao: $_" -ForegroundColor Red
    exit 1
}

# Ler o arquivo de configuracao
$telegrafConfPath = 'C:\Program Files\Telegraf\conf\telegraf.conf'
try {
    $telegrafConf = Get-Content $telegrafConfPath -ErrorAction Stop
} catch {
    Write-Host "Erro ao ler o arquivo de configuracao: $_" -ForegroundColor Red
    exit 1
}

# Substituir os placeholders no arquivo de configuracao
$bucketName = Read-Host "Digite o nome do bucket"
$bucketToken = Read-Host "Digite o token do bucket"

$telegrafConf = $telegrafConf -replace 'BUCKET_NAME', $bucketName
$telegrafConf = $telegrafConf -replace 'BUCKET_TOKEN', $bucketToken

# Escrever o arquivo de configuracao atualizado
try {
    $telegrafConf | Set-Content $telegrafConfPath -ErrorAction Stop
    Write-Host "Arquivo de configuracao atualizado com sucesso."
} catch {
    Write-Host "Erro ao escrever o arquivo de configuracao: $_" -ForegroundColor Red
    exit 1
}

# Instalar o servico
Write-Host "Instalando o servico..."
try {
    .\telegraf.exe --service install --config 'C:\Program Files\Telegraf\conf\telegraf.conf'
    Write-Host "Servico instalado com sucesso."
} catch {
    Write-Host "Erro ao instalar o servico: $_" -ForegroundColor Red
    exit 1
}

Write-Host "Script concluido com sucesso."
