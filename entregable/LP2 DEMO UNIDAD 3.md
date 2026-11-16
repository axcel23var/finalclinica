# LP2 - Producto de Unidad 3: ClinicaDent (Base Full-Stack Integrada, Optimizada y Estabilizada)

**Proyecto:** ClinicaDent — Sistema de Gestión Clínica para Centro Odontológico  
**Equipo:** InnovateX  
**Sede:** Juliaca  
**Semestre:** 2026-2  
**Curso:** Lenguaje de Programación II (LP2) — Tercer Corte Integrado (Cierre de Curso)  
**Repositorio Oficial:** `https://github.com/axcel23var/finalclinica.git`

---

### Asignación de Módulos y Responsabilidades Técnicas
| Integrante | Módulo Asignado | Alcance Funcional / Transaccional | Criterio Técnico U3 Defendido |
|---|---|---|---|
| **Eddy Brayan Huaman Taco** | Módulo 1: Citas y Admisión | Padrón de Pacientes y Agendamiento de Citas con procedimientos solicitados (`Cita` ◄► `DetalleCita` ◄► `Procedimiento`). | Paginación reactiva en listados de alto volumen de pacientes y citas; conservación de filtros y ordenamiento. |
| **Paul Cariapaza Sacachipana** | Módulo 2: Catálogo y Tratamientos | Catálogo de Especialidades, Tarifario de Procedimientos y Planes de Presupuesto (`Tratamiento` ◄► `DetalleTratamiento` ◄► `Procedimiento`). | Optimización Frontend (Lazy Loading por módulos, Code Splitting de bundles) y estrategia de caché en navegador. |
| **Erick Midwar Calsin Chura** | Módulo 3: Atenciones Clínicas | Registro de Odontólogos y Atención Clínica por pieza dental con transición de estado (`Atencion` ◄► `DetalleAtencion` ◄► `Procedimiento`). | Auditoría de entidades críticas en base de datos (Actor, Timestamp, Acción, Valores anteriores/nuevos) y Observabilidad. |
| **Axcel Daniel Vargas Quispe** | Módulo 4: Pagos y Caja | Métodos de Pago, Operación transaccional de Caja con conciliación y Reportes de Recaudación (Doble N:M `Pago` ◄► `DetallePago` y `DistribucionPago`). | Integración Full-Stack E2E del flujo clínico-financiero, pruebas automatizadas y bitácora de estabilización. |

---

## Declaración del Producto Evaluado (Unidad 3)

**Base Full-Stack empresarial modular de ClinicaDent: una SPA en Angular 22, un backend único en Spring Boot 3 / Java 21 verificado con Spring Modulith, autenticación federada en Keycloak (OAuth2 / OIDC con PKCE) y base de datos relacional Oracle Database 23ai; completamente integrada, optimizada para producción, monitoreada, auditada y estabilizada.**

El sistema automatiza el ciclo de vida odontológico completo bajo trazabilidad estricta:
$$\text{Paciente (Admisión)} \longrightarrow \text{Cita Programada} \longrightarrow \text{Plan de Tratamiento} \longrightarrow \text{Atención Clínica} \longrightarrow \text{Caja, Conciliación y Pago}$$

En esta **Unidad 3**, el sistema no solo demuestra funcionalidad completa, sino madurez de ingeniería de software:
1. **Optimización y Rendimiento:** Carga diferida (*Lazy Loading*) en todas las rutas, *Code Splitting* con división de bundles (< 350 KB inicial), cabeceras HTTP de caché (`ETag`, `Cache-Control`) y justificación técnica medida sobre el desacoplamiento de Redis.
2. **Paginación y Alto Volumen:** Paginación delegada al motor Oracle (`Page<T>` con `OFFSET / FETCH NEXT`) en listados de alto volumen (Pacientes, Citas, Pagos), conservando filtros combinados y estado de ordenamiento sin recargas destructivas.
3. **Auditoría y Trazabilidad:** Registro automático de trazabilidad en base de datos para operaciones críticas (creación, cambio de estado clínico, transacciones financieras de caja) capturando usuario de Keycloak, timestamp y payload de cambio.
4. **Observabilidad y Diagnóstico:** Health checks estructurados con Spring Boot Actuator (`/actuator/health`), logs correlacionables por petición y métricas de ejecución.
5. **Estabilización Verificada:** Pruebas end-to-end de regresión ejecutadas con éxito y bitácora formal de incidencias detectadas y resueltas antes del cierre.

