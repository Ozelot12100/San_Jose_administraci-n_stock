# San Jose Sistema de Inventario

Sistema completo de inventario para clínicas, desarrollado en **Flutter** (frontend) y **ASP.NET Core** (backend).

---

## Requisitos

### **Frontend (Windows)**
- Windows 10/11
- No requiere instalación de Flutter para el usuario final (ya viene compilado)
- Acceso a la red local donde esté el backend

### **Backend**
- Windows 10/11
- [.NET 9.0 Runtime](https://dotnet.microsoft.com/en-us/download/dotnet/9.0) instalado
- MySQL o MariaDB (para la base de datos)

---

## Instalación

### 1. **Clona el repositorio**
```sh
git clone https://github.com/Ozelot12100/San_Jose_administraci-n_stock.git
```

---

### 2. **Configura la base de datos**
- Crea una base de datos llamada `clinica_san_jose` en tu servidor MySQL/MariaDB.
- Modifica el archivo:
  ```
  Backend/SanJoseAPI/bin/Release/net9.0/win-x64/publish/appsettings.json
  ```
  Cambia la cadena de conexión según tus datos de usuario, contraseña y servidor.

---

### 3. **Instala y ejecuta el backend**

#### **Opción A: Usar el instalador**
- Ejecuta el instalador generado con Inno Setup (si lo tienes).
- Usa el acceso directo "Iniciar Backend San Jose" para arrancar el backend.
- El backend escuchará en el puerto `5177` para toda la red local.

#### **Opción B: Manual**
- Ve a:
  ```
  Backend/SanJoseAPI/bin/Release/net9.0/win-x64/publish
  ```
- Ejecuta en terminal:
  ```sh
  set ASPNETCORE_URLS=http://0.0.0.0:5177
  SanJoseAPI.exe
  ```
- El backend estará disponible en:  
  `http://<IP_DE_TU_PC>:5177`

---

### 4. **Configura el frontend**

- Ve a:
  ```
  lib/config/api_config.dart
  ```
- Cambia la línea:
  ```dart
  static const String baseUrl = 'http://192.168.0.92:5177';
  ```
  por la IP de la PC donde corre el backend (debe ser accesible desde la red).

---

### 5. **Ejecuta el frontend (Windows)**

- Ve a:
  ```
  build/windows/x64/runner/Release
  ```
- Ejecuta:
  ```
  san_jose_sistema_de_inventario.exe
  ```
- ¡Listo! Ya puedes usar el sistema.

---

## Notas importantes

- **Firewall:** Asegúrate de permitir el puerto `5177` en el firewall de Windows para conexiones entrantes.
- **Usuarios:** El sistema viene con usuarios de ejemplo. Puedes crear, editar y eliminar usuarios desde la app.
- **Soporte multiusuario:** Varias PCs pueden usar el frontend al mismo tiempo, siempre que apunten a la IP correcta del backend.

---

## Soporte

Si tienes dudas o problemas, abre un issue en este repositorio o contacta al desarrollador.

---
