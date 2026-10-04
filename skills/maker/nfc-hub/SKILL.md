---
name: nfc-hub
description: Genera la página hub de un negocio (menú, WiFi con QR, reseña en Google, redes, WhatsApp) a la que apunta el tag NFC de una pieza impresa, más las instrucciones para programar y bloquear el tag
user-invocable: true
categories: [maker, nfc, web, business]
version: 1.0.0
---

# NFC Hub

Crea la página única que se abre al acercar el teléfono a la pieza NFC de un negocio: todo centralizado en un solo toque.

## Usage

```
/nfc-hub <negocio> [datos]
```

### Examples

```
/nfc-hub "Café La Esquina" menú=https://... wifi=LaEsquina-Clientes
/nfc-hub barbería "El Bigote" --sin-wifi
```

## Principio clave: el tag guarda UNA URL

- El tag apunta a `https://<dominio>/h/<slug-cliente>/`. El contenido se cambia en la página **sin reprogramar** el tag.
- **WiFi por NFC no funciona en iPhone**: iOS ignora los registros WiFi NDEF. Por eso el WiFi va dentro del hub (nombre de red, botón "copiar contraseña" y QR de WiFi, que la cámara del iPhone sí lee).
- La URL debe ser de un dominio propio y estable: si el host cambia, todos los tags quedan rotos y están bloqueados.

## Datos a pedir (sólo los que falten)

| Dato | Notas |
|---|---|
| Nombre, logo, colores | Logo como archivo en la carpeta del cliente |
| Menú | URL existente o PDF/imagen para alojar junto al hub |
| WiFi | SSID y contraseña de la **red de invitados** (la página es pública; nunca la red interna) |
| Reseña Google | Place ID → `https://search.google.com/local/writereview?placeid=<PLACE_ID>` (se obtiene con el *Place ID Finder* de Google Maps Platform) |
| Redes | Instagram, TikTok, Facebook |
| WhatsApp | Número en formato internacional → `https://wa.me/52XXXXXXXXXX` |
| Extras | Horario, ubicación (link de Google Maps), promo del mes, reservaciones |

No ofrezcas descuentos o regalos a cambio de reseñas: viola las políticas de Google y puede bajar las reseñas del negocio.

## Página a generar

Un solo `index.html` autocontenido (CSS inline), mobile-first, carga rápida, sin frameworks:

1. Encabezado: logo + nombre
2. Botones grandes en este orden: **Ver menú**, **WiFi**, **Déjanos tu reseña**, WhatsApp, redes, ubicación
3. Sección WiFi: SSID visible, botón "Copiar contraseña" (`navigator.clipboard.writeText`) y QR con el texto `WIFI:T:WPA;S:<ssid>;P:<password>;;`. Escapa `\ ; , : "` con `\` en SSID y contraseña. Para dibujar el QR usa una librería pequeña por CDN, p. ej. `https://cdnjs.cloudflare.com/ajax/libs/qrcodejs/1.0.0/qrcode.min.js`
4. Pie discreto con la marca del estudio (canal de adquisición de nuevos clientes)
5. Medición de origen: los enlaces del tag y del QR impreso llevan `?src=nfc` y `?src=qr` para distinguirlos después en la analítica

Si existe `hubs/` en el proyecto, guarda en `hubs/<slug>/index.html` con sus assets. Los datos sensibles del cliente (contactos, notas) van en `clients/<slug>/`, que debe estar en `.gitignore` si contiene información privada.

## Publicación

Cualquier hosting estático gratuito con dominio propio: GitHub Pages, Cloudflare Pages o Netlify. Verifica la URL final en un iPhone y en un Android antes de programar el tag.

## Programar y bloquear el tag

Con la app **NFC Tools** (iOS y Android):

1. *Write* → *Add a record* → *URL/URI* → pegar `https://<dominio>/h/<slug>/?src=nfc`
2. *Write* y acercar el tag
3. Probar con **dos teléfonos** (iPhone XS o más nuevo lee URLs en segundo plano; en Android el NFC debe estar activado)
4. Sólo cuando funcione: *Other* → *Lock tag*. **Es irreversible**; evita que alguien reescriba el tag con otra URL
5. Tag recomendado: NTAG213 (144 bytes, suficiente para una URL) o NTAG215

## Respaldo

Genera también un QR impreso con `?src=qr` para teléfonos sin NFC; se puede grabar en relieve o pegar en la base de la pieza.

## Checklist de entrega

- [ ] Hub publicado y probado en iPhone y Android
- [ ] WiFi de invitados verificado desde el QR
- [ ] Link de reseña abre directamente el formulario de Google
- [ ] Tag programado, probado y bloqueado
- [ ] QR de respaldo en la pieza
- [ ] Cliente sabe cómo pedir cambios (menú, promos, WiFi)
