# 🔍 Automated Network Diagnostic Tool (PowerShell)

![Platform](https://img.shields.io/badge/platform-Windows-blue) ![Language](https://img.shields.io/badge/language-PowerShell-5391FE) ![License](https://img.shields.io/badge/license-MIT-green)

Un script de automatización en **PowerShell** diseñado para técnicos de soporte TI y administradores de sistemas. Realiza un diagnóstico de red secuencial basado en el **Modelo OSI**, permitiendo identificar rápidamente si una falla es física, de configuración IP, de DNS o de bloqueo de puertos.

---

## 🚀 Características Principales

* **Diagnóstico por Capas:** Analiza secuencialmente desde la Capa 1 (Física) hasta la Capa 7 (Aplicación).
* **Detección de Fallos Específicos:** Distingue entre "No hay internet", "Error de DNS" y "Servicio Caído".
* **Feedback Visual:** Uso de colores en consola para identificar estados (Verde=OK, Rojo=Fallo, Amarillo=Diagnóstico).
* **Traceroute Automático:** Se ejecuta automáticamente si falla la conectividad de Capa 3.
* **Portable:** No requiere instalación de software de terceros, solo Windows nativo.

## 🛠️ Requisitos Previos

* **Sistema Operativo:** Windows 10, Windows 11 o Windows Server.
* **PowerShell:** Versión 5.1 o superior.
* **Permisos:** Permisos de ejecución de scripts habilitados en la terminal.

## 📦 Instalación y Uso

1.  **Clonar el repositorio** (o descargar el archivo):
    ```bash
    git clone [https://github.com/tu-usuario/network-diagnostic-tool.git](https://github.com/tu-usuario/network-diagnostic-tool.git)
    cd network-diagnostic-tool
    ```

2.  **Permitir ejecución de scripts** (Solo la primera vez):
    Por seguridad, Windows bloquea scripts descargados. Abre PowerShell como Administrador y ejecuta:
    ```powershell
    Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -Scope CurrentUser
    ```

3.  **Ejecutar la herramienta:**
    Haz clic derecho sobre `DiagnosticoRed.ps1` y selecciona **"Ejecutar con PowerShell"**, o desde la terminal:
    ```powershell
    .\DiagnosticoRed.ps1
    ```

## 🧠 ¿Cómo funciona? (Lógica OSI)

El script sigue un flujo de decisión lógica para aislar el problema:

| Paso | Capa OSI | Acción Técnica | Diagnóstico Posible |
| :--- | :--- | :--- | :--- |
| **1** | **Capa 1/2 (Física/Enlace)** | Ping al Default Gateway local. | Cable desconectado, falla de Wi-Fi o tarjeta de red. |
| **2** | **Capa 7 (Aplicación)** | Intento de resolución DNS (`Resolve-DnsName`). | Servidor DNS no responde o configuración IP errónea. |
| **3** | **Capa 3 (Red)** | Ping ICMP al host destino. | Problema de enrutamiento, ISP caído o bloqueo ICMP. |
| **4** | **Capa 4 (Transporte)** | Handshake TCP al puerto 443 (`Test-NetConnection`). | Firewall bloqueando el puerto o servicio web detenido. |

## 📸 Capturas de Pantalla

*(Opcional: Aquí puedes agregar una captura de pantalla de tu script funcionando)*
`![Ejemplo de Ejecución](./screenshot.png)`

## 🤝 Contribución

Las contribuciones son bienvenidas. Por favor, abre un "Issue" para discutir cambios mayores antes de enviar un "Pull Request".

## 📄 Licencia

Este proyecto está bajo la Licencia MIT - ver el archivo [LICENSE](LICENSE) para más detalles.

---
*Desarrollado con fines educativos y de soporte técnico.*
