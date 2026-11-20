# Chuleta en Vivo BD2 — Códigos Listos para Copiar, Pegar y Sustentar

Guía de emergencia para el examen/sustentación en vivo con el **Ing. Eder Gutiérrez Quispe**.  
Todo está probado sobre tus conexiones **`ClinicaDent_SYS`** y **`ClinicaDent_BD2`**.

---

## PARTE 1: Cómo explicar y probar LO QUE YA TIENES creado

### 1.1. Mostrar el Procedimiento (`REGISTRAR_CITA_BD2`)
* **Dónde:** **`ClinicaDent_BD2`** (`F5`)
* **Qué dices:** *"Este procedimiento recibe el ID del paciente y la fecha (`IN`), valida que el paciente exista en `PACIENTES` (si no existe, lanza error `-20001` con `NO_DATA_FOUND`), registra la cita en estado `PROGRAMADA` y nos devuelve el ID creado por parámetro `OUT`."*
* **Código para probarlo en vivo:**
```sql
SET SERVEROUTPUT ON;
DECLARE
    v_id_cita NUMBER;
BEGIN
    REGISTRAR_CITA_BD2(1, LOCALTIMESTAMP + INTERVAL '2' DAY, v_id_cita);
    DBMS_OUTPUT.PUT_LINE('Nueva cita creada con ID: ' || v_id_cita);
    ROLLBACK; -- para no dejar basura de prueba (o COMMIT si quieres guardarla)
END;
/
```
*(Si el profe pide ver que falla cuando el paciente no existe, cambia el `1` por `9999` y salta `ORA-20001: El paciente indicado no existe`).*

---

### 1.2. Mostrar la Función (`CONTAR_CITAS_BD2`)
* **Dónde:** **`ClinicaDent_BD2`** (`Ctrl + Enter`)
* **Qué dices:** *"A diferencia del procedimiento, la función siempre retorna un solo valor (`RETURN`) y por eso la podemos llamar directo dentro de un `SELECT`. Recibe el ID del paciente y cuenta cuántas citas tiene en `CITAS`."*
* **Código para probarlo en vivo:**
```sql
SELECT ID, DNI, NOMBRES, APELLIDOS,
       CONTAR_CITAS_BD2(ID) AS CANTIDAD_CITAS
FROM PACIENTES;
```

---

### 1.3. Mostrar el Cursor (`c_citas_bd2`)
* **Dónde:** **`ClinicaDent_BD2`** (`F5`)
* **Qué dices:** *"Cuando una consulta devuelve varias filas, Oracle usa un cursor para leerla fila por fila (`OPEN`, `FETCH` en bucle `LOOP`, sale con `%NOTFOUND` y cierra con `CLOSE`). Este cursor une `CITAS` con `PACIENTES`."*
* **Código para probarlo en vivo:**
```sql
SET SERVEROUTPUT ON;
DECLARE
    CURSOR c_citas_bd2 IS
        SELECT c.ID, p.NOMBRES || ' ' || p.APELLIDOS AS PACIENTE, c.ESTADO
        FROM CITAS c
        INNER JOIN PACIENTES p ON p.ID = c.ID_PACIENTE
        ORDER BY c.ID;
    v_reg c_citas_bd2%ROWTYPE;
BEGIN
    OPEN c_citas_bd2;
    LOOP
        FETCH c_citas_bd2 INTO v_reg;
        EXIT WHEN c_citas_bd2%NOTFOUND;
        DBMS_OUTPUT.PUT_LINE('Cita #' || v_reg.ID || ' | ' || v_reg.PACIENTE || ' | ' || v_reg.ESTADO);
    END LOOP;
    CLOSE c_citas_bd2;
END;
/
```

---

### 1.4. Mostrar el Trigger (`TRG_AUDITAR_CITA_BD2`)
* **Dónde:** **`ClinicaDent_BD2`** (`F5`)
* **Qué dices:** *"Es un disparador `AFTER INSERT ON CITAS FOR EACH ROW`: se ejecuta automáticamente cada vez que entra una cita nueva (desde SQL o desde la web) e inserta la huella en `AUDITORIA_EVENTOS` capturando al usuario de sesión y `:NEW.ID` / `:NEW.ESTADO`."*
* **Código para probarlo en vivo:**
```sql
INSERT INTO CITAS (ID_PACIENTE, FECHA_HORA, ESTADO)
VALUES (1, LOCALTIMESTAMP, 'PROGRAMADA');

SELECT ACCION, ACTOR, RECURSO, RECURSO_ID, DETALLE
FROM AUDITORIA_EVENTOS
ORDER BY ID DESC;

ROLLBACK; -- vuelve atrás la prueba si no quieres guardarla
```

---

