# Paso 3 (En la PC de la U): Comandos Data Pump, Monitoreo y RMAN (según el Word)

> **Nota:** Si el puerto mapeado en `compose-dev.yml` en esa PC es `1521`, usa `1521` en SQL Developer; si es `1523`, usa `1523`. Dentro de `docker exec` Oracle siempre usa `1521/FREEPDB1`.

---

## 1. Data Pump (`EXPDP` / `IMPDP`) — Capítulo VIII

### Crear la carpeta física dentro del contenedor
```powershell
docker exec -u root clinicadent-oracle mkdir -p /opt/oracle/oradata/bd2_datapump
docker exec -u root clinicadent-oracle chown oracle:oinstall /opt/oracle/oradata/bd2_datapump
```

### Exportación del esquema `CLINICADENT_BD2`
```powershell
docker exec clinicadent-oracle expdp CLINICADENT_BD2/123456@localhost:1521/FREEPDB1 DIRECTORY=BD2_DATAPUMP DUMPFILE=clinicadent_bd2.dmp LOGFILE=clinicadent_bd2_exp.log SCHEMAS=CLINICADENT_BD2
```

### Importación recuperando `PACIENTES` como `PACIENTES_RECUP_BD2`
```powershell
docker exec clinicadent-oracle impdp CLINICADENT_BD2/123456@localhost:1521/FREEPDB1 DIRECTORY=BD2_DATAPUMP DUMPFILE=clinicadent_bd2.dmp LOGFILE=clinicadent_bd2_imp.log TABLES=CLINICADENT_BD2.PACIENTES REMAP_TABLE=CLINICADENT_BD2.PACIENTES:PACIENTES_RECUP_BD2 EXCLUDE=INDEX,CONSTRAINT,STATISTICS
```

### Verificación en SQL Developer (`CLINICADENT_BD2`)
```sql
SELECT 'ORIGINAL' AS ORIGEN, ID, DNI, NOMBRES, APELLIDOS FROM PACIENTES WHERE DNI = 'BD2-DP-01'
UNION ALL
SELECT 'IMPORTADO' AS ORIGEN, ID, DNI, NOMBRES, APELLIDOS FROM PACIENTES_RECUP_BD2 WHERE DNI = 'BD2-DP-01';
```

---

## 2. Monitoreo de Sesiones y Bloqueos (en `SYS`)
```sql
-- Ver sesiones activas y bloqueos
SELECT SID AS SESION_EN_ESPERA,
       BLOCKING_SESSION AS SESION_BLOQUEADORA,
       EVENT
FROM V$SESSION
WHERE USERNAME = 'CLINICADENT_BD2'
  AND BLOCKING_SESSION_STATUS = 'VALID';

-- Ver objetos inválidos (debe salir 0)
SELECT COUNT(*) AS OBJETOS_INVALIDOS
FROM DBA_OBJECTS
WHERE OWNER = 'CLINICADENT_BD2' AND STATUS <> 'VALID';
```

---

## 3. Respaldo Físico RMAN (en frío, por estar en `NOARCHIVELOG`)
*(La imagen `23-slim` no trae el binario `rman`, por eso se ejecuta desde el contenedor auxiliar `gvenzl/oracle-free:latest` conectado a la red de `clinicadent-oracle`).*

1. Montar la base en modo `MOUNT`:
```powershell
docker exec -u root clinicadent-oracle bash -c "mkdir -p /opt/oracle/oradata/bd2_rman && chown oracle:oinstall /opt/oracle/oradata/bd2_rman"
docker exec clinicadent-oracle bash -c "printf 'SHUTDOWN IMMEDIATE;\nSTARTUP MOUNT;\nEXIT;\n' | sqlplus / as sysdba"
```
2. Ejecutar respaldo `BD2_FRIO` y validar los 5 backup sets:
```powershell
$rman = @"
BACKUP DATABASE INCLUDE CURRENT CONTROLFILE FORMAT '/opt/oracle/oradata/bd2_rman/clinica_%U.bkp' TAG 'BD2_FRIO';
LIST BACKUP SUMMARY;
VALIDATE BACKUPSET 1;
VALIDATE BACKUPSET 2;
VALIDATE BACKUPSET 3;
VALIDATE BACKUPSET 4;
VALIDATE BACKUPSET 5;
EXIT;
"@
$rman | docker run --rm -i --network container:clinicadent-oracle --entrypoint rman gvenzl/oracle-free:latest target "sys/123456@(DESCRIPTION=(ADDRESS=(PROTOCOL=TCP)(HOST=localhost)(PORT=1521))(CONNECT_DATA=(SERVICE_NAME=FREE)(UR=A)))"
```
3. Volver a abrir la base de datos:
```powershell
docker exec clinicadent-oracle bash -c "printf 'ALTER DATABASE OPEN;\nEXIT;\n' | sqlplus / as sysdba"
```
