# Bloque 4: Exportación e Importación (Data Pump `EXPDP`/`IMPDP` y Clásico `exp`/`imp`)

> **Dónde se ejecuta:** En **PowerShell o CMD de Windows** (NO dentro de SQL Developer).
> Asegúrate de haber corrido primero el Bloque 1 (`01_sys_tablespaces_y_usuarios.sql`) en `ClinicaDent_SYS` para que existan `CLINICADENT_IMP` y `DIR_BACKUP`.

---

## Opción 1: Oracle Data Pump (`expdp` / `impdp`) dentro del contenedor Docker (Recomendado — pide el Formato Word Sección VIII)

### 1. Crear carpeta de respaldo dentro del contenedor Oracle
```powershell
docker exec -u root clinicadent-oracle mkdir -p /opt/oracle/backup_clinicadent
docker exec -u root clinicadent-oracle chown oracle:oinstall /opt/oracle/backup_clinicadent
```

### 2. Exportación (`EXPDP`) del esquema `CLINICADENT_APP`
```powershell
docker exec clinicadent-oracle expdp CLINICADENT_APP/123456@localhost:1521/FREEPDB1 DIRECTORY=DIR_BACKUP DUMPFILE=clinicadent_dp.dmp LOGFILE=clinicadent_expdp.log SCHEMAS=CLINICADENT_APP
```

### 3. Ver archivos generados (`.dmp` y `.log`) — *Tomar captura*
```powershell
docker exec clinicadent-oracle ls -lh /opt/oracle/backup_clinicadent
```

### 4. Importación (`IMPDP`) hacia el esquema destino `CLINICADENT_IMP`
```powershell
docker exec clinicadent-oracle impdp SYSTEM/123456@localhost:1521/FREEPDB1 DIRECTORY=DIR_BACKUP DUMPFILE=clinicadent_dp.dmp LOGFILE=clinicadent_impdp.log REMAP_SCHEMA=CLINICADENT_APP:CLINICADENT_IMP REMAP_TABLESPACE=USERS:TBS_OPERACIONAL TABLE_EXISTS_ACTION=REPLACE
```
*(Nota: dentro del contenedor Oracle escucha en el puerto `1521`, por eso ahí dice `1521/FREEPDB1`).*

---

## Opción 2: Método Clásico de clase (`exp` / `imp`) desde CMD de Windows
*(Si en clase usaron las utilidades `exp` e `imp` instaladas en tu Windows con Oracle 21c, puedes ejecutarlas apuntando al puerto `1523` de Docker):*

```cmd
:: Exportación desde CMD de Windows
exp USERID=SYSTEM/123456@localhost:1523/FREEPDB1 OWNER=CLINICADENT_APP FILE="%USERPROFILE%\clinicadent_respaldo_01.dmp" LOG="%USERPROFILE%\clinicadent_respaldo_01.log"

:: Importación hacia esquema destino
imp USERID=SYSTEM/123456@localhost:1523/FREEPDB1 FILE="%USERPROFILE%\clinicadent_respaldo_01.dmp" FROMUSER=CLINICADENT_APP TOUSER=CLINICADENT_IMP LOG="%USERPROFILE%\clinicadent_importacion_01.log" IGNORE=N
```

---

## 5. Verificación final en SQL Developer (Sección 8.4)
Ejecuta esto en **`ClinicaDent_SYS`** (para comprobar que las tablas y registros se importaron en `CLINICADENT_IMP`):

```sql
SELECT TABLE_NAME, NUM_ROWS
FROM DBA_TABLES
WHERE OWNER = 'CLINICADENT_IMP'
ORDER BY TABLE_NAME;

SELECT COUNT(*) AS PACIENTES_IMPORTADOS FROM CLINICADENT_IMP.PACIENTES;
SELECT COUNT(*) AS PAGOS_IMPORTADOS     FROM CLINICADENT_IMP.PAGOS;
```
