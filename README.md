# Network Diagnostic Tool (OSI Model)

![PowerShell](https://img.shields.io/badge/Language-PowerShell_5.1%2B-blue?style=for-the-badge&logo=powershell)
![Platform](https://img.shields.io/badge/Platform-Windows-0078D6?style=for-the-badge&logo=windows)
![License](https://img.shields.io/badge/License-MIT-green?style=for-the-badge)

## 📋 Descripción Técnica

**Network Diagnostic Tool** es una solución de automatización CLI (Command Line Interface) desarrollada en PowerShell. Su objetivo es ejecutar diagnósticos de red estructurados basándose en el **Modelo OSI**, permitiendo identificar cuellos de botella con precisión quirúrgica.

A diferencia de herramientas básicas como `ping`, este script valida secuencialmente la integridad de la conexión desde la capa física hasta la capa de aplicación, diferenciando entre fallos de hardware, enrutamiento, DNS o filtrado de puertos.

## ⚙️ Arquitectura y Lógica de Ejecución

El script implementa una estrategia de **Fail-Fast** (Fallo Rápido): valida las dependencias jerárquicamente. Si una capa inferior falla, el diagnóstico se detiene para evitar falsos positivos en capas superiores.

### Diagrama de Flujo (Mermaid)

```mermaid
graph TD
    A[Inicio: Input Target] --> B{Capa 1/2: Gateway}
    B -- Fallo --> X[ERROR: Enlace Físico/Local]
    B -- OK --> C{Capa 7: DNS}
    C -- Fallo --> Y[ERROR: Resolución de Nombres]
    C -- OK --> D{Capa 3: Red (ICMP)}
    D -- Fallo --> Z[ERROR: Bloqueo Firewall/Ruta]
    D -- OK --> E{Capa 4: Transporte (TCP)}
    E -- Fallo --> W[ERROR: Puerto Cerrado/Filtrado]
    E -- OK --> F[SUCCESS: Servicio Operativo]