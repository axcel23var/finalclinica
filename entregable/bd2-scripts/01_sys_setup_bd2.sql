-- ============================================================================
-- PASO 1 (EN LA PC DE LA U): EJECUTAR COMO SYS (ROL SYSDBA) EN FREEPDB1
-- Replica exactamente la configuracion del Informe Final (CLINICADENT_BD2)
-- ============================================================================

-- 1. Verificar que estas en la PDB correcta (debe devolver FREEPDB1)
SHOW CON_NAME;

-- 2. Crear Tablespace y Datafile (Capitulo VI del Informe)
CREATE TABLESPACE TS_CLINICADENT_BD2
    DATAFILE '/opt/oracle/oradata/FREE/FREEPDB1/clinicadent_bd2_01.dbf'
    SIZE 20M
    AUTOEXTEND ON NEXT 5M MAXSIZE 100M;

-- 3. Crear esquema de pruebas CLINICADENT_BD2 y asignar cuotas
CREATE USER CLINICADENT_BD2 IDENTIFIED BY "123456"
    DEFAULT TABLESPACE USERS
    TEMPORARY TABLESPACE TEMP
    QUOTA UNLIMITED ON USERS
    QUOTA 50M ON TS_CLINICADENT_BD2;

GRANT CREATE SESSION, CREATE TABLE, CREATE VIEW, CREATE PROCEDURE, CREATE TRIGGER, CREATE SEQUENCE TO CLINICADENT_BD2;

-- 4. Crear directorio Data Pump (Capitulo VIII del Informe)
CREATE OR REPLACE DIRECTORY BD2_DATAPUMP AS '/opt/oracle/oradata/bd2_datapump';
GRANT READ, WRITE ON DIRECTORY BD2_DATAPUMP TO CLINICADENT_BD2;

-- 5. Verificar Tablespace y Datafile
SELECT TABLESPACE_NAME,
       FILE_NAME,
       ROUND(BYTES / 1024 / 1024, 2) AS TAMANO_MB,
       AUTOEXTENSIBLE
FROM DBA_DATA_FILES
WHERE TABLESPACE_NAME = 'TS_CLINICADENT_BD2';
