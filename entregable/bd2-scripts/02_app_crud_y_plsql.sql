-- ============================================================================
-- BLOQUE 2: CRUD SQL Y PROGRAMACIÓN PL/SQL INTEGRAL (LOS 4 MÓDULOS DE CLINICADENT)
-- DÓNDE EJECUTAR: Conexión ClinicaDent_APP (Usuario: CLINICADENT_APP | FREEPDB1)
-- ============================================================================

SET SERVEROUTPUT ON;

-- ----------------------------------------------------------------------------
-- SECCIÓN 4.3: INSERCIÓN, CONSULTA, ACTUALIZACIÓN Y ELIMINACIÓN (CRUD SQL)
-- Ejemplo sobre PACIENTES (Módulo Admisión)
-- ----------------------------------------------------------------------------

-- INSERT
INSERT INTO PACIENTES (DNI, NOMBRES, APELLIDOS, TELEFONO)
VALUES ('99887766', 'Lucia Prueba', 'Quispe Mamani', '951000111');
COMMIT;

-- SELECT
SELECT ID, DNI, NOMBRES, APELLIDOS, TELEFONO
FROM PACIENTES
WHERE DNI = '99887766';

-- UPDATE
UPDATE PACIENTES
SET TELEFONO = '951999888'
WHERE DNI = '99887766';
COMMIT;

-- DELETE
DELETE FROM PACIENTES
WHERE DNI = '99887766';
COMMIT;


-- ----------------------------------------------------------------------------
-- SECCIÓN 5.1: BLOQUE ANÓNIMO PL/SQL (Resumen de los 4 módulos de la clínica)
-- ----------------------------------------------------------------------------
DECLARE
    v_pacientes     NUMBER := 0;
    v_citas         NUMBER := 0;
    v_atenciones    NUMBER := 0;
    v_tratamientos  NUMBER := 0;
    v_recaudado     NUMBER(10,2) := 0;
BEGIN
    SELECT COUNT(*) INTO v_pacientes FROM PACIENTES;
    SELECT COUNT(*) INTO v_citas FROM CITAS;
    SELECT COUNT(*) INTO v_atenciones FROM ATENCIONES;
    SELECT COUNT(*) INTO v_tratamientos FROM TRATAMIENTOS WHERE SALDO_PENDIENTE > 0;
    SELECT NVL(SUM(MONTO_TOTAL), 0) INTO v_recaudado FROM PAGOS;

    DBMS_OUTPUT.PUT_LINE('=== RESUMEN GLOBAL CLINICADENT (4 MODULOS) ===');
    DBMS_OUTPUT.PUT_LINE('1. Pacientes registrados      : ' || v_pacientes);
    DBMS_OUTPUT.PUT_LINE('2. Citas totales              : ' || v_citas);
    DBMS_OUTPUT.PUT_LINE('3. Atenciones realizadas      : ' || v_atenciones);
    DBMS_OUTPUT.PUT_LINE('4. Planes con saldo pendiente : ' || v_tratamientos);
    DBMS_OUTPUT.PUT_LINE('5. Total recaudado en caja S/ : ' || v_recaudado);
EXCEPTION
    WHEN OTHERS THEN
        DBMS_OUTPUT.PUT_LINE('Error en resumen global: ' || SQLERRM);
END;
/


-- ----------------------------------------------------------------------------
-- SECCIÓN 5.2: PROCEDIMIENTOS ALMACENADOS (SP_)
-- ----------------------------------------------------------------------------

-- Procedimiento 1 (Módulo Citas): Cambiar estado de una cita validando existencia
CREATE OR REPLACE PROCEDURE SP_ACTUALIZAR_ESTADO_CITA (
    p_id_cita      IN CITAS.ID%TYPE,
    p_nuevo_estado IN CITAS.ESTADO%TYPE
) IS
    v_estado_actual CITAS.ESTADO%TYPE;
