---
name: print-quote
description: Cotiza una pieza impresa en 3D (FDM o resina) con NFC/electrónica opcional y devuelve el precio en MXN con desglose de costos, margen e IVA
user-invocable: true
categories: [maker, 3d-printing, pricing, business]
version: 1.0.0
---

# Print Quote

Calcula el costo real y el precio de venta de una pieza impresa en 3D. Nunca inventes costos: si falta un dato, usa la tabla de costos base del proyecto o pregunta.

## Usage

```
/print-quote <descripción de la pieza> [opciones]
```

### Examples

```
/print-quote figura restaurante 60g PLA 4h con NFC
/print-quote soporte de celular 35g PETG 2.5h --cantidad=10
/print-quote miniatura resina 18ml 3h --canal=mercadolibre
```

## Fuentes de datos (en este orden)

1. `pricing/costos.md` del proyecto actual (si existe): precios de filamento/resina, kWh, depreciación, tarifa de mano de obra, margen objetivo.
2. Datos que el usuario dé en el mensaje.
3. Si falta algo, **pregunta**. No uses valores por defecto sin decirlo; si el usuario pide una estimación rápida, marca cada supuesto como `(supuesto)`.

Los gramos y horas salen del slicer (Bambu Studio, PrusaSlicer, Cura, Chitubox/Lychee para resina). Si el usuario no los tiene, pide que slicee la pieza primero.

## Fórmula

```
material      = gramos × (precio_kg / 1000)              # FDM
              = ml × (precio_litro / 1000) × 1.1          # resina (+10% por soportes/purga)
energía       = horas × (watts / 1000) × precio_kWh
máquina       = horas × depreciación_hora                 # precio_impresora / horas_vida_útil
fallas        = (material + energía) × tasa_fallas        # 10% FDM, 15% resina si no hay dato
componentes   = tag NFC + electrónica + imanes/insertos + empaque
mano_de_obra  = horas_humanas × tarifa_hora               # diseño, post-proceso, programar NFC, armado
costo_total   = material + energía + máquina + fallas + componentes + mano_de_obra
precio_base   = costo_total × (1 + margen)
comisión      = precio_base × comisión_canal / (1 - comisión_canal)   # sólo si --canal
precio_final  = (precio_base + comisión) × 1.16           # IVA, si factura
```

Resina: suma consumibles (alcohol isopropílico, guantes, FEP) dentro de `componentes` o como costo fijo por pieza.

Cantidad > 1: el diseño y la configuración se cobran una vez; prorratéalos entre las piezas y muéstralo.

## Output

```markdown
## Cotización: <pieza>

| Concepto | Cálculo | MXN |
|---|---|---|
| Material | 60 g × $0.45/g | $27.00 |
| Energía | 4 h × 0.12 kW × $X/kWh | ... |
| Máquina | 4 h × $X/h | ... |
| Fallas (10%) | ... | ... |
| Componentes | NTAG213 + empaque | ... |
| Mano de obra | 0.5 h × $X/h | ... |
| **Costo total** | | **$...** |
| Margen (X%) | | ... |
| **Precio sin IVA** | | **$...** |
| **Precio con IVA** | | **$...** |

**Precio mínimo** (margen 0): $...
**Supuestos**: ...
```

Termina con una línea de recomendación: si el precio queda por debajo del mercado o del valor percibido (p. ej. una figura NFC para negocio que sustituye placas de $150–500 MXN), dilo y sugiere el precio por valor, no sólo por costo.

## Reglas

- Moneda MXN, dos decimales; redondea el precio final a múltiplos de $5 o $10.
- Mano de obra nunca en cero: el tiempo de diseño, post-proceso y programación del NFC se cobra.
- Si la pieza va a un negocio, recuerda que el hub/suscripción se cotiza aparte (ver `client-pitch`).