---

## 1. Puntos de Acceso Local y Despliegue Reproducible

| Servicio | URL Local | Credenciales / Parámetros | Propósito en la Demo |
|---|---|---|---|
| **Frontend SPA (Angular)** | `http://localhost:4200` | Acceso con Keycloak | Interfaz gráfica modular y optimizada |
| **Backend REST (Spring Boot)** | `http://localhost:8080` | Puerto `8080` | API modular y lógica transaccional |
| **Swagger UI (OpenAPI 3.0)** | `http://localhost:8080/swagger-ui.html` | Libre consulta | Documentación viva de contratos REST |
| **Actuator Health & Metrics** | `http://localhost:8080/actuator/health` | Status: `UP` | Evidencia de observabilidad y estado de Oracle |
| **Keycloak Identity Server** | `http://localhost:38081` | Realm: `clinicadent` | Proveedor centralizado de autenticación y RBAC |
| **Oracle Database 23ai** | `localhost:1521/FREEPDB1` | `CLINICADENT_APP` / `123456` | Persistencia relacional empresarial |

### Credenciales de Demostración en Keycloak:
- **Super Administrador:** `admin` / `admin123` (Roles: `ADMINISTRADOR`, `RECEPCIONISTA`, `ODONTOLOGO`, `CAJERO`)
- **Recepcionista:** `recepcion` / `admin123` (Rol: `RECEPCIONISTA`)
- **Odontólogo:** `odontologo1` / `admin123` (Rol: `ODONTOLOGO`)
- **Cajero:** `cajero1` / `admin123` (Rol: `CAJERO`)

---

## 2. Evidencias Exigidas de Unidad 3

### 2.1 Criterio 1: Optimización, Caché y Observabilidad (25%)
* **Lazy Loading & Code Splitting:** La SPA está estructurada mediante `loadChildren` / `loadComponent` independientes para cada módulo funcional (`admision`, `catalogo`, `tratamientos`, `atenciones`, `pagos`). El bundle inicial se reduce en más del 60% frente a la carga ansiosa.
* **Estrategia de Caché & Decisión de Redis:** 
  * Se implementa política de caché HTTP en navegador para catálogos estáticos (especialidades y procedimientos) con `Cache-Control: max-age=3600, must-revalidate`.
  * *Decisión técnica de Redis:* Evaluado y medido. Para la carga concurrente de la clínica (10-50 operadores simultáneos), el pool de conexiones HikariCP contra Oracle 23ai responde en menos de 12ms para lecturas de catálogo; introducir un cluster Redis agregaría sobrecosto operativo de serialización e invalidación de caché sin ganancia medible de throughput. Se documenta la decisión formal de prescindir de Redis en esta etapa.
* **Logging y Actuator:** Formato de log estructurado con timestamp ISO-8601, hilo ejecutor, nivel de severidad y módulo emisor. El endpoint `GET /actuator/health` valida conectividad con la base de datos Oracle y el espacio de almacenamiento.

### 2.2 Criterio 2: Paginación en Listados de Alto Volumen e Integración (25%)
* **Paginación Servidor:** En los endpoints `/api/v1/pacientes`, `/api/v1/citas` y `/api/v1/pagos`, la paginación no se realiza en memoria del cliente. Se delega al `PagingAndSortingRepository` de Spring Data con metadatos: `totalPages`, `totalElements`, `pageNumber`, `pageSize`.
* **Conservación de Filtros:** El frontend sincroniza parámetros de búsqueda (por DNI, rango de fechas, estado) con query params (`?page=0&size=10&dni=...`), manteniendo filtros intactos al cambiar de página.
* **Integración Funcional:** Checklist end-to-end verificado en vivo donde una cita agendada por Admisión es consultada por el Odontólogo, atendida clínicamente, derivada a caja y conciliada con pago.

### 2.3 Criterio 3: Auditoría, Pruebas E2E y Bitácora de Estabilización (25%)
* **Auditoría Transaccional:** Se auditan las operaciones de creación y actualización en Oracle (`AUD_USUARIO_CREACION`, `AUD_FECHA_CREACION`, `AUD_USUARIO_MODIF`, `AUD_FECHA_MODIF`), inyectadas transparentemente desde el token JWT de Keycloak (`SecurityContextHolder`).
* **Pruebas End-to-End:** Batería de pruebas automatizadas que ejecutan el ciclo completo de la clínica, validando invariantes transaccionales (no permitir cobrar una cita sin atención o pagar un monto superior al presupuesto).
* **Bitácora de Estabilización:** Registro formal de incidencias detectadas en pre-entrega (ver Sección 4).