BEGIN
    SELECT ESTADO INTO v_estado_actual
    FROM CITAS
    WHERE ID = p_id_cita;

    IF v_estado_actual = 'CANCELADA' THEN
        RAISE_APPLICATION_ERROR(-20001, 'No se puede modificar una cita ya CANCELADA.');
    END IF;

    UPDATE CITAS
    SET ESTADO = UPPER(p_nuevo_estado)
    WHERE ID = p_id_cita;
    COMMIT;

    DBMS_OUTPUT.PUT_LINE('Cita #' || p_id_cita || ' actualizada de ' || v_estado_actual || ' a ' || UPPER(p_nuevo_estado));
EXCEPTION
    WHEN NO_DATA_FOUND THEN
        RAISE_APPLICATION_ERROR(-20002, 'No existe la cita con ID ' || p_id_cita);
END;
/

-- Procedimiento 2 (Módulo Tratamientos): Consultar resumen financiero de un plan
CREATE OR REPLACE PROCEDURE SP_RESUMEN_TRATAMIENTO (
    p_id_tratamiento  IN  TRATAMIENTOS.ID%TYPE,
    p_costo_total     OUT TRATAMIENTOS.COSTO_TOTAL%TYPE,
    p_saldo_pendiente OUT TRATAMIENTOS.SALDO_PENDIENTE%TYPE,
    p_estado          OUT TRATAMIENTOS.ESTADO%TYPE
) IS
BEGIN
    SELECT COSTO_TOTAL, SALDO_PENDIENTE, ESTADO
    INTO p_costo_total, p_saldo_pendiente, p_estado
    FROM TRATAMIENTOS
    WHERE ID = p_id_tratamiento;

    DBMS_OUTPUT.PUT_LINE('Tratamiento #' || p_id_tratamiento || ' | Estado: ' || p_estado ||
                         ' | Costo: S/ ' || p_costo_total || ' | Saldo: S/ ' || p_saldo_pendiente);
EXCEPTION
    WHEN NO_DATA_FOUND THEN
        RAISE_APPLICATION_ERROR(-20003, 'No existe el tratamiento con ID ' || p_id_tratamiento);
END;
/

-- Prueba del procedimiento (no falla si aun no hay datos)
DECLARE
    v_costo  NUMBER(10,2);
    v_saldo  NUMBER(10,2);
    v_estado VARCHAR2(20);
BEGIN
    SP_RESUMEN_TRATAMIENTO(1, v_costo, v_saldo, v_estado);
EXCEPTION
    WHEN OTHERS THEN
        DBMS_OUTPUT.PUT_LINE('Aviso prueba SP: ' || SQLERRM);
END;
/


-- ----------------------------------------------------------------------------
-- SECCIÓN 5.3: FUNCIONES ALMACENADAS (FN_)
-- ----------------------------------------------------------------------------

-- Función 1 (Módulo Citas/Admisión): Contar cuántas citas tiene un paciente
CREATE OR REPLACE FUNCTION FN_CONTAR_CITAS_PACIENTE (
    p_id_paciente IN NUMBER
) RETURN NUMBER IS
    v_cantidad NUMBER := 0;
BEGIN
    SELECT COUNT(*)
    INTO v_cantidad
    FROM CITAS
    WHERE ID_PACIENTE = p_id_paciente;

    RETURN v_cantidad;
END;
/

-- Función 2 (Módulo Pagos): Calcular total abonado a un tratamiento
CREATE OR REPLACE FUNCTION FN_TOTAL_PAGADO_TRATAMIENTO (
    p_id_tratamiento IN NUMBER
) RETURN NUMBER IS
    v_total_abonado NUMBER(10,2) := 0;
BEGIN
    SELECT NVL(SUM(MONTO_APLICADO), 0)
    INTO v_total_abonado
    FROM DISTRIBUCION_PAGOS
    WHERE ID_TRATAMIENTO = p_id_tratamiento;

    RETURN v_total_abonado;
END;
/

-- Prueba de ambas funciones en SELECT (TOMAR CAPTURA):
SELECT ID, DNI, NOMBRES, APELLIDOS,
       FN_CONTAR_CITAS_PACIENTE(ID) AS TOTAL_CITAS
