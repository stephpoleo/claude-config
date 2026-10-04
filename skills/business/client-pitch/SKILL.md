---
name: client-pitch
description: Prepara la propuesta de venta para un negocio local concreto (restaurante, cafetería, barbería, Airbnb, consultorio) - problema, demo, paquetes, mensaje de WhatsApp, guion de visita y respuesta a objeciones
user-invocable: true
categories: [business, sales, b2b]
version: 1.0.0
---

# Client Pitch

Arma todo lo necesario para ofrecer una pieza NFC + hub (u otro producto funcional) a un negocio específico.

## Usage

```
/client-pitch <negocio> <tipo> [ciudad]
```

### Examples

```
/client-pitch "Café La Esquina" cafetería Guadalajara
/client-pitch "Barbería El Bigote" barbería
/client-pitch anfitrión con 3 Airbnbs en Playa del Carmen
```

## Información a reunir

Pide a la persona que pegue lo que encuentre (no inventes datos del negocio):
- Calificación y número de reseñas en Google Maps
- Si tienen menú digital, WiFi para clientes, Instagram activo, WhatsApp Business
- Mascota, logo o elemento icónico que pueda volverse figura
- Quién decide (dueño, gerente) y mejor horario para visitar

Si existe `pricing/paquetes.md` en el proyecto, usa esos paquetes y precios. Si no, propón estructura con precios marcados como `(definir)`.

## Ángulo por tipo de negocio

| Tipo | Dolor principal | Qué resuelve el hub |
|---|---|---|
| Cafetería / restaurante | "¿Cuál es el WiFi?", pocas reseñas, menú en papel | WiFi + menú + reseña en un toque |
| Barbería / salón | Reseñas y citas por mensaje | Reseña + agendar por WhatsApp + Instagram |
| Airbnb / hospedaje | Preguntas repetidas del huésped | WiFi + guía de la casa + reseña |
| Consultorio | Reputación en Google | Reseña + agenda + ubicación |

## Output

```markdown
# Propuesta: <negocio>

## Diagnóstico (2–3 líneas)
Situación actual basada en los datos que se dieron.

## Propuesta
Pieza (descripción + render o foto de demo) + hub (qué incluye).

## Paquetes
| Paquete | Incluye | Precio |
|---|---|---|
| Básico | Figura NFC + hub | |
| Pro | + cambios ilimitados + reporte mensual de toques | mensualidad |
| Multi-sucursal | Varias piezas, un hub por sucursal | |

## Mensaje de WhatsApp (primer contacto)
<máximo 4 líneas, personal, con una pregunta concreta; sin enlaces en el primer mensaje>

## Guion de visita (5 minutos)
1. Saludo y por qué ese negocio
2. **Tap test**: entregar la pieza demo y pedir que acerquen su teléfono
3. Mostrar cómo se vería con su menú/WiFi/reseñas
4. Paquetes y piloto
5. Cierre: fecha de entrega o siguiente paso concreto

## Objeciones
| Objeción | Respuesta |
|---|---|
| "Ya tengo un QR" | ... |
| "Está caro" | ... |
| "Lo voy a pensar" | ... |
| "¿Y si se descompone?" | ... |
```

## Reglas

- No prometer número de reseñas ni ofrecer incentivos por reseñas (viola las políticas de Google).
- Ofrecer piloto (a costo o con descuento) a cambio de testimonio y permiso para grabar el video de entrega.
- Mencionar factura si el negocio la requiere.
- Tono cercano, español de México, sin tecnicismos ("se abre en el celular al acercarlo", no "NDEF").
