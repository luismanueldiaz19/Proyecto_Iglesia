# Módulo de Intenciones

## Objetivo

Integrar al sistema existente un módulo llamado **Intenciones**, cuyo propósito es permitir que personas interactúen con el sistema mediante WhatsApp utilizando lenguaje natural.

El sistema principal ya existe y cuenta con sus funcionalidades actuales, incluyendo usuarios, autenticación, permisos y demás módulos.

**No se debe reconstruir el sistema existente.**

El objetivo es agregar únicamente este nuevo módulo e integrarlo con la plataforma actual.

---

## Idea principal

El módulo funcionará como un intermediario entre:

**Persona → WhatsApp → IA → Sistema**

La persona podrá escribir por WhatsApp de forma natural y enviar imágenes o documentos.

La IA interpretará lo que la persona quiere hacer y extraerá la información necesaria.

Sin embargo, la IA **no tendrá autoridad para aprobar operaciones administrativas o financieras**.

---

## Primera intención

La primera intención que se desea implementar será el registro de una **ofrenda mediante transferencia bancaria**.

Ejemplo:

> Hola, hice una ofrenda de 5,000 pesos.

El sistema puede identificar que la persona desea registrar una ofrenda.

Luego el bot puede solicitar:

> Por favor, envíame el comprobante de la transferencia.

La persona envía el comprobante por WhatsApp.

La IA podrá interpretar la información visible en el comprobante, por ejemplo:

- Nombre.
- Monto.
- Fecha.
- Banco.
- Número o referencia de transacción.
- Otros datos disponibles.

---

## Estado inicial

Todo comprobante recibido debe registrarse inicialmente como:

**PENDIENTE**

La IA únicamente ayuda a interpretar y organizar la información.

No debe marcar automáticamente una transferencia como aprobada.

---

## Revisión administrativa

Después de recibir el comprobante, el registro aparecerá dentro del sistema existente en una lista de operaciones pendientes.

Un administrador podrá revisar:

- Persona.
- Monto.
- Fecha.
- Banco.
- Referencia.
- Comprobante original.
- Información interpretada por la IA.

El administrador tendrá la capacidad de:

**APROBAR**

o

**RECHAZAR**

el registro.

---

## Flujo general

```text
Persona
   ↓
WhatsApp
   ↓
Mensaje
   ↓
Módulo de Intenciones
   ↓
IA interpreta la intención
   ↓
Solicita información faltante
   ↓
Persona envía comprobante
   ↓
IA interpreta el comprobante
   ↓
Sistema registra la operación
   ↓
Estado: PENDIENTE
   ↓
Administrador revisa
   ↓
APROBADO / RECHAZADO
```

---

## Importante

El módulo debe estar diseñado pensando que en el futuro pueden existir muchas otras intenciones.

Por ejemplo:

- Registrar una ofrenda.
- Registrar una donación.
- Consultar una operación.
- Consultar información.
- Solicitar algún servicio.
- Otras acciones que puedan agregarse posteriormente.

Por eso, **“Intenciones” debe ser el concepto general del módulo**, mientras que `REGISTRAR_OFRENDA` será solamente la primera intención implementada.

---

## Principio fundamental

La IA interpreta.

El sistema valida.

El administrador decide cuando sea necesaria una aprobación humana.

La IA no debe modificar directamente información crítica sin pasar por las reglas de negocio del sistema.

---

## Resultado esperado

El resultado final debe ser una integración natural entre WhatsApp y el sistema existente.

Para el usuario, la experiencia debe sentirse como una conversación:

> Usuario: Quiero hacer una ofrenda de RD$5,000.

> Bot: Claro. Envíame el comprobante.

> Usuario: [envía comprobante]

> Bot: Hemos recibido tu comprobante por RD$5,000. Será revisado por un administrador.

Mientras tanto, en el sistema:

```text
Ofrenda
Persona: Luis
Monto: RD$5,000
Comprobante: recibido
Estado: PENDIENTE
```

Posteriormente:

```text
Administrador
      ↓
Revisa
      ↓
APROBAR / RECHAZAR
```

---

## Instrucción para el agente

Antes de escribir código, analizar el sistema existente y determinar la mejor forma de integrar este módulo respetando la arquitectura, tecnologías, convenciones y seguridad ya implementadas.

No crear nuevamente funcionalidades que el sistema ya posee.

Primero comprender la arquitectura actual y luego proponer cómo integrar el **Módulo de Intenciones**.