### 1.5. Mostrar Tablespace, Datafile, Particiones y Data Pump que ya tienes
* **Ver Tablespace y Datafile (`ClinicaDent_SYS`, `Ctrl + Enter`):**
```sql
SELECT TABLESPACE_NAME, FILE_NAME, ROUND(BYTES/1024/1024, 2) AS MB, AUTOEXTENSIBLE
FROM DBA_DATA_FILES
WHERE TABLESPACE_NAME = 'TS_CLINICADENT_BD2';
```
* **Ver Particiones y EXPLAIN PLAN (`ClinicaDent_BD2`, `F5`):**
```sql
SELECT PARTITION_NAME, TABLESPACE_NAME, NUM_ROWS
FROM USER_TAB_PARTITIONS WHERE TABLE_NAME = 'TRATAMIENTOS_HIST_BD2';

EXPLAIN PLAN FOR
SELECT * FROM TRATAMIENTOS_HIST_BD2
WHERE FECHA_CREACION >= TIMESTAMP '2027-01-01 00:00:00'
  AND FECHA_CREACION <  TIMESTAMP '2028-01-01 00:00:00';
SELECT * FROM TABLE(DBMS_XPLAN.DISPLAY);
```
* **Ver recuperación de Data Pump (`ClinicaDent_BD2`, `Ctrl + Enter`):**
```sql
SELECT 'ORIGINAL' AS ORIGEN, ID, DNI, NOMBRES FROM PACIENTES WHERE DNI = 'BD2-DP-01'
UNION ALL
SELECT 'IMPORTADO' AS ORIGEN, ID, DNI, NOMBRES FROM PACIENTES_RECUP_BD2 WHERE DNI = 'BD2-DP-01';
```

---
---

## PARTE 2: Si el profe te dice en vivo *"A ver, agrega uno nuevo ahorita"*

### 2.1. "Agrega un DATAFILE más a tu tablespace"
* **Dónde:** **`ClinicaDent_SYS`** (`F5`)
```sql
ALTER TABLESPACE TS_CLINICADENT_BD2
ADD DATAFILE '/opt/oracle/oradata/FREE/FREEPDB1/clinicadent_bd2_02.dbf'
SIZE 10M AUTOEXTEND ON NEXT 5M MAXSIZE 50M;

-- Verificar que ya aparecen 2 datafiles:
SELECT FILE_NAME, TABLESPACE_NAME, ROUND(BYTES/1024/1024, 2) AS MB, AUTOEXTENSIBLE
FROM DBA_DATA_FILES
WHERE TABLESPACE_NAME = 'TS_CLINICADENT_BD2';
```

---

### 2.2. "Crea un NUEVO TABLESPACE (con su datafile y cuota)"
* **Dónde:** **`ClinicaDent_SYS`** (`F5`)
```sql
CREATE TABLESPACE TS_CLINICA_EXTRA
DATAFILE '/opt/oracle/oradata/FREE/FREEPDB1/clinica_extra_01.dbf'
SIZE 10M AUTOEXTEND ON NEXT 5M MAXSIZE 50M;

ALTER USER CLINICADENT_BD2 QUOTA UNLIMITED ON TS_CLINICA_EXTRA;

-- Verificar:
SELECT FILE_NAME, TABLESPACE_NAME, ROUND(BYTES/1024/1024, 2) AS MB
FROM DBA_DATA_FILES
WHERE TABLESPACE_NAME = 'TS_CLINICA_EXTRA';
```

---

### 2.3. "Agrega un NUEVO TRIGGER" (ej. impedir pagos con monto <= 0)
* **Dónde:** **`ClinicaDent_BD2`** (`F5`)
```sql
CREATE OR REPLACE TRIGGER TRG_VALIDAR_PAGO_BD2
BEFORE INSERT OR UPDATE ON PAGOS
FOR EACH ROW
BEGIN
    IF :NEW.MONTO_TOTAL <= 0 THEN
        RAISE_APPLICATION_ERROR(-20002, 'Error BD: El monto del pago debe ser mayor a 0.');
    END IF;
END;
/

-- Probar que el trigger bloquea montos negativos (debe salir ORA-20002):
INSERT INTO PAGOS (FECHA_PAGO, ID_TRATAMIENTO, MONTO_TOTAL)
VALUES (SYSTIMESTAMP, 1, -50);
```

---

### 2.4. "Agrega una NUEVA FUNCIÓN" (ej. total abonado a un tratamiento)
* **Dónde:** **`ClinicaDent_BD2`** (`F5`)
```sql
CREATE OR REPLACE FUNCTION FN_TOTAL_PAGADO_BD2 (
    p_id_tratamiento IN NUMBER
) RETURN NUMBER AS
    v_total NUMBER(10,2) := 0;
BEGIN
    SELECT NVL(SUM(MONTO_APLICADO), 0)
    INTO v_total
    FROM DISTRIBUCION_PAGOS
    WHERE ID_TRATAMIENTO = p_id_tratamiento;
    RETURN v_total;
END;
/

-- Probar en SELECT:
SELECT FN_TOTAL_PAGADO_BD2(1) AS TOTAL_ABONADO FROM DUAL;
```

