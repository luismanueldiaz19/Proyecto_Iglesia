# Prompt — Análisis y diseño de módulo de recepción y validación de pagos por WhatsApp

Quiero analizar y diseñar un módulo para integrar **WhatsApp con un sistema empresarial**, cuyo objetivo principal sea recibir reportes de pagos enviados por clientes mediante WhatsApp y permitir que un administrador autenticado pueda revisar y confirmar manualmente dichos pagos.

**IMPORTANTE:** En esta primera etapa NO quiero que programes ni modifiques código. Quiero únicamente un análisis técnico y funcional completo de la solución, identificando arquitectura, flujo, entidades, estados, seguridad, integraciones y posibles problemas.

---

## 1. Objetivo del módulo

El cliente tendrá un número de WhatsApp del negocio.

El cliente podrá enviar un mensaje indicando que realizó un pago y posteriormente enviar una fotografía o documento del comprobante bancario.

El sistema debe recibir:

* Número de WhatsApp del cliente
* Nombre del cliente
* Número de referencia de la transferencia
* Monto pagado
* Concepto del pago
* Fecha del pago, si está disponible
* Fotografía del comprobante
* PDF del comprobante, si se permite
* Fecha y hora en que el cliente reportó el pago

El sistema debe registrar toda esta información y colocar el pago en estado **pendiente de revisión**.

Un administrador autenticado dentro del sistema será responsable de revisar el comprobante y decidir si el pago es válido.

---

# 2. Flujo principal esperado

Analiza y diseña este flujo:

```text
CLIENTE
   ↓
WhatsApp
   ↓
Envía datos del pago
   ↓
Envía foto/PDF del comprobante
   ↓
WhatsApp Business API
   ↓
Webhook
   ↓
Backend
   ↓
Procesamiento del mensaje
   ↓
Identificación del cliente
   ↓
Creación del reporte de pago
   ↓
Almacenamiento del comprobante
   ↓
OCR / IA opcional
   ↓
Validaciones automáticas
   ↓
PENDIENTE DE REVISIÓN
   ↓
Administrador autenticado
   ↓
Revisión manual
   ↓
┌───────────────┐
│               │
▼               ▼
APROBAR       RECHAZAR
│               │
▼               ▼
Confirmar      Registrar motivo
pago           del rechazo
│
▼
Enviar respuesta
por WhatsApp
```

Analiza si este flujo es correcto y propone mejoras.

---

# 3. Integración con WhatsApp

Analiza cómo debería realizarse la integración utilizando la plataforma oficial de WhatsApp Business / WhatsApp Cloud API.

Explica:

* Configuración de Meta Developer
* WhatsApp Business Account
* Número de teléfono
* Access Token
* Webhook
* Verificación del webhook
* Recepción de mensajes
* Recepción de imágenes
* Recepción de documentos
* Descarga de archivos multimedia
* Envío de respuestas automáticas
* Manejo de errores
* Reintentos
* Identificación única de cada mensaje
* Idempotencia

Define qué endpoints debería tener el backend.

Ejemplo:

```http
GET /api/webhooks/whatsapp
POST /api/webhooks/whatsapp
```

Pero analiza si son suficientes o si hacen falta otros endpoints.

---

# 4. Conversación de WhatsApp

Diseña una conversación sencilla para que el cliente pueda reportar un pago.

Ejemplo:

```text
Cliente:
Hola, quiero reportar un pago.

Sistema:
Claro. Por favor indique:

Referencia:
Monto:
Nombre:
Concepto:
```

Después:

```text
Cliente:
Referencia: 839201847
Monto: 5500
Nombre: Juan Pérez
Concepto: Factura 00125
```

Sistema:

```text
Información recibida correctamente.

Ahora envíe una foto o PDF del comprobante de pago.
```

Cliente:

```text
[Imagen del comprobante]
```

Sistema:

```text
Su comprobante fue recibido correctamente.

Su pago queda pendiente de verificación.
Le notificaremos cuando sea confirmado.
```

Analiza cómo manejar:

* Datos incompletos
* Datos incorrectos
* Usuario que envía primero la foto
* Usuario que envía primero los datos
* Usuario que manda varios comprobantes
* Usuario que cancela el proceso
* Usuario que inicia nuevamente el proceso
* Mensajes duplicados
* Mensajes fuera de contexto
* Conversaciones abandonadas
* Varios pagos enviados por el mismo número

---

# 5. Modelo de datos

Propón las entidades y tablas necesarias.

Como mínimo analiza:

### WhatsApp

```text
whatsapp_conversations
whatsapp_messages
whatsapp_media
```

### Pagos

```text
payment_reports
payment_receipts
payment_audit_logs
```

### Clientes

