$Host.UI.RawUI.WindowTitle = "Network Diagnostic Tool - OSI Model"

function Show-Header {
    Clear-Host
    Write-Host "==========================================" -ForegroundColor Cyan
    Write-Host "   DIAGNOSTICO DE RED AUTOMATIZADO" -ForegroundColor White
    Write-Host "==========================================" -ForegroundColor Cyan
}

function Write-Log {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory=$true)]
        [string]$Message,

        [string]$Color = "Gray",

        [ValidateSet("OK", "FAIL", "INFO")]
        [string]$Status = "INFO"
    )

    $timestamp = Get-Date -Format "HH:mm:ss"
    
    Write-Host "[$timestamp] $Message" -NoNewline -ForegroundColor $Color

    switch ($Status) {
        "OK"   { Write-Host " [OK]" -ForegroundColor Green }
        "FAIL" { Write-Host " [FALLO]" -ForegroundColor Red }
        Default { Write-Host "" }
    }
}

function Get-Target {
    param ([string]$PresetTarget = $null)
    
    if (-not [string]::IsNullOrWhiteSpace($PresetTarget)) { 
        return $PresetTarget 
    }
    return Read-Host "Ingrese Dominio o IP (ej. google.com)"
}

function Start-Diagnostic {
    param (
        [Parameter(Mandatory=$true)]
        [string]$Target,

        [int]$Count = 1
    )

    $headerMsg = "`n--- INICIANDO PRUEBA ({0} iteraciones) para: {1} ---" -f $Count, $Target
    Write-Host $headerMsg -ForegroundColor Yellow

    1..$Count | ForEach-Object {
        $i = $_
        Write-Host "`n[Iteracion $i de $Count]" -ForegroundColor Magenta
        
        # --- CAPA 1 y 2: ENLACE DE DATOS Y FISICA ---
        $gatewayRoute = Get-NetRoute | Where-Object { $_.DestinationPrefix -eq "0.0.0.0/0" }
        $gateway = $gatewayRoute | Select-Object -ExpandProperty NextHop -ErrorAction SilentlyContinue
        
        if ($gateway) {
            $testGateway = Test-Connection -ComputerName $gateway -Count 1 -Quiet
            if ($testGateway) {
                Write-Log -Message "Capa 1/2: Conexion al Gateway ($gateway)" -Status "OK"
            } else {
                Write-Log -Message "Capa 1/2: Conexion al Gateway ($gateway)" -Status "FAIL"
                Write-Host ">> CAUSA: Fallo fisico o de enlace local. Revise cableado/WiFi." -ForegroundColor Red
                return
            }
        } else {
            Write-Log -Message "Capa 3: Configuracion IP Local" -Status "FAIL"
            Write-Host ">> CAUSA: No hay Gateway asignado (DHCP fallido o IP estatica mal configurada)." -ForegroundColor Red
            return
        }

        # --- CAPA 7: APLICACION (DNS) ---
        $isIP = $Target -match "\b\d{1,3}\.\d{1,3}\.\d{1,3}\.\d{1,3}\b"
        
        if (-not $isIP) {
            try {
                $dnsTest = Resolve-DnsName -Name $Target -ErrorAction Stop
                $resolvedIP = $dnsTest.IPAddress[0]
                Write-Log -Message "Capa 7: Resolucion DNS ($Target -> $resolvedIP)" -Status "OK"
            } catch {
                Write-Log -Message "Capa 7: Resolucion DNS ($Target)" -Status "FAIL"
                Write-Host ">> CAUSA: Fallo en servidor DNS. No se puede traducir el nombre." -ForegroundColor Red
                return
            }
        }

        # --- CAPA 3: RED (ICMP) ---
        $pingTest = Test-Connection -ComputerName $Target -Count 1 -Quiet
        if ($pingTest) {
            Write-Log -Message "Capa 3: Ping a $Target" -Status "OK"
        } else {
            Write-Log -Message "Capa 3: Ping a $Target" -Status "FAIL"
            Write-Host ">> CAUSA: Paquetes perdidos. Posible bloqueo de Firewall o ruta caida." -ForegroundColor Red
            
            Write-Host "   Ejecutando TraceRoute (Saltos max: 10)..." -ForegroundColor DarkGray
            tracert -d -h 10 $Target
            return
        }

        # --- CAPA 4: TRANSPORTE (TCP Handshake) ---
        $portTest = Test-NetConnection -ComputerName $Target -Port 443 -InformationLevel Quiet
        if ($portTest) {
            Write-Log -Message "Capa 4: Conexion TCP Puerto 443 (HTTPS)" -Status "OK"
        } else {
            Write-Log -Message "Capa 4: Conexion TCP Puerto 443 (HTTPS)" -Status "FAIL"
            Write-Host ">> NOTA: Ping responde pero puerto web cerrado/filtrado." -ForegroundColor Yellow
        }
        
        Start-Sleep -Milliseconds 500 
    }
}

do {
    Show-Header
    Write-Host "1. Test Personalizado (Ingresar IP/Dominio)"
    Write-Host "2. Test Rapido a Google (8.8.8.8 - Capa 3)"
    Write-Host "3. Test Rapido a Google (google.com - Full Stack)"
    Write-Host "Q. Salir"
    
    $selection = Read-Host "`nSeleccione una opcion"

    switch ($selection) {
        "1" { 
            $t = Get-Target
            $inputCount = Read-Host "Cantidad de iteraciones (Default: 1)"
            if ([string]::IsNullOrWhiteSpace($inputCount)) { $c = 1 } else { $c = [int]$inputCount }
            
            Start-Diagnostic -Target $t -Count $c
        }
        "2" { 
            Start-Diagnostic -Target "8.8.8.8" -Count 1 
        }
        "3" { 
            Start-Diagnostic -Target "google.com" -Count 1 
        }
        "Q" { 
            Write-Host "Cerrando sesion..." -ForegroundColor Cyan
            break 
        }
        Default { 
            Write-Host "Opcion no valida." -ForegroundColor Red 
            Start-Sleep -Seconds 1
        }
    }
    
    if ($selection -ne "Q") {
        Write-Host "`nPresione ENTER para volver al menu..." -ForegroundColor Gray
        Read-Host
    }

} until ($selection -eq "Q")