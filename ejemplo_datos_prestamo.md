# Ejemplo de Datos de Préstamo - Estado de Cuenta

Basado en el documento "Estado De Cuenta De Prestamo" de la imagen, aquí tienes los datos estructurados para utilizarlos como referencia o ejemplo al registrar un nuevo préstamo en el sistema:

## 1. Datos Generales (Prestamista / Socio)
*   **Oficina:** 1 Oficina Principal, La Vega (ej. CoopCupadec)
*   **Número de Socio:** 181
*   **Número de Préstamo:** 88
*   **Nombre / Titular:** CENTRO DE EVANGELIZACION PADRE FANTINO (CONTROBA, LA VEGA)
*   **Cédula:** 430372392

## 2. Condiciones Financieras del Préstamo
*   **Monto Préstamo (Original):** 2,840,415.98
*   **Fecha del Préstamo:** 19-oct-2023
*   **Tasa (Mensual):** 1.25
*   **Plazo:** 60
*   **Expresión Plazo:** Mensual(es)
*   **Tipo Préstamo:** PRESTAMOS CORRIENTES
*   **Modalidad del Préstamo:** 2 - INTERES Y CAPITAL MENSUAL - CUOTAS FIJAS

## 3. Estado de Cuenta Actual
*   **Valor Cuota (Cuota Regular):** 60,436.32
*   **Saldo Actual:** 918,806.36
*   **Fecha Próximo Capital:** 05-oct-2026
*   **Fecha Próximo Interés:** 05-oct-2026

## 4. Ejemplo de Tabla de Transacciones (Amortización/Abonos)
*(Ejemplo de una fila del desglose para entender cómo se aplica un pago)*

| FECHA | TRANSACCIONES | NÚM. REF. | PAGO TOTAL | PAGO DE CAPITAL | BALANCE | INTERES | MORA | SEGURO |
| :--- | :--- | :--- | :--- | :--- | :--- | :--- | :--- | :--- |
| 10-sep-2025 | PAGO DE PRESTAMO DESDE CUENTA DE AHORROS... | NC 138899 | 60,436.32 | 37,327.42 | 1,801,256.68 | 23,108.90 CR | - | - |
| 7-oct-2025 | PAGO DE PRESTAMO DESDE CUENTA DE AHORROS... | NC 139040 | 60,436.32 | 37,842.92 | 1,763,413.76 | 22,593.40 CR | - | - |
| 5-nov-2025 | INGRESO PAGO DE PRESTAMOS EN CAJA | RI 6210 | 50,975.00 | 28,900.68 | 1,734,513.08 | 22,074.32 CR | - | - |

> Este archivo servirá como plantilla base para hacer las pruebas de registro y cálculo en el "Módulo de Préstamos".