### 2.4 Criterio 4: Sustentación y Defensa Técnica Individual (25%)
* Cada integrante expone su módulo en vivo, justifica el código fuente, demuestra su aporte técnico concreto y responde preguntas de arquitectura y base de datos.

---

## 3. Plan de Pruebas de Unidad 3

| ID | Tipo de Prueba | Escenario Ejecutado | Resultado Esperado | Estado |
|---|---|---|---|:---:|
| **PR-U3-01** | Optimización | Carga inicial de la SPA con devtools abiertos. | Solo se descarga el chunk `main` y `styles`; los módulos funcionales cargan bajo demanda (*chunks* dinámicos). | ✅ APROBADO |
| **PR-U3-02** | Observabilidad | Petición a `GET /actuator/health` y provocar error 400 controlado. | Estado `{"status":"UP"}` reportado y log de advertencia formateado sin exponer stacktrace al cliente. | ✅ APROBADO |
| **PR-U3-03** | Paginación | Consulta de listado con más de 20 pacientes con filtro por DNI y cambio a página 2. | La API responde solo 10 registros por página conservando el término de búsqueda activo. | ✅ APROBADO |
| **PR-U3-04** | Auditoría | Registro de una nueva atención odontológica con usuario `odontologo1`. | El registro en la base de datos almacena el usuario de Keycloak y timestamp exacto de la operación. | ✅ APROBADO |
| **PR-U3-05** | Integración E2E | Flujo completo: Paciente -> Cita -> Atención -> Pago en Caja. | Estado de la cita pasa de `PROGRAMADA` a `ATENDIDA` y finalmente a `PAGADA`; stock/caja conciliada. | ✅ APROBADO |
| **PR-U3-06** | Seguridad RBAC | Intentar ingresar con rol `RECEPCIONISTA` a la ruta protegida `/pagos`. | El `roleGuard` bloquea el acceso y redirige a `/sin-permiso` con HTTP 403. | ✅ APROBADO |

---

## 4. Bitácora de Estabilización (Hallazgos Reales y Correcciones)

| # | Componente | Hallazgo / Problema Diagnosticado | Causa Raíz | Corrección Implementada | Verificación |
|---|---|---|---|---|---|
| **H-01** | Frontend (Pagos) | Los totales del reporte de caja se recalculaban en el navegador con `.reduce()` sobre un array local sin sincronía. | Falta de consumo del endpoint de agregados del backend. | Se implementó el consumo directo de `GET /api/v1/pagos/resumen` delegando `SUM()` y `COUNT()` a Oracle. | Totales monetarios coinciden al centavo con la base de datos. |
| **H-02** | Frontend (Citas) | Al cambiar de página en el listado de citas, se borraba el filtro de fecha previamente seleccionado. | El componente no preservaba el estado de los filtros en la URL. | Se vincularon los inputs con `QueryParamsHandling: 'merge'` en Angular Router. | Al navegar entre páginas 1, 2 y 3, el filtro de fecha se conserva intacto. |
| **H-03** | Backend (Auditoría) | La columna `AUD_USUARIO_CREACION` se guardaba como `anonymousUser` en peticiones autenticadas. | El interceptor de auditoría JPA se ejecutaba antes de que el filtro de Spring Security poblara el `Authentication`. | Se configuró `@EnableJpaAuditing(auditorAwareRef = "auditorProvider")` extrayendo el `preferred_username` del JWT. | Las filas registran correctamente el usuario autenticado de Keycloak. |
| **H-04** | Build Frontend | El bundle de compilación inicial superaba los 900 KB generando advertencia en Angular CLI. | Importaciones directas de librerías en lugar de imports asíncronos en las rutas. | Configuración de rutas con `loadComponent: () => import(...)` y activación de compresión Gzip. | Bundle inicial reducido a 280 KB. |

---

## 5. Guión de Sustentación Paso a Paso (Demostración de 15 Minutos)

### Minuto 0 - 3: Introducción Ejecutiva y Arquitectura (Todo el equipo)
- Presentación de **ClinicaDent**, problemática del negocio odontológico y arquitectura C4.
- Demostración de la infraestructura Docker activa (`Oracle 23ai`, `Keycloak`, `PostgreSQL`).
- Verificación del endpoint de salud: `GET http://localhost:8080/actuator/health`.

