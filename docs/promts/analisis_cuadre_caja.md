# Análisis de Estructura Escalable: Cuadre de Caja

Este documento analiza el formato de "Cuadre de Caja" (basado en el excel de *Intenciones*) con el objetivo de abstraer sus componentes y crear un modelo de base de datos y API escalable. El objetivo es que esta misma estructura sirva para **Tienda, Donaciones, Intenciones** y futuros módulos.

## 1. Análisis de los Componentes Actuales (Según la Imagen)

Al observar el formato de Excel, identificamos los siguientes bloques de información:

1.  **Metadatos del Cuadre:**
    *   Módulo / Actividad (Ej: "INTENCIONES").
    *   Fecha de la actividad.
2.  **Conteo Físico de Efectivo (Desglose):**
    *   **Billetes:** Denominaciones locales ($2000, $1000, etc.) x Cantidad.
    *   **Monedas:** Denominaciones locales ($25, $10, etc.) x Cantidad.
    *   **Dólares (Divisa Extranjera):** Denominaciones extranjeras x Cantidad.
3.  **Resumen de Ingresos:**
    *   Total en moneda local (Pesos).
    *   Total en divisas (Dólares).
    *   Tasa de cambio aplicada.
    *   Total General convertido.
4.  **Salidas / Egresos (Distribución del dinero):**
    *   Depósito, Pago a préstamos específicos (Ej: COOPCUPADI), Aportaciones, etc.
5.  **Diferencia (Cuadre final):**
    *   El resultado de enfrentar el **Total General (Ingresos físicos)** contra el **Total Pagos (Salidas)**.

---

## 2. ¿Qué se QUITA (para hacerlo escalable)?

Para que el modelo sirva para cualquier módulo (Tienda, Donaciones, etc.), debemos eliminar las dependencias rígidas:

*   **❌ Campos fijos de egresos:** "Pago Préstamo COOPCUPADI" o "Aportación" no pueden ser columnas fijas en una tabla. Si mañana la tienda tiene un pago de "Proveedores", el modelo se rompería.
*   **❌ Separación estricta de tablas por módulo:** No deberíamos tener una tabla `cuadres_intenciones` y otra `cuadres_tienda`.
*   **❌ Columnas fijas de denominaciones:** No tener columnas como `cant_billetes_2000` en la base de datos, porque si el banco central emite un nuevo billete, habría que alterar la base de datos.

---

## 3. ¿Qué se QUEDA (Abstracción)?

*   **✅ Catálogo dinámico de denominaciones:** Una tabla maestra que guarde el valor de cada billete/moneda y su tipo.
*   **✅ Tipos de movimientos (Ingresos/Egresos):** Los conceptos como "Depósito" o "Préstamo" pasan a ser registros dinámicos de salida vinculados al cuadre.
*   **✅ Relación polimórfica o por "Origen":** El cuadre pertenece a un módulo específico ("Source" o "Module").

---

## 4. Propuesta de Arquitectura de Base de Datos (Relacional)

Para que el backend (Laravel/Postgres) soporte esto eficientemente, la base de datos debe diseñarse así:

### A. Tablas de Catálogo (Configuración)
1.  **`modules` (Módulos/Orígenes)**
    *   `id`, `name` (Ej: 'Intenciones', 'Tienda', 'Donaciones'), `is_active`.
2.  **`denominations` (Denominaciones de Moneda)**
    *   `id`, `value` (2000, 1000, 100, etc.), `type` (billete, moneda), `currency` (DOP, USD).

### B. Tablas Operativas (El Cuadre)
3.  **`cash_reconciliations` (Tabla Principal del Cuadre)**
    *   `id`, `module_id` (Relación a Tienda, Intenciones, etc.)
    *   `date` (Fecha de la actividad)
    *   `exchange_rate` (Tasa del dólar del día, Ej: 61.75)
    *   `total_local_currency` (Total pesos contados)
    *   `total_foreign_currency` (Total dólares contados)
    *   `total_general` (Total convertido)
    *   `total_expenses` (Total de pagos/salidas)
    *   `difference` (Diferencia: sobrante o faltante)
    *   `status` (Borrador, Cuadrado, Cerrado)
    *   `user_id` (Usuario que hace el cuadre)

4.  **`reconciliation_denominations` (El detalle físico de billetes/monedas)**
    *   `id`, `reconciliation_id` (FK)
    *   `denomination_id` (FK al billete de 2000, 100, etc.)
    *   `quantity` (Cantidad de billetes de ese tipo)
    *   `total` (quantity * valor de denominación)

5.  **`reconciliation_transactions` (Las salidas o pagos)**
    *   `id`, `reconciliation_id` (FK)
    *   `type` (egreso, ingreso_extra)
    *   `description` (Ej: "Pago Préstamo COOPCUPADI", "Pago Proveedor Agua")
    *   `amount` (Monto)

---

## 5. Flujo del API (Ejemplo de cómo funcionará el Backend)

Cuando el Frontend en Flutter envíe el cuadre de caja de la "Tienda" o de "Intenciones", enviará un JSON estructurado así:

```json
{
  "module_id": 1, // 1 = Intenciones, 2 = Tienda, etc.
  "date": "2026-03-11",
  "exchange_rate": 61.75,
  
  // Desglose del conteo físico
  "denominations": [
    { "denomination_id": 1, "quantity": 8 },  // 8 billetes de $2000
    { "denomination_id": 2, "quantity": 20 }  // 20 billetes de $1000
    // ...
  ],
  
  // Pagos o distribuciones del dinero
  "transactions": [
    { "description": "Depósito a cuenta", "amount": 0 },
    { "description": "Pago Préstamo COOPCUPADI", "amount": 52720.32 },
    { "description": "Aportación", "amount": 2563.00 }
  ]
}
```

## 6. Conclusión y Beneficios

Con esta estructura:
1. **Escalabilidad Infinita:** Si mañana abren el módulo de "Diezmos" o "Cafetería", solo agregamos un registro en la tabla `modules`. Todo el sistema de cuadre funcionará automáticamente sin tocar código.
2. **Mantenibilidad:** Los conceptos de gastos y billetes son dinámicos.
3. **Cálculos en el Backend:** Flutter solo enviará las cantidades, y Laravel (Postgres) se encargará de validar las matemáticas y calcular la diferencia exacta, asegurando integridad en los datos.
