---
name: iot-firmware
description: Crea un proyecto de firmware ESP32 (PlatformIO + Arduino) para una pieza impresa con vida propia, con configuración WiFi sin recompilar, OTA y checklist de alimentación y carcasa
user-invocable: true
categories: [maker, iot, esp32, firmware]
version: 1.0.0
---

# IoT Firmware

Arma el firmware de una pieza impresa con microcontrolador (botón "llamar mesero", semáforo de ocupación, turnero, contador) listo para entregar a un negocio.

## Usage

```
/iot-firmware <producto> [placa]
```

### Examples

```
/iot-firmware botón llamar mesero que avisa por Telegram
/iot-firmware semáforo de ocupación con LED WS2812 esp32-c3
```

## Stack

- **PlatformIO** (VS Code, funciona igual en Windows y macOS) con framework Arduino
- **WiFiManager** (`tzapu/WiFiManager`): el negocio conecta la pieza a su WiFi desde el teléfono, sin recompilar
- **ArduinoOTA**: actualizar firmware por WiFi, con contraseña
- Avisos al personal: bot de Telegram o webhook HTTP (lo más simple que funcione en el negocio)

## Estructura

```
firmware/<producto>/
├── platformio.ini
├── src/main.cpp
├── include/config.h        # pines, nombres, intervalos (sin secretos)
└── README.md               # cableado, cómo configurar WiFi, cómo actualizar
```

`platformio.ini` base:

```ini
[env:esp32dev]
platform = espressif32
board = esp32dev
framework = arduino
monitor_speed = 115200
lib_deps =
    tzapu/WiFiManager
```

Esqueleto de `main.cpp`:

```cpp
#include <WiFiManager.h>
#include <ArduinoOTA.h>
#include "config.h"

void setup() {
  Serial.begin(115200);
  WiFiManager wm;
  wm.setConfigPortalTimeout(180);
  if (!wm.autoConnect(DEVICE_NAME "-Setup")) ESP.restart();

  ArduinoOTA.setHostname(DEVICE_NAME);
  ArduinoOTA.setPassword(OTA_PASSWORD);
  ArduinoOTA.begin();
  // pines y periféricos del producto
}

void loop() {
  ArduinoOTA.handle();
  // lógica del producto, sin delay() largos (usar millis())
}
```

## Reglas

- Secretos (token de Telegram, contraseña OTA) **fuera del repo**: `include/secrets.h` en `.gitignore` con un `secrets.example.h` versionado
- Botones con debounce; sin `delay()` largos en `loop()`
- Reconexión automática si cae el WiFi; la pieza debe recuperarse sola tras un corte de luz
- Indicador de estado visible (LED): configurando, conectado, error

## Checklist de hardware y carcasa

- **Alimentación**: USB-C 5 V con cargador de pared es lo más confiable. Baterías LiPo sólo con módulo de protección/carga y fuera de piezas selladas
- **Calor**: el ESP32 se calienta con WiFi activo; dejar ventilación y no usar PLA junto a reguladores calientes (usar PETG)
- **Acceso**: tapa con tornillos o insertos de calor para servicio; puerto USB accesible para recuperar el dispositivo
- **Antena**: sin metal alrededor de la antena del ESP32
- Probar 24 h continuas antes de entregar

## Output

Genera los archivos en `firmware/<producto>/` si existe la carpeta; si no, en la ruta que indique el usuario. Incluye en el README: diagrama de cableado en texto, lista de materiales con costo aproximado (para `/print-quote`) y pasos de configuración para el cliente.