FROM PACIENTES
ORDER BY ID;

SELECT ID, ID_PACIENTE, ESTADO, COSTO_TOTAL, SALDO_PENDIENTE,
       FN_TOTAL_PAGADO_TRATAMIENTO(ID) AS TOTAL_ABONADO
FROM TRATAMIENTOS
ORDER BY ID;


-- ----------------------------------------------------------------------------
-- SECCIÓN 5.4: CURSORES Y ESTRUCTURAS DE CONTROL
-- Recorre atenciones realizadas y planes con saldo pendiente
-- ----------------------------------------------------------------------------
DECLARE
    CURSOR c_atenciones IS
        SELECT a.ID,
               o.NOMBRES || ' ' || o.APELLIDOS AS ODONTOLOGO,
               a.DIAGNOSTICO,
               TO_CHAR(a.FA_ATENCION, 'DD/MM/YYYY') AS FECHA
        FROM ATENCIONES a
        INNER JOIN ODONTOLOGOS o ON o.ID = a.ID_ODONTOLOGO
        ORDER BY a.ID DESC;

    v_reg      c_atenciones%ROWTYPE;
    v_contador NUMBER := 0;
BEGIN
    OPEN c_atenciones;
    LOOP
        FETCH c_atenciones INTO v_reg;
        EXIT WHEN c_atenciones%NOTFOUND;

        v_contador := v_contador + 1;
        DBMS_OUTPUT.PUT_LINE('Atencion #' || v_reg.ID || ' | Fecha: ' || v_reg.FECHA ||
                             ' | Odontologo: ' || v_reg.ODONTOLOGO || ' | Diag: ' || v_reg.DIAGNOSTICO);
    END LOOP;
    CLOSE c_atenciones;

    IF v_contador = 0 THEN
        DBMS_OUTPUT.PUT_LINE('No existen atenciones registradas aun.');
    ELSE
        DBMS_OUTPUT.PUT_LINE('Total atenciones listadas: ' || v_contador);
    END IF;
END;
/


-- ----------------------------------------------------------------------------
-- SECCIÓN 5.5: TRIGGERS DML (TRG_)
-- ----------------------------------------------------------------------------

-- Trigger 1 (Módulo Citas): Validar estados permitidos en CITAS
CREATE OR REPLACE TRIGGER TRG_VALIDAR_ESTADO_CITA
BEFORE INSERT OR UPDATE ON CITAS
FOR EACH ROW
BEGIN
    IF :NEW.ESTADO NOT IN ('PROGRAMADA', 'ATENDIDA', 'CANCELADA') THEN
        RAISE_APPLICATION_ERROR(-20004, 'Estado de cita invalido. Use PROGRAMADA, ATENDIDA o CANCELADA.');
    END IF;
END;
/

-- Trigger 2 (Módulo Pagos): Validar que el monto de pago no sea negativo
CREATE OR REPLACE TRIGGER TRG_VALIDAR_PAGO_DML
BEFORE INSERT OR UPDATE ON PAGOS
FOR EACH ROW
BEGIN
    IF :NEW.MONTO_TOTAL < 0 THEN
        RAISE_APPLICATION_ERROR(-20005, 'Regla BD: El monto total del pago no puede ser negativo.');
    END IF;

    IF UPDATING AND :OLD.MONTO_TOTAL <> :NEW.MONTO_TOTAL THEN
        DBMS_OUTPUT.PUT_LINE('Cambio de monto en pago #' || :NEW.ID ||
                             ': antes S/ ' || :OLD.MONTO_TOTAL || ' -> ahora S/ ' || :NEW.MONTO_TOTAL);
    END IF;
END;
/

-- Verificar todos los objetos PL/SQL compilados y válidos (TOMAR CAPTURA):
SELECT OBJECT_NAME, OBJECT_TYPE, STATUS
FROM USER_OBJECTS
WHERE OBJECT_TYPE IN ('PROCEDURE', 'FUNCTION', 'TRIGGER')
ORDER BY OBJECT_TYPE, OBJECT_NAME;
