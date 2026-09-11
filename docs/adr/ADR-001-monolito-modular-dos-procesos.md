# ADR-001 · Monolito modular con dos procesos, no microservicios

**Estado:** aceptada
**Fecha:** 29 de agosto de 2026
**Fase:** 0

## Contexto

La plataforma tiene que atender tráfico HTTP (sesión, proyectos, pizarras, IA,
imagen, XMI, generación) y tráfico WebSocket (salas, presencia, persistencia del
documento). Son dos perfiles de carga distintos sobre el mismo dominio.

## Decisión

Un monolito modular orientado al dominio, desplegado como **dos ejecutables**:
`backend/api` y `backend/collab`. Comparten el mismo repositorio, los mismos
paquetes de `shared/` y la misma base de datos.

Arquitectura hexagonal aplicada de forma ligera y **solo** en
`shared/domain-core`, que no depende de React, del documento colaborativo, del
servidor HTTP, de la base de datos ni de ningún proveedor de IA. Fuera de ese
paquete, código directo: nada de convertir cada operación en un puerto con su
adaptador, su fábrica y su mapeador.

## Por qué dos procesos y no uno

Montar HTTP y WebSocket sobre el mismo servidor obliga a resolver una
convivencia que no aporta nada al examen. Además escalan distinto: el proceso de
colaboración mantiene conexiones abiertas y estado de sala; el HTTP atiende
peticiones cortas.

## Por qué no son microservicios

No hay bases de datos separadas, ni contratos versionados entre ellos, ni
despliegue independiente, ni equipos distintos. Es una aplicación modular con dos
ejecutables, y Docker Compose lo oculta detrás de un comando.

Dividir el módulo de proyectos o el de usuarios en servicios propios no
resolvería ningún problema real de este sistema.

## Consecuencias

- Los dos procesos **no guardan estado en memoria propia**: todo va a la base.
  Es lo que permitirá replicarlos más adelante sin rediseñar (sección 14).
- `shared/` no es opcional: es la consecuencia directa de RA-05. El aplicador de
  comandos y el validador se ejecutan en el navegador y en el servidor, con una
  sola implementación.
- El proceso `collab` se construye sobre `node:http` y no sobre un framework,
  porque en la fase 4 el servidor de documentos se engancha al evento `upgrade`
  de esa misma instancia.
- Los primeros candidatos a separar, si algún día hiciera falta, son generación e
  imágenes: consumen tiempo y ya tienen frontera limpia (reciben un snapshot,
  devuelven un artefacto). No se implementa durante el parcial.

## Alternativas descartadas

**Un solo proceso.** Posible, pero obliga a integrar HTTP y WebSocket en el mismo
servidor sin ganancia para el examen.

**Núcleo en Java.** Obligaría a implementar el modelo canónico y el validador dos
veces, y el módulo de IA no podría aplicar comandos directamente sobre el
documento. Descartada.
