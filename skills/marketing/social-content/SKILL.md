---
name: social-content
description: Genera contenido para Instagram Reels y TikTok a partir de una pieza o pedido impreso en 3D - guion toma a toma, caption, hashtags para México y texto alternativo
user-invocable: true
categories: [marketing, social-media, content]
version: 1.0.0
---

# Social Content

Convierte una pieza, pedido o proceso del taller en un video corto listo para grabar y publicar. Modo asistido: Claude prepara, la persona graba y publica.

## Usage

```
/social-content <pieza o tema> [formato]
```

### Examples

```
/social-content figura NFC de la taquería tap-test
/social-content soporte de bici que arreglé timelapse
/social-content ¿cuánto cuesta imprimir esto? llavero NFC
```

## Antes de escribir

- Lee `brand/` del proyecto (voz de marca, nombre, colores) si existe.
- Si el video muestra a un negocio cliente, confirma que el cliente autorizó aparecer y pide su @ para etiquetarlo.

## Formatos que funcionan para impresión 3D

| Formato | Hook típico |
|---|---|
| **Tap test** | Teléfono se acerca a la figura → se abre el menú. "Tu restaurante necesita esto" |
| **Timelapse** | La pieza "creciendo" capa por capa; revelar el resultado al final |
| **Antes / después** | El problema cotidiano → la pieza que lo resuelve |
| **¿Cuánto cuesta imprimir esto?** | Desglose rápido de costos (usar datos reales de `/print-quote`) |
| **Arreglé X con una impresión** | Serie recurrente de soluciones útiles |
| **Entrega al negocio** | Reacción del dueño + la pieza en su mostrador (etiquetar al negocio) |

## Output

```markdown
# <título interno>
**Formato**: ... · **Duración**: 15–30 s · **Plataformas**: Reels, TikTok, Shorts

## Hook (0–3 s)
Texto en pantalla: ...
Toma: ...

## Guion
| Seg | Toma (qué se ve) | Texto en pantalla / voz |
|---|---|---|

## Caption
<2–4 líneas, primera línea engancha, CTA al final: "Cotiza por WhatsApp (link en bio)">

## Hashtags (8–12)
Mezcla amplios (#impresion3d #3dprinting), nicho (#nfc #impresion3dmexico) y locales (#<ciudad> #hechoenmexico)

## Texto alternativo
<descripción de la pieza para accesibilidad>

## Audio
Sugerencia de tipo de audio (tendencia o voz en off); verificar en la app qué audios son tendencia esa semana
```

Si existe `social/` en el proyecto, guarda en `social/<AAAA-MM-DD>-<slug>.md`.

## Reglas

- Un video = una idea. Mostrar la pieza funcionando en los primeros 3 segundos.
- Texto en pantalla corto y legible; muchas personas ven sin sonido.
- No inventar métricas ni testimonios; usar sólo datos reales del cliente con su permiso.
- Un mismo video sirve para Reels, TikTok y Shorts; adaptar sólo caption y hashtags.