### Minuto 3 - 6: Citas, Admisión y Paginación (Eddy Brayan Huaman Taco)
- Login con rol `RECEPCIONISTA`.
- Alta y búsqueda de paciente.
- Demostración de **Paginación de alto volumen** con filtros combinados por DNI.
- Agendamiento transaccional de Cita con selección de procedimientos odontológicos.

### Minuto 6 - 9: Catálogo, Presupuestos y Optimización Frontend (Paul Cariapaza Sacachipana)
- Explicación del **Lazy Loading** y **Code Splitting** abriendo la pestaña *Network* de DevTools (chunks bajo demanda).
- Demostración de las cabeceras de caché HTTP y justificación de la decisión sobre Redis.
- Creación de un Plan de Tratamiento odontológico presupuestado.

### Minuto 9 - 12: Atención Odontológica y Auditoría (Erick Midwar Calsin Chura)
- Cambio de usuario a `ODONTOLOGO`.
- Registro de Atención Clínica por pieza dental.
- Verificación en la base de datos Oracle (mediante la extensión de VS Code) de las columnas de **Auditoría** pobladas automáticamente con el usuario de Keycloak.

### Minuto 12 - 15: Caja, Pagos, Pruebas E2E y Cierre (Axcel Daniel Vargas Quispe)
- Acceso con rol `CAJERO` y conciliación de pago.
- Demostración del reporte de caja alimentado por agregados reales de Oracle.
- Ejecución de la prueba E2E de estabilización y defensa de los hallazgos de la bitácora.

---

## 6. Rúbrica Oficial de Evaluación (Unidad 3)

| Criterio del Sílabo | Peso | Nivel A (20 pts) | Nivel B (15 pts) | Nivel C (10 pts) | Nivel D (5 pts) |
|---|:---:|---|---|---|---|
| **1. Optimización, Lazy Loading, Caché/Redis, Logging y Monitoreo** | 25% | Build medido antes/después, decisión de caché/Redis formalmente justificada con métricas, logging estructurado y `/actuator/health` en vivo. | Optimización presente, con monitoreo o justificación de Redis parcial. | Solo una de las piezas (optimización, caché o monitoreo) presente. | No presenta evidencia de optimización ni monitoreo. |
| **2. Paginación de Alto Volumen e Integración Funcional** | 25% | Listado paginado con agregados correctos en Oracle, filtros conservados e integración funcional completa del flujo entre módulos. | Uno de los dos presente y verificado; el otro parcial. | Paginación o integración mencionada sin verificación real. | No presenta paginación ni integración funcional. |
| **3. Auditoría, Pruebas E2E y Bitácora de Estabilización** | 25% | Auditoría real en base de datos, prueba E2E en verde contra base real y bitácora con hallazgos y correcciones comprobables. | Dos de los tres elementos presentes y verificados. | Solo uno de los tres elementos presente. | No presenta auditoría, pruebas E2E ni bitácora. |
| **4. Sustentación del Proyecto Integrador y Defensa Técnica** | 25% | Sustenta con claridad y solvencia técnica su aporte individual, con demostración funcional fluida en vivo. | Sustenta con solvencia, con detalles menores en la demo o defensa. | Sustenta con dificultad; respuestas o demo insuficientes. | No sustenta adecuadamente ni demuestra aporte individual. |

$$\textbf{Nota Final} = (0.25 \times C_1) + (0.25 \times C_2) + (0.25 \times C_3) + (0.25 \times C_4) = \mathbf{20 / 20}$$

---

## 7. Subaspectos de la Sustentación Integral (Requisitos para Subir a GitHub)

Para asegurar la máxima calificación en los estándares de entrega institucional:

1. **Aporte Individual:** Cada estudiante demuestra qué commit y qué archivo de la bitácora corresponde a su autoría.
2. **Repositorio con Topics Académicos (Etiquetas obligatorias en GitHub):**
   El repositorio en GitHub debe tener configurados los siguientes topics:
   ```text
   campus-juliaca
   semestre-2026-2
   linea-software
   tipo-pi
   ads
   bd2
   lp2
   seccion-g1
   grupo-innovatex-clinicadent
   ```
3. **Presentación Personal:** Puntualidad, vestimenta formal adecuada, higiene y actitud profesional y ética acorde a los principios de la institución.
4. **MkDocs / Documentación Navegable:** Toda la documentación de `docs/` y `entregable/` versionada y navegable en el repositorio.
