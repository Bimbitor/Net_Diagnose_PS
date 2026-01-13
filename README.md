
# Network Diagnostic Tool (OSI Model)

![PowerShell](https://img.shields.io/badge/Language-PowerShell_5.1%2B-blue?style=for-the-badge&logo=powershell)
![Platform](https://img.shields.io/badge/Platform-Windows-0078D6?style=for-the-badge&logo=windows)
![License](https://img.shields.io/badge/License-MIT-green?style=for-the-badge)

## 📋 Descripción Técnica

**Network Diagnostic Tool** es una solución de automatización CLI (Command Line Interface) desarrollada en PowerShell. Su objetivo es ejecutar diagnósticos de red estructurados basándose en el **Modelo OSI**, permitiendo identificar cuellos de botella con precisión quirúrgica.

A diferencia de herramientas básicas como `ping`, este script valida secuencialmente la integridad de la conexión desde la capa física hasta la capa de aplicación, diferenciando entre fallos de hardware, enrutamiento, DNS o filtrado de puertos.

## ⚙️ Arquitectura y Lógica de Ejecución

El script implementa una estrategia de **Fail-Fast** (Fallo Rápido): valida las dependencias jerárquicamente. Si una capa inferior falla, el diagnóstico se detiene para evitar falsos positivos en capas superiores.


### Análisis de Componentes

1. **Capa 1/2 (Enlace de Datos):**
* **Implementación:** Uso del cmdlet `Get-NetRoute` para identificar dinámicamente el *NextHop*.
* **Ventaja:** Elimina la dependencia de parsear texto (string manipulation) de comandos legacy como `ipconfig`, garantizando robustez ante cambios de idioma del SO.


2. **Capa 7 (Aplicación/DNS):**
* **Implementación:** `Resolve-DnsName` encapsulado en bloques `try-catch`.
* **Lógica:** Detecta mediante Regex si el input es una IP pura para omitir este paso, optimizando el tiempo de ejecución.


3. **Capa 4 (Transporte):**
* **Implementación:** `Test-NetConnection -Port 443`.
* **Ventaja:** Realiza un *TCP Three-Way Handshake* real. Esto valida que el servicio web esté escuchando, a diferencia de `Test-Connection` (ICMP) que solo valida la presencia del host.


## 🚀 Características Principales

* **Menú Interactivo (Event Loop):** Implementado con ciclo `do-while` para permitir múltiples diagnósticos sin reiniciar la sesión.
* **Testing Iterativo:** Permite definir  iteraciones por prueba para detectar pérdida de paquetes intermitente (Jitter).
* **Clean Code:** Estructura modular con funciones parametrizadas (`Run-Diagnostic`, `Write-Log`) y tipado estricto.
* **Logging Visual:** Feedback inmediato mediante códigos de color semánticos (Verde=OK, Rojo=Fallo, Amarillo=Info).

## 📦 Instalación y Uso

### Prerrequisitos

* Windows 10/11 o Windows Server 2016+.
* PowerShell 5.1 o superior.

### Despliegue

1. Clonar el repositorio:
```bash
git clone [https://github.com/tu-usuario/network-diagnostic-tool.git](https://github.com/tu-usuario/network-diagnostic-tool.git)
cd network-diagnostic-tool

```


2. Ejecutar el script (puede requerir permisos de ejecución):
```powershell
Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -Scope Process
.\Net_Diagnose_v3.ps1

```



## 💻 Ejemplo de Salida

```text
==========================================
   DIAGNOSTICO DE RED AUTOMATIZADO
==========================================
1. Test Personalizado (Ingresar IP/Dominio)
2. Test Rápido a Google (8.8.8.8)
...

Seleccione una opción: 1
Ingrese Dominio o IP: platzi.com
Cantidad de iteraciones: 3

[Iteración 1 de 3] Capa 1/2: Conexión al Gateway (192.168.1.1) [OK] Capa 7: Resolución DNS (platzi.com -> 104.18.32.120) [OK] Capa 3: Ping a platzi.com [OK] Capa 4: Conexión TCP Puerto 443 (HTTPS) [OK]

```

## 👤 Autor

**Javi Giraldo**

* *Data Engineering Student & Programmer*
* Especializado en automatización, arquitecturas de datos y optimización de flujos de trabajo.

---

*Este proyecto fue desarrollado bajo estándares de código de producción para entornos Windows.*

```