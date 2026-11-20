# FORMATO DE INFORME FINAL DEL PROYECTO DE BASE DE DATOS II

**Implementación y administración de base de datos utilizando Oracle Database**

---

## PORTADA

- Nombre de la institución.
- Nombre del programa de estudios o carrera profesional.
- Asignatura: Administración de Base de datos 2.
- Título del proyecto.
- Integrantes del equipo.
- Docente responsable.
- Ciclo o semestre académico.
- Lugar y fecha.

---

## I. RESUMEN EJECUTIVO

Describir brevemente el proyecto de sistema de información desarrollado, indicando el problema que busca solucionar, el objetivo del sistema, los principales módulos implementados y las tecnologías utilizadas.

Asimismo, mencionar la utilización de Oracle Database como gestor de base de datos y los principales componentes desarrollados durante el proyecto.

---

## II. PLANTEAMIENTO DEL PROYECTO

### 2.1. Descripción del problema
Identificar y describir la problemática que se busca solucionar mediante el desarrollo del sistema de información.

### 2.2. Justificación
Explicar la importancia de implementar el sistema y los beneficios que proporcionará a sus usuarios.

### 2.3. Objetivos

**Objetivo general:**
- Desarrollar e implementar un sistema de información que permita gestionar y administrar eficientemente la información de [indicar el área o proceso].

**Objetivos específicos:**
- Diseñar el modelo relacional de la base de datos.
- Implementar la base de datos utilizando Oracle Database.
- Desarrollar procedimientos y funcionalidades mediante PL/SQL.
- Implementar estructuras de almacenamiento mediante TABLESPACES y DATAFILES.
- Aplicar particionamiento de tablas cuando corresponda.
- Realizar procesos de exportación e importación de información.

### 2.4. Alcance del sistema
Describir los procesos, módulos y funcionalidades que contempla el sistema desarrollado.

---

## III. ANÁLISIS Y DISEÑO DEL SISTEMA DE INFORMACIÓN

### 3.1. Descripción del sistema
Explicar cómo funciona el sistema, quiénes son sus usuarios y qué procesos permite gestionar.

### 3.2. Modelo relacional
Presentar el modelo relacional, identificando:
- Tablas.
- Campos y tipos de datos.
- Claves primarias.
- Claves foráneas.
- Relaciones entre tablas.
- Restricciones de integridad.

> **Evidencia obligatoria:** incluir el diagrama del modelo relacional y explicar su estructura.

---

## IV. IMPLEMENTACIÓN DE LA BASE DE DATOS EN ORACLE

### 4.1. Creación de la base de datos
Describir el entorno Oracle utilizado y presentar la estructura implementada.

### 4.2. Creación de tablas
Presentar los scripts SQL utilizados para crear las tablas principales del proyecto.

### 4.3. Inserción y gestión de información
Mostrar ejemplos de inserción, actualización, eliminación y consulta de registros.

### 4.4. Evidencias
Incluir capturas de pantalla que demuestren la creación de tablas y la ejecución de consultas.

---

## V. DESARROLLO DE PROGRAMACIÓN PL/SQL

Explicar cómo se utilizó PL/SQL para implementar funcionalidades del sistema.

### 5.1. Bloques PL/SQL
Presentar ejemplos de bloques PL/SQL desarrollados.

### 5.2. Procedimientos almacenados
Describir los procedimientos implementados y su finalidad.

### 5.3. Funciones
Presentar las funciones desarrolladas para realizar operaciones específicas.

### 5.4. Cursores y estructuras de control
Mostrar ejemplos de utilización, cuando corresponda.

### 5.5. Triggers
Describir los disparadores implementados y los eventos que controlan, cuando corresponda.

> **Evidencia obligatoria:** presentar scripts y capturas de ejecución de los componentes PL/SQL desarrollados.

---

## VI. ADMINISTRACIÓN DE TABLESPACES Y DATAFILES

### 6.1. Creación de TABLESPACES
Describir los espacios lógicos de almacenamiento creados para el proyecto.

### 6.2. Administración de DATAFILES
Identificar los archivos físicos asociados a los TABLESPACES.

### 6.3. Asignación de almacenamiento
Explicar cómo se organizaron los objetos de la base de datos dentro de los espacios de almacenamiento.

### 6.4. Evidencias
Presentar los comandos utilizados y capturas de pantalla de la configuración implementada.

---

## VII. PARTICIONAMIENTO DE TABLAS

### 7.1. Descripción del particionamiento
Explicar qué tabla del proyecto fue seleccionada para implementar particiones y por qué.

### 7.2. Tipo de particionamiento utilizado
Identificar el tipo implementado:
- `RANGE`.
- `LIST`.
- `HASH`.
- `COMPOSITE`.

### 7.3. Implementación
Presentar el script SQL utilizado para crear la tabla particionada.

### 7.4. Resultados
Explicar cómo se distribuyen los registros y qué beneficios aporta esta implementación al proyecto.

> **Evidencia obligatoria:** presentar el script y capturas de la estructura de particiones.

---

## VIII. EXPORTACIÓN E IMPORTACIÓN DE INFORMACIÓN

### 8.1. Exportación de información
Describir el procedimiento realizado para exportar la información de la base de datos mediante Oracle Data Pump (`EXPDP`).

### 8.2. Importación de información
Describir el procedimiento utilizado para importar los datos mediante Oracle Data Pump (`IMPDP`).

### 8.3. Archivos generados
Identificar los archivos de exportación generados y su ubicación.

### 8.4. Verificación de resultados
Demostrar que la información exportada pudo ser importada correctamente y que los objetos y registros se encuentran disponibles.

> **Evidencia obligatoria:** incluir comandos ejecutados, capturas de pantalla y resultados de la importación.

---

## IX. CONCLUSIONES

Presentar conclusiones relacionadas con:
- El diseño e implementación del modelo relacional.
- La utilización de PL/SQL.
- La administración de TABLESPACES y DATAFILES.
- El uso de particiones.
- Los procesos de exportación e importación.
- El aporte del sistema de información desarrollado.

---

## X. RECOMENDACIONES

Plantear recomendaciones para mejorar el sistema, optimizar la base de datos y garantizar la seguridad, disponibilidad e integridad de la información.

---

## XI. REFERENCIAS BIBLIOGRÁFICAS

Incluir documentación técnica de Oracle, libros, manuales y otras fuentes utilizadas durante el desarrollo del proyecto.
