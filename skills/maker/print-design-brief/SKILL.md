---
name: print-design-brief
description: Convierte el pedido de un cliente en una especificación de impresión 3D (licencia, medidas, material, tolerancias, cavidad NFC, orientación) y genera OpenSCAD paramétrico cuando aplica
user-invocable: true
categories: [maker, 3d-printing, design]
version: 1.0.0
---

# Print Design Brief

Transforma una idea o pedido ("quiero un porta-servilletas con el logo del café y NFC") en un brief listo para modelar e imprimir.

## Usage

```
/print-design-brief <descripción del pedido>
```

### Examples

```
/print-design-brief figura de la mascota de una taquería con NFC para el mostrador
/print-design-brief organizador de cables mejorado basado en https://www.printables.com/model/...
/print-design-brief llavero NFC con tarjeta de contacto para agente inmobiliario
```

## Proceso

### 1. Origen y licencia (siempre primero)

Pregunta de dónde viene el diseño:

| Origen | ¿Se puede vender la impresión? |
|---|---|
| Diseño propio desde cero | Sí |
| Printables/Thingiverse/MakerWorld con **CC BY, CC BY-SA, CC0** | Sí, dando crédito al autor |
| Con **CC BY-NC** o "no comercial" (y sus remixes) | **No.** Pedir licencia comercial al autor o rediseñar desde cero |
| Licencia comercial comprada | Sí, dentro de sus términos |
| "Idea mejorada" de algo visto | Sí, si se modela desde cero; las ideas no tienen copyright, la geometría sí |
| Logos/personajes de terceros | Sólo el logo del propio cliente con su autorización; no personajes con marca registrada |

Registra URL, autor y licencia en el brief.

### 2. Requisitos funcionales

Pregunta sólo lo que falte:
- **Función** y dónde vivirá (mostrador, exterior, cocina, auto)
- **Medidas** máximas o del objeto con el que encaja
- **Entorno**: sol/calor (PLA se deforma cerca de 55–60 °C → usar PETG o ASA), humedad, contacto con comida (las piezas FDM **no** son seguras para alimentos sin recubrimiento certificado; decirlo)
- **Carga/esfuerzo** y piezas móviles
- **Acabado**: color(es), texto, logo; resina si requiere detalle fino
- **Cantidad** y fecha de entrega

### 3. Especificación técnica

- **Material y proceso**: PLA (decorativo, interior), PETG (resistencia, calor moderado), TPU (flexible), resina (detalle, figuras pequeñas)
- **Tolerancias FDM**: 0.2–0.3 mm para encajes; 0.4 mm para piezas que deslizan. Resina: 0.1–0.15 mm
- **Paredes**: mínimo 1.2 mm (3 perímetros con boquilla 0.4) para piezas funcionales
- **Orientación**: capas perpendiculares a la carga principal; minimizar soportes en caras visibles

### 4. Cavidad NFC (si aplica)

- Tag: NTAG213/215 (disco de 25 mm o 30 mm, ~0.5–1 mm de grosor; medir el tag real)
- Cavidad: diámetro tag + 0.5 mm, profundidad grosor + 0.2 mm
- Techo sobre el tag: 0.6–1.2 mm (más grueso reduce el alcance de lectura)
- Ubicar la cavidad del lado donde se acercará el teléfono; marcarlo en el diseño (icono NFC en relieve)
- Lejos de imanes y metal; si la pieza va sobre metal usar tag anti-metal
- **Pausa en capa** para insertar el tag: Bambu Studio (clic derecho en el deslizador de capas → *Add pause*), PrusaSlicer (*Add pause print*, M601), Cura (*Extensions → Post Processing → Pause at height*)
- Programar y probar el tag **antes** de cerrarlo dentro de la pieza

### 5. Modelo paramétrico (cuando sea geometría simple)

Para soportes, bases, cajas, porta-tags y placas, genera OpenSCAD con parámetros al inicio:

```openscad
// Base de mostrador con cavidad NFC
ancho = 80;   alto = 60;   grosor = 6;
tag_d = 25.5; tag_h = 1.2; techo = 0.8;

difference() {
    cube([ancho, alto, grosor]);
    translate([ancho/2, alto/2, grosor - techo - tag_h])
        cylinder(d = tag_d, h = tag_h, $fn = 96);
}
```

Para figuras orgánicas (mascotas, personajes), recomienda Blender, Nomad Sculpt o encargar el modelado, y describe en el brief las vistas de referencia necesarias.

## Output

Si existe la carpeta `designs/` en el proyecto, guarda en `designs/<slug>/BRIEF.md` y, si hay diseño de terceros, `designs/<slug>/SOURCE.md` (URL, autor, licencia). Si no, muestra el brief en la respuesta.

```markdown
# Brief: <pieza>
- Cliente / pedido:
- Origen y licencia:
- Función y entorno:
- Medidas:
- Material / proceso / color:
- Tolerancias y paredes:
- NFC: tag, cavidad, capa de pausa, URL a programar
- Orientación y soportes:
- Cantidad / entrega:
- Pendientes / preguntas abiertas:
```

Sugiere al final `/print-quote` con los datos del brief.
