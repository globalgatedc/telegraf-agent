# Iniciar no diretorio C:\Program Files
Set-Location -Path "C:\Program Files"

# Criar diretorios do programa com verificacoes
Write-Host "Verificando e criando diretorios do programa"

# Diretorio principal
$mainDir = "C:\Program Files\Telegraf"
$confDir = "C:\Program Files\Telegraf\conf"

# Verifica e cria o diretorio principal, se necessario
if (-not (Test-Path -Path $mainDir)) {
    New-Item -ItemType Directory -Path $mainDir -ErrorAction Stop
    Write-Host "Diretorio $mainDir criado com sucesso"
} else {
    Write-Host "Diretorio $mainDir ja existe. Pulando a criacao"
}

# Verifica e cria o diretorio de configuracao, se necessario
if (-not (Test-Path -Path $confDir)) {
    New-Item -ItemType Directory -Path $confDir -ErrorAction Stop
    Write-Host "Diretorio $confDir criado com sucesso"
} else {
    Write-Host "Diretorio $confDir ja existe. Pulando a criacao"
}

Write-Host "Verificacao e criacao de diretorios concluida"

#Change Directory
try {
    Set-Location -Path "C:\Program Files\Telegraf" -ErrorAction Stop
} catch {
    Write-Host "Erro: nao foi possivel acessar o diretorio C:\Program Files\Telegraf. Verifique se o diretorio existe e se voce tem permissao para acessa-lo" -ForegroundColor Red
    exit 1
}

# Baixar o executavel do Telegraf
Write-Host "Baixando o executavel do Telegraf"

try {
    # Baixar o arquivo para o diretorio especificado
    Invoke-WebRequest -Uri "https://dl.influxdata.com/telegraf/releases/telegraf-1.30.0_windows_amd64.zip" `
                      -UseBasicParsing `
                      -OutFile "telegraf.zip" `
                      -ErrorAction Stop
    Write-Host "Executavel baixado com sucesso"
    

} catch {
    Write-Host "Erro ao baixar o executavel do Telegraf: $_" -ForegroundColor Red
    exit 1
}

# Extrair o arquivo zip
Write-Host "Extraindo o arquivo zip..."
try {
    Expand-Archive .\telegraf.zip -Force -ErrorAction Stop
    Write-Host "Arquivo zip extraido com sucesso."
} catch {
    Write-Host "Erro ao extrair o arquivo zip: $_" -ForegroundColor Red
    exit 1
}

# Remover o arquivo zip
Write-Host "Removendo o arquivo zip..."
try {
    Remove-Item .\telegraf.zip -ErrorAction Stop
    Write-Host "Arquivo zip removido com sucesso."
} catch {
    Write-Host "Erro ao remover o arquivo zip: $_" -ForegroundColor Red
    exit 1
}

# Mover o executavel do Telegraf
Write-Host "Procurando e movendo o executavel do Telegraf..."

try {
    # Procurar o arquivo telegraf.exe em qualquer subdiretorio de $mainDir
    $telegrafExePath = Get-ChildItem -Path $mainDir -Recurse -Filter "telegraf.exe" | Select-Object -First 1 -ExpandProperty FullName

    if ($telegrafExePath) {
        # Mover o arquivo telegraf.exe para o diretorio principal
        Move-Item -Path $telegrafExePath -Destination $mainDir -Force -ErrorAction Stop
        Write-Host "Executavel movido com sucesso para $mainDir"
    } else {
        Write-Host "Erro: arquivo telegraf.exe nao encontrado nos subdiretorios de $mainDir" -ForegroundColor Red
        exit 1
    }
} catch {
    Write-Host "Erro ao mover o executavel do Telegraf: $_" -ForegroundColor Red
    exit 1
}

# Remover diretorio de extracao
Write-Host "Procurando e removendo o diretorio de extracao..."

try {
    # Procurar o diretorio telegraf-{versao} dentro de $mainDir
    $extractDir = Get-ChildItem -Path $mainDir -Directory -Filter "telegraf*" | Select-Object -First 1 -ExpandProperty FullName

    if ($extractDir) {
        # Remover o diretorio de extracao encontrado
        Remove-Item -Path $extractDir -Recurse -ErrorAction Stop
        Write-Host "Diretorio de extracao $extractDir removido com sucesso."
    } else {
        Write-Host "Erro: diretorio de extracao nao encontrado em $mainDir" -ForegroundColor Red
        exit 1
    }
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
    iwr $configURL -UseBasicParsing -OutFile 'C:\Program Files\Telegraf\conf\telegraf.conf' -ErrorAction Stop
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

#Change Directory
try {
    Set-Location -Path "C:\Program Files\Telegraf\" -ErrorAction Stop
} catch {
    Write-Host "Erro: nao foi possivel acessar o diretorio C:\Program Files\Telegraf\ Verifique se o diretorio existe e se voce tem permissao para acessa-lo" -ForegroundColor Red
    exit 1
}

# Instalar o servico
Write-Host "Instalando o servico..."
try {
    .\telegraf.exe service install --config 'C:\Program Files\Telegraf\conf\telegraf.conf'
    Write-Host "Servico instalado com sucesso."
} catch {
    Write-Host "Erro ao instalar o servico: $_" -ForegroundColor Red
    exit 1
}

# Iniciar o servico
Write-Host "Iniciando o servico..."
try {
    .\telegraf.exe service start
    Write-Host "Servico iniciado com sucesso."
} catch {
    Write-Host "Erro ao iniciar o servico: $_" -ForegroundColor Red
    exit 1
}

Write-Host "Script concluido com sucesso."
