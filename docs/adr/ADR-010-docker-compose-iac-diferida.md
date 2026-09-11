# ADR-010 · Docker Compose, infraestructura como código diferida

**Estado:** aceptada
**Fecha:** 29 de agosto de 2026
**Fase:** 0

## Contexto

RNF-12 exige que la plataforma se levante completa con un solo comando. La
sección 13 pide además poder apagar o reiniciar piezas individuales sin tocar el
resto.

## Decisión

Docker Compose desde el primer día, con perfiles. Infraestructura como código
(Terraform u OpenTofu) queda **después del parcial**.

### Servicios y perfiles

| Servicio | Perfil | Por qué |
|---|---|---|
| `db` | por defecto | PostgreSQL de la plataforma |
| `api` | por defecto | Proceso HTTP |
| `collab` | por defecto | Proceso WebSocket |
| `web` | por defecto | Interfaz React |
| `proxy` | `demo` | Origen único para la demostración |
| `adminer` | `tools` | Inspección de la base |

Los perfiles hacen que `proxy` y `adminer` no arranquen salvo que se pidan. El
entorno diario queda liviano y el de demostración se enciende cuando hace falta.

### Reglas aplicadas en `infra/compose.yml`

- Cada servicio declara comprobación de salud y quien depende de él la espera.
  Evita el error clásico del servidor que arranca antes que la base.
- Los datos viven en volúmenes con nombre. Solo `down -v` los borra.
- Toda la configuración entra por variables de entorno, con `infra/.env.example`
  versionado y `infra/.env` ignorado.
- Ningún secreto queda escrito en la composición.
- Con el perfil `demo`, el navegador habla con un solo origen: desaparecen los
  problemas de origen cruzado y las otras computadoras del aula llegan a una
  dirección en lugar de tres puertos.

## Por qué no infraestructura como código ahora

El retorno es negativo a tres semanas de la entrega. El problema a resolver es
modelado UML colaborativo, no aprovisionamiento de redes y DNS. Docker sí reduce
riesgo real el día de la defensa; Terraform no reduce ninguno.

## Consecuencia para el artefacto generado

El backend generado trae **su propia** composición dentro del ZIP, independiente
de la plataforma. Es la salvaguarda del día de la defensa: si la máquina donde se
abre el proyecto no tiene PostgreSQL, o tiene otra versión, o el puerto ocupado,
la composición lo resuelve. Se implementa en la fase 6 (RF-071).