---

### 2.5. "Agrega un NUEVO PROCEDIMIENTO" (ej. actualizar teléfono de paciente por DNI)
* **Dónde:** **`ClinicaDent_BD2`** (`F5`)
```sql
SET SERVEROUTPUT ON;
CREATE OR REPLACE PROCEDURE SP_ACTUALIZAR_TEL_BD2 (
    p_dni      IN PACIENTES.DNI%TYPE,
    p_telefono IN PACIENTES.TELEFONO%TYPE
) AS
BEGIN
    UPDATE PACIENTES
    SET TELEFONO = p_telefono
    WHERE DNI = p_dni;

    IF SQL%ROWCOUNT = 0 THEN
        RAISE_APPLICATION_ERROR(-20003, 'No existe paciente con DNI ' || p_dni);
    END IF;
    DBMS_OUTPUT.PUT_LINE('Telefono actualizado para DNI ' || p_dni);
END;
/

-- Probar:
BEGIN
    SP_ACTUALIZAR_TEL_BD2('BD2-DP-01', '987654321');
    ROLLBACK;
END;
/
```

---

### 2.6. "Agrega un NUEVO CURSOR" (ej. listar todos los pacientes)
* **Dónde:** **`ClinicaDent_BD2`** (`F5`)
```sql
SET SERVEROUTPUT ON;
DECLARE
    CURSOR c_pacientes_bd2 IS
        SELECT ID, DNI, NOMBRES || ' ' || APELLIDOS AS NOMBRE_COMPLETO, TELEFONO
        FROM PACIENTES
        ORDER BY ID;
    v_pac c_pacientes_bd2%ROWTYPE;
BEGIN
    OPEN c_pacientes_bd2;
    LOOP
        FETCH c_pacientes_bd2 INTO v_pac;
        EXIT WHEN c_pacientes_bd2%NOTFOUND;
        DBMS_OUTPUT.PUT_LINE('ID ' || v_pac.ID || ' | DNI: ' || v_pac.DNI || ' | ' || v_pac.NOMBRE_COMPLETO);
    END LOOP;
    CLOSE c_pacientes_bd2;
END;
/
```

---

### 2.7. "Agrega otra PARTICIÓN o una tabla particionada nueva"
*(En `TRATAMIENTOS_HIST_BD2`, como la última partición es `MAXVALUE`, se usa `SPLIT PARTITION`; o puedes crear una tabla nueva particionada por `LIST`):*
* **Dónde:** **`ClinicaDent_BD2`** (`F5`)

**Opción A — Dividir la partición `P_DESDE_2028` para agregar `P_2028`:**
```sql
ALTER TABLE TRATAMIENTOS_HIST_BD2
SPLIT PARTITION P_DESDE_2028 AT (TIMESTAMP '2029-01-01 00:00:00')
INTO (
    PARTITION P_2028       TABLESPACE TS_CLINICADENT_BD2,
    PARTITION P_DESDE_2029 TABLESPACE TS_CLINICADENT_BD2
);

SELECT PARTITION_NAME, TABLESPACE_NAME FROM USER_TAB_PARTITIONS WHERE TABLE_NAME = 'TRATAMIENTOS_HIST_BD2';
```

**Opción B — Crear una tabla nueva particionada por `LIST` (por estado de pago):**
```sql
CREATE TABLE PAGOS_LIST_DEMO (
    ID          NUMBER GENERATED BY DEFAULT AS IDENTITY PRIMARY KEY,
    MONTO_TOTAL NUMBER(10,2) NOT NULL,
    ESTADO      VARCHAR2(20 CHAR) NOT NULL
)
PARTITION BY LIST (ESTADO) (
    PARTITION P_PAGADO    VALUES ('PAGADO')    TABLESPACE TS_CLINICADENT_BD2,
    PARTITION P_PENDIENTE VALUES ('PENDIENTE') TABLESPACE TS_CLINICADENT_BD2,
    PARTITION P_ANULADO   VALUES ('ANULADO')   TABLESPACE TS_CLINICADENT_BD2
);

INSERT INTO PAGOS_LIST_DEMO (MONTO_TOTAL, ESTADO) VALUES (120.00, 'PAGADO');
INSERT INTO PAGOS_LIST_DEMO (MONTO_TOTAL, ESTADO) VALUES (80.00,  'PENDIENTE');
COMMIT;

SELECT PARTITION_NAME, TABLESPACE_NAME FROM USER_TAB_PARTITIONS WHERE TABLE_NAME = 'PAGOS_LIST_DEMO';
```
