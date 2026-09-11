# Arquitectura

El detalle vive en la sección 4 del [plan maestro](../referencia/plan-integral-plataforma-uml.md).
Aquí solo queda lo que un integrante necesita tener presente al escribir código.

## Principio rector

Todas las entradas modifican un **único modelo UML canónico** mediante lotes de
comandos atómicos. Colaboración, IA, imagen, XMI y generación son adaptadores
alrededor de ese núcleo.

Si esa pieza está bien hecha, las seis funcionalidades se conectan al mismo
centro. Si está mal hecha, habrá seis implementaciones peleándose por ser la
verdad.

## Flujo de una modificación

```
GUI · texto · voz · imagen · XMI
              ↓
     Propuesta de lote
              ↓
     Resolución estructural (desambiguación)
              ↓
         Validación            ← si hay un solo error, no se aplica nada
              ↓
    Aplicador de comandos
              ↓
  Documento colaborativo (transacción única)
              ↓
   ┌──────────┴──────────┐
   ↓                     ↓
Actualización        Snapshot inmutable
incremental                ↓
a los demás         Representación intermedia
                           ↓
                    Plantillas → ZIP
```

## Restricciones que no se negocian

Las quince restricciones arquitectónicas están en la sección 4.8 del plan
maestro. Las que más se olvidan al escribir código:

- **RA-03** — Lotes transaccionales: todo o nada. La validación ocurre **antes**
  de aplicar; la transacción del documento agrupa el cambio para que produzca una
  sola actualización, no como mecanismo de deshacer.
- **RA-04** — Identidad UUID interna independiente del nombre. Renombrar nunca
  rompe una relación.
- **RA-05** — Aplicador y validador: una implementación, dos lugares de ejecución.
- **RA-06** — El asistente dispone de vocabulario cerrado. Nunca mutación
  arbitraria.
- **RA-07** — Generación determinista por plantillas. Ningún modelo de lenguaje
  escribe Java.
- **RA-08** — La generación opera sobre snapshot inmutable, no sobre estado vivo.
- **RA-11** — El documento colaborativo se persiste en su representación binaria
  nativa. El JSON canónico es proyección derivada y **nunca** reconstruye el
  documento.
- **RA-12** — La colaboración garantiza convergencia estructural, no validez
  semántica. Dos usuarios pueden converger en un modelo inválido; el validador lo
  marca antes de permitir generar.
- **RA-15** — Toda conexión al servidor de colaboración se autentica y autoriza
  antes de unirse a una sala. Proteger solo las rutas HTTP no sirve de nada.

## Fuentes de verdad

| Representación | Responsabilidad |
|---|---|
| Esquema canónico | Contrato semántico: qué significa el estado |
| Documento colaborativo | Estado vivo replicado |
| Layout | Posición y viewport, sin valor semántico |
| PostgreSQL | Persistencia durable y metadatos |
| Snapshot de generación | Entrada inmutable al generador |
| Representación intermedia | Traducción temporal para emitir código |

El editor visual siempre es una **proyección** del documento, nunca la fuente de
verdad.

## Despliegue

```
                    Navegador
              React + editor + documento
                        │
              ┌─────────┴─────────┐
            HTTPS               WSS
              ↓                   ↓
         ┌──────────┐      ┌─────────────┐
         │   api    │      │   collab    │
         │ :3001    │      │ :3002       │
         └────┬─────┘      └──────┬──────┘
              └──────────┬────────┘
                         ↓
                    PostgreSQL
```

Con el perfil `demo`, Caddy queda delante y expone un único origen en el puerto
80: `/api/*` al proceso HTTP, `/collab/*` al de colaboración, el resto a la
interfaz.
