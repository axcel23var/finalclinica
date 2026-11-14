# Guía Rápida de Ejecución y Git — ClinicaDent

Guía paso a paso con todos los comandos en orden para clonar, levantar Docker/Oracle/Keycloak, Backend, Frontend, cambiar puertos si hay conflicto y trabajar con Git.

- **Repositorio GitHub:** `https://github.com/axcel23var/finalclinica.git`
- **Usuario Git:** `axcel23var`
- **Correo Git:** `vargasaxcel4@gmail.com`

---

## 1. Requisitos en la PC

- **Git**
- **Docker Desktop** (abierto y corriendo)
- **Java 21**
- **Node.js y npm**

---

## 2. Clonar el proyecto en otra PC (primera vez)

Abre PowerShell donde quieras guardar el proyecto (por ejemplo `D:\`) y ejecuta en fila:

```powershell
git config --global user.name "axcel23var"
git config --global user.email "vargasaxcel4@gmail.com"
git clone https://github.com/axcel23var/finalclinica.git
cd finalclinica
```

---

## 3. Levantar Docker (Keycloak + PostgreSQL + Oracle) y Backend

En **Terminal 1** (dentro de `finalclinica`):

```powershell
cd CLINICADENT-backend
docker compose -f compose-dev.yml up -d
```

Espera a que Oracle termine de inicializar (~1 minuto la primera vez). Puedes verlo en vivo con:

```powershell
docker logs -f clinicadent-oracle
```

Cuando aparezca `DATABASE IS READY TO USE!`, presiona `Ctrl + C` para salir de los logs y arranca el backend:

```powershell
.\mvnw.cmd spring-boot:run
```

*(Deja esta terminal abierta corriendo).*

---

## 4. Levantar Frontend (Angular)

Abre **Terminal 2** aparte (dentro de `finalclinica`):

```powershell
cd frontend
npm install
npm start
```

> **Nota:** `npm install` solo se ejecuta la primera vez al clonar (o cuando cambie `package.json`). En arranques siguientes basta con `npm start`. Deja esta terminal abierta sin presionar `Ctrl + C`.

---

## 5. Crear usuario en Keycloak (solo la primera vez en la PC)

El realm `clinicadent` se importa automáticamente sin usuarios creados. Para poder iniciar sesión en la web:

1. Entra a `http://localhost:38081`
2. Inicia sesión en la consola admin de Keycloak:
   - **Usuario:** `admin`
   - **Contraseña:** `admin123`
3. Arriba a la izquierda, cambia al realm **`clinicadent`**.
4. Ve a **Users → Add user**, crea tu usuario.
5. En la pestaña **Credentials**, asigna una contraseña (desactiva *Temporary*).
6. En la pestaña **Role mapping → Assign role**, asigna el rol deseado (`ADMINISTRADOR`, `RECEPCIONISTA`, `ODONTOLOGO` o `CAJERO`).

---

## 6. URLs del sistema corriendo

| Servicio | URL |
|---|---|
| **Frontend (Angular)** | `http://localhost:4200` |
| **Backend (Spring Boot)** | `http://localhost:8080` |
| **Swagger UI** | `http://localhost:8080/swagger-ui.html` |
| **Keycloak** | `http://localhost:38081` |
| **Oracle DB** | `localhost:1521/FREEPDB1` (`CLINICADENT_APP` / `123456`) |

---

## 7. Si el puerto `1521` de Oracle está ocupado en esa PC

Si al correr `.\mvnw.cmd spring-boot:run` sale `ORA-12514` o en `docker ps -a` ves `clinicadent-oracle` en estado `Created`:

### Comandos de diagnóstico
```powershell
docker ps -a
netstat -ano | findstr :1521
tasklist /FI "PID eq 7760"
```
*(Reemplaza `7760` por el PID que te aparezca en `netstat`).*

### Cambiar el puerto de Oracle a `1523`
1. En `CLINICADENT-backend/compose-dev.yml` cambia `"1521:1521"` por:
   ```yaml
   - "1523:1521"
   ```
2. En `CLINICADENT-backend/src/main/resources/application-dev.yml` cambia la URL por:
   ```yaml
   url: jdbc:oracle:thin:@localhost:1523/FREEPDB1
   ```
3. Reaplica Docker, espera a que Oracle esté listo y arranca el backend:
   ```powershell
   cd CLINICADENT-backend
   docker compose -f compose-dev.yml up -d
   docker logs -f clinicadent-oracle
   ```
   Cuando veas `DATABASE IS READY TO USE!`, presiona `Ctrl + C` y corre:
   ```powershell
   .\mvnw.cmd spring-boot:run
   ```

---

## 8. Comandos Git para el día a día

*(Estando dentro de la carpeta raíz `finalclinica`):*

### Subir cambios nuevos a GitHub
```powershell
git status
git add .
git commit -m "feat: descripcion de lo que agregaste o cambiaste"
git push
```

### Descargar cambios si actualizaste desde otra PC
```powershell
git pull
```