Determina si debe relacionarse con una tabla de clientes existente.

Para cada tabla define:

* Nombre
* Campos
* Tipo de dato
* Primary Key
* Foreign Keys
* Índices
* Unique constraints
* Estados
* Relaciones

No programes todavía las migraciones. Primero presenta el diseño.

---

# 6. Estado del pago

Diseña una máquina de estados.

Como punto de partida:

```text
RECEIVED
    ↓
PROCESSING
    ↓
PENDING_REVIEW
    ↓
APPROVED
    ↓
CONFIRMED
```

o:

```text
PENDING_REVIEW
    ↓
┌──────────────┐
│              │
▼              ▼
APPROVED     REJECTED
```

Determina cuáles estados son realmente necesarios.

Explica qué acciones pueden realizarse en cada estado y qué transiciones están permitidas.

---

# 7. OCR e Inteligencia Artificial

Analiza la posibilidad de utilizar OCR o IA para leer automáticamente la fotografía del comprobante.

El sistema podría detectar:

```text
Referencia
Monto
Fecha
Nombre
Beneficiario
Banco
Concepto
```

Ejemplo:

```json
{
  "reference": "839201847",
  "amount": 5500,
  "date": "2026-08-10",
  "name": "Juan Pérez",
  "beneficiary": "Empresa XYZ",
  "concept": "Factura 00125"
}
```

Analiza:

* OCR tradicional
* Visión mediante IA
* Extracción estructurada
* Nivel de confianza
* Validación de datos
* Comparación entre datos enviados por el cliente y datos encontrados en el comprobante

IMPORTANTE:

La IA/OCR **NO debe aprobar automáticamente el pago**.

Debe funcionar como herramienta de asistencia para el administrador.

---

# 8. Validaciones automáticas

Diseña las validaciones que deberían realizarse antes de enviar el pago al administrador.

Por ejemplo:

### Referencia duplicada

```text
¿Esta referencia ya fue utilizada?
```

### Monto

```text
Monto reportado
VS
Monto detectado en comprobante
VS
Monto esperado
```

### Fecha

```text
Fecha del comprobante
VS
fecha permitida
```

### Nombre

```text
Nombre reportado
VS
nombre encontrado
```

### Concepto

```text
Concepto reportado
VS
concepto detectado
```

### Archivo

Verificar:

* Tipo
* Tamaño
* Extensión
* MIME type
* Integridad
* Hash SHA-256

Analiza también otros controles antifraude que consideres importantes.

---

# 9. Detección de comprobantes repetidos

Analiza cómo detectar:

1. Misma referencia
2. Mismo archivo
3. Misma imagen enviada varias veces
4. Mismo monto + fecha + cliente
5. Comprobante reutilizado para otro cliente

Propón mecanismos como:

```text
UNIQUE
SHA-256
Hash perceptual
Reglas de negocio
```

y explica cuáles conviene utilizar.

---

# 10. Panel administrativo

Diseña conceptualmente una pantalla:

```text
Pagos pendientes
```

Debe mostrar como mínimo:

```text
Cliente
WhatsApp
Referencia
Monto
Concepto
Fecha
Estado
Nivel de coincidencia
Fecha de recepción
```

Al abrir un pago:

```text
Información del cliente

Información reportada

Información detectada por OCR/IA

Comprobante

Comparación de datos

Historial

Auditoría
```

Botones:

```text
[ APROBAR PAGO ]
[ RECHAZAR PAGO ]
```

Si se rechaza:

```text
Motivo del rechazo
```

Analiza si deben existir otros roles o permisos.

---

# 11. Seguridad

Analiza todos los aspectos de seguridad necesarios.

Especialmente:

* Autenticación del administrador
* Autorización por roles
* Protección del webhook
* Verificación de firma de Meta
* Validación de archivos
* Control de MIME
* Límite de tamaño
* Protección contra archivos maliciosos
* Protección contra duplicados
* Rate limiting
* Logs
* Auditoría
* Protección de datos personales
* Acceso privado a comprobantes
* URLs temporales para imágenes
* Cifrado cuando sea necesario
* Protección contra acceso directo a archivos

El comprobante bancario contiene información potencialmente sensible, por lo que debe tratarse como información privada.

---

# 12. Auditoría

Todo cambio importante debe quedar registrado.

Ejemplo:

```text
Pago: #4582

Creado:
10/08/2026 16:20

Administrador:
Luis

Acción:
APPROVED

Fecha:
10/08/2026 16:32

Estado anterior:
PENDING_REVIEW

Estado nuevo:
APPROVED
```

Diseña una tabla de auditoría y determina qué eventos deberían registrarse.

---

# 13. Notificaciones

Analiza las respuestas automáticas de WhatsApp.

Cuando se recibe:

```text
Comprobante recibido.
```

Cuando está pendiente:

```text
Su pago está pendiente de verificación.
```

Cuando se aprueba:

```text
Su pago ha sido confirmado correctamente.
```

Cuando se rechaza:

```text
Su pago no pudo ser confirmado.

Motivo:
...
```

También analiza si el administrador debería recibir:

* Notificación dentro del sistema
* Notificación por WhatsApp
* Email
* Push notification

---

# 14. API Backend

Propón los endpoints necesarios.

Por ejemplo:

```http
POST /api/webhooks/whatsapp

GET /api/admin/payment-reports

GET /api/admin/payment-reports/{id}

POST /api/admin/payment-reports/{id}/approve

POST /api/admin/payment-reports/{id}/reject

GET /api/admin/payment-reports/{id}/receipt

GET /api/admin/payment-reports/{id}/audit
```

No asumas que estos son definitivos.

Analiza y propone una estructura REST adecuada.

---

# 15. Almacenamiento de comprobantes

Analiza dónde deberían almacenarse las imágenes y PDFs.

Comparar:

* Servidor local
* VPS
* S3
* Cloud Storage
* Otro almacenamiento privado

El sistema debe evitar almacenar archivos grandes directamente dentro de PostgreSQL.

La base de datos debería almacenar información como:

```text
file_path
file_name
mime_type
file_size
sha256
uploaded_at
```

---

# 16. Idempotencia

Esto es MUY importante.

WhatsApp puede reenviar eventos o el servidor puede procesar nuevamente un webhook.

Diseña un mecanismo para evitar:

```text
Un mismo mensaje
       ↓
crear dos pagos
```

Debe existir una identificación única del mensaje/evento recibido.

---

# 17. Manejo de errores

Analiza qué debe suceder si:

* WhatsApp no responde
* El webhook falla
* La imagen no puede descargarse
* OCR falla
* IA falla
* El archivo es inválido
* PostgreSQL falla
* El administrador intenta aprobar dos veces
* El cliente envía datos incorrectos
* El cliente abandona el proceso

Diseña mecanismos de:

```text
Retry
Queue
Logging
Dead-letter / failed jobs
Idempotencia
```

---

# 18. Arquitectura tecnológica

Considera como base:

```text
Backend:
Laravel / PHP

Database:
PostgreSQL

Frontend:
Sistema administrativo existente

WhatsApp:
WhatsApp Business Cloud API

OCR / IA:
Por definir

Storage:
Por definir

Queue:
Laravel Queue / Redis u otra alternativa
```

Analiza si esta arquitectura es adecuada y qué componentes adicionales serían necesarios.

---

# 19. Escalabilidad

Aunque inicialmente puedan recibirse pocos pagos, analiza cómo diseñar el módulo para soportar posteriormente:

```text
100 pagos diarios
1,000 pagos diarios
10,000 pagos diarios
```

Analiza:

* Webhooks
* Colas
* Procesamiento asíncrono
* OCR
* almacenamiento
* PostgreSQL
* índices
* archivos
* concurrencia

---

# 20. Fraude y seguridad del comprobante

Analiza específicamente qué cosas un administrador debería revisar antes de aprobar.

Por ejemplo:

```text
✓ Referencia
✓ Monto
✓ Fecha
✓ Banco
✓ Beneficiario
✓ Nombre
✓ Concepto
✓ Imagen
✓ Duplicados
✓ Historial del cliente
```

También explica qué cosas **NO puede garantizar un OCR o una IA**.

El sistema debe dejar claro que:

```text
OCR detecta información
IA interpreta información
Administrador confirma el pago
```

No asumir que una fotografía demuestra por sí sola que el dinero realmente llegó al banco.

---

# 21. Resultado esperado de este análisis

Quiero que tu respuesta esté organizada en estas secciones:

1. Resumen de la solución
2. Arquitectura propuesta
3. Flujo completo
4. Flujo conversacional de WhatsApp
5. Integración con WhatsApp Business API
6. Entidades y base de datos
7. Máquina de estados
8. OCR / IA
9. Validaciones
10. Detección de fraude
11. Panel administrativo
12. API
13. Seguridad
14. Auditoría
15. Almacenamiento
16. Colas y procesamiento asíncrono
17. Manejo de errores
18. Escalabilidad
19. Riesgos y limitaciones
20. Recomendaciones
21. Arquitectura final recomendada

Al final incluye un diagrama general de arquitectura en formato Mermaid.

**NO escribas código de implementación todavía.**

Primero quiero entender y validar completamente el diseño.

Después de revisar este análisis, podremos pasar a una segunda etapa donde se definirá la implementación concreta.
