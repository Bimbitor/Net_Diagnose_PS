# ==========================================
# DIAGNOSTICO DE RED AUTOMATIZADO (OSI MODEL)
# ==========================================
Clear-Host
Write-Host "--- INICIANDO DIAGNOSTICO DE RED ---" -ForegroundColor Cyan
$objetivo = Read-Host "Dominio o IP: "

# Función auxiliar para pausar antes de salir
function Pausar-Y-Salir {
    Write-Host "`n----------------------------------------" -ForegroundColor Gray
    Write-Host "Diagnóstico finalizado. Presiona ENTER para cerrar." -NoNewline
    Read-Host
    Exit
}

# --- PASO 1: VALIDACIÓN LOCAL (CAPA 1 y 2) ---
Write-Host "`n[1] Verificando tu propia conexión (Gateway)..." -NoNewline
$gateway = (Get-NetRoute | Where-Object { $_.DestinationPrefix -eq "0.0.0.0/0" } | Select-Object -ExpandProperty NextHop)

if ($gateway) {
    $testGateway = Test-Connection -ComputerName $gateway -Count 1 -Quiet
    if ($testGateway) {
        Write-Host " OK" -ForegroundColor Green
    } else {
        Write-Host " FALLÓ" -ForegroundColor Red
        Write-Host ">> DIAGNÓSTICO: Error en CAPA 1 (Física) o CAPA 2 (Enlace)." -ForegroundColor Yellow
        Write-Host ">> CAUSA: Tu PC no alcanza el Router. Revisa el cable, WiFi o tarjeta de red."
        Pausar-Y-Salir
    }
} else {
    Write-Host " FALLÓ" -ForegroundColor Red
    Write-Host ">> DIAGNÓSTICO: Error en CAPA 3 (Red) - Configuración Local." -ForegroundColor Yellow
    Write-Host ">> CAUSA: No tienes una Puerta de Enlace (Gateway) asignada (IP 169.254.x.x)."
    Pausar-Y-Salir
}

# --- PASO 2: RESOLUCIÓN DE NOMBRES (CAPA 7 - APLICACIÓN/DNS) ---
$esIP = $objetivo -match "\b\d{1,3}\.\d{1,3}\.\d{1,3}\.\d{1,3}\b"

if (-not $esIP) {
    Write-Host "[2] Verificando Resolución DNS (Capa 7)..." -NoNewline
    try {
        $dnsTest = Resolve-DnsName -Name $objetivo -ErrorAction Stop
        Write-Host " OK ($($dnsTest.IPAddress[0]))" -ForegroundColor Green
    } catch {
        Write-Host " FALLÓ" -ForegroundColor Red
        Write-Host ">> DIAGNÓSTICO: Error en CAPA 7 (Aplicación/DNS)." -ForegroundColor Yellow
        Write-Host ">> CAUSA: Tu internet funciona, pero no puede traducir el nombre '$objetivo'. Intenta 'ipconfig /flushdns' o cambia tus DNS a 8.8.8.8."
        Pausar-Y-Salir
    }
}

# --- PASO 3: ENRUTAMIENTO Y CONECTIVIDAD (CAPA 3 - RED) ---
Write-Host "[3] Verificando conectividad Ping (Capa 3)..." -NoNewline
$pingTest = Test-Connection -ComputerName $objetivo -Count 2 -Quiet

if ($pingTest) {
    Write-Host " OK" -ForegroundColor Green
} else {
    Write-Host " FALLÓ" -ForegroundColor Red
    Write-Host ">> DIAGNÓSTICO: Error en CAPA 3 (Red)." -ForegroundColor Yellow
    Write-Host ">> CAUSA: El DNS resuelve, pero los paquetes no llegan. Puede ser Firewall o servidor caído."
    Write-Host "   -> Ejecutando trazado de ruta..."
    tracert $objetivo
    Pausar-Y-Salir
}

# --- PASO 4: PUERTOS Y SERVICIOS (CAPA 4 - TRANSPORTE) ---
Write-Host "[4] Verificando Servicio Web - Puerto 443 (Capa 4)..." -NoNewline
$portTest = Test-NetConnection -ComputerName $objetivo -Port 443 -InformationLevel Quiet

if ($portTest) {
    Write-Host " OK" -ForegroundColor Green
    Write-Host "`n--- RESULTADO FINAL ---" -ForegroundColor Cyan
    Write-Host "El sistema funciona correctamente. El fallo no es de red." -ForegroundColor Green
} else {
    Write-Host " FALLÓ" -ForegroundColor Red
    Write-Host ">> DIAGNÓSTICO: Error en CAPA 4 (Transporte)." -ForegroundColor Yellow
    Write-Host ">> CAUSA: El servidor responde al Ping, pero rechaza la conexión al servicio (Puerto Cerrado)."
}

# Pausa final si todo salió bien
Pausar-Y-Salir