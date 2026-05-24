# Pacha Suite — App Móvil (Sprint 1 + avance Sprint 2)

App móvil oficial de **Hotel Pacha Suite**, extensión del sistema web existente.
Construida con **Flutter + Provider + Material 3** y un backend mínimo
**Django REST Framework + SimpleJWT + PostgreSQL** (Docker).

Este entregable cubre:

- **Sprint 1 completo** — autenticación JWT, persistencia segura, logout,
  navegación principal y control de acceso por roles.
- **Avance controlado de Sprint 2** — listado de habitaciones (HU20) y
  detalle simple (HU21). Sin CRUD, reservas ni funciones avanzadas.

---

## 📦 Estructura del proyecto

```
pacha-suite-mobile/
├── backend/                  # API Django (mínima)
│   ├── config/               # settings, urls, wsgi
│   ├── apps/
│   │   ├── accounts/         # User custom (rol), login/refresh/me, seed
│   │   └── rooms/            # Habitaciones (list + detail)
│   ├── docker-compose.yml    # Postgres + API
│   ├── Dockerfile
│   ├── entrypoint.sh         # migrate + seed + gunicorn
│   ├── requirements.txt
│   └── .env.example
│
└── app/                      # Proyecto Flutter
    ├── lib/
    │   ├── config/           # theme Material3, app_config (baseUrl)
    │   ├── core/             # colores, enum rol, errores, validators
    │   ├── models/           # user, auth_tokens, room
    │   ├── services/         # api_client (Dio), secure_storage (Keystore)
    │   ├── repositories/     # auth_repository, room_repository
    │   ├── providers/        # auth_provider, room_provider
    │   ├── routes/           # rutas + role_guard
    │   ├── widgets/          # botón, input, badge, kpi, room_card, skeleton…
    │   ├── screens/          # splash, auth, shell, dashboard, rooms, perfil, unauthorized
    │   └── main.dart
    ├── pubspec.yaml
    └── analysis_options.yaml
```

---

## 🎨 Identidad visual (reutilizada de la web)

| Color | Hex |
|---|---|
| Naranja quemado | `#C2410C` |
| Naranja oscuro | `#9A3412` |
| Ámbar | `#D97706` |
| Café chocolate | `#5C3A21` |
| Beige claro | `#FAF7F2` |
| Beige suave | `#F0E9DD` |
| Texto cálido | `#1F1611` |

Tipografía: **Playfair Display** (títulos) + **Inter** (cuerpo), vía `google_fonts`.

---

## 🔌 Contrato de API

```
POST /api/auth/login/
  body: { "email": "...", "password": "..." }
  200 : { "access": "...", "refresh": "...",
          "user": { "id": 1, "name": "Ana Quispe",
                    "email": "...", "role": "ADMIN" } }

POST /api/auth/refresh/
  body: { "refresh": "..." }
  200 : { "access": "..." }

GET  /api/auth/me/        (Authorization: Bearer <access>)
  200 : { "id": 1, "name": "...", "email": "...", "role": "ADMIN" }

GET  /api/rooms/          -> lista de habitaciones (HU20)
GET  /api/rooms/{id}/     -> detalle de habitación (HU21)
```

Roles: `ADMIN`, `RECEPCIONISTA`.
Estados de habitación: `disponible`, `ocupada`, `mantenimiento`.

---

## 🚀 1) Levantar el backend (Docker)

```bash
cd backend
cp .env.example .env          # ajusta credenciales/secret si quieres
docker compose up --build
```

Esto levanta PostgreSQL + la API en `http://localhost:8000`, aplica
migraciones y ejecuta el **seed** automáticamente.

**Usuarios demo creados por el seed:**

| Rol | Email | Password |
|---|---|---|
| Administrador | `admin@pachasuite.com` | `admin123` |
| Recepcionista | `recepcion@pachasuite.com` | `recepcion123` |

Verifica:
```bash
curl http://localhost:8000/api/health/
curl -X POST http://localhost:8000/api/auth/login/ \
  -H "Content-Type: application/json" \
  -d '{"email":"admin@pachasuite.com","password":"admin123"}'
```

### Sin Docker (opcional)
```bash
cd backend
python -m venv .venv && source .venv/bin/activate
pip install -r requirements.txt
# Configura POSTGRES_HOST=localhost en .env y ten Postgres corriendo
python manage.py migrate
python manage.py seed
python manage.py runserver 0.0.0.0:8000
```

---

## 📱 2) Ejecutar la app Flutter

> **Nota:** este entregable incluye `lib/` + `pubspec.yaml`. Las carpetas de
> plataforma (`android/`, `ios/`) se generan con un comando, ya que dependen de
> tu versión local de Flutter.

```bash
cd app
flutter create .            # genera android/ ios/ con el package por defecto
flutter pub get
```

### Apuntar al backend
- **Emulador Android:** usa `http://10.0.2.2:8000/api` (valor por defecto).
- **iOS Simulator / escritorio:** pásale tu host:
  ```bash
  flutter run --dart-define=API_BASE_URL=http://localhost:8000/api
  ```
- **Dispositivo físico:** usa la IP LAN de tu PC:
  ```bash
  flutter run --dart-define=API_BASE_URL=http://192.168.x.x:8000/api
  ```

### Requisito Android (Secure Storage / Keystore)
`flutter_secure_storage` con `encryptedSharedPreferences` requiere
**minSdkVersion 23**. Tras `flutter create .`, edita
`android/app/build.gradle`:
```gradle
defaultConfig {
    minSdkVersion 23
}
```

---

## 🔐 Flujo de autenticación (Sprint 1)

1. **Splash** valida sesión: lee tokens del Keystore y llama `/auth/me/`.
2. Sesión válida → **MainShell**; sin sesión → **Login**.
3. **Login** valida campos, llama `/auth/login/`, guarda `access`+`refresh`
   en el almacenamiento seguro y carga el usuario.
4. El **ApiClient (Dio)** inyecta `Bearer` en cada request y, ante un `401`,
   intenta `/auth/refresh/` **una vez**; si falla, fuerza logout.
5. **Logout** limpia el Keystore y regresa a Login.

### Control de acceso por roles (HU17)
- `AuthProvider.role` expone `ADMIN` / `RECEPCIONISTA`.
- Renderizado condicional (p. ej. acción "Cambiar estado" solo para ADMIN).
- `AdminGuard` (en `routes/role_guard.dart`) envuelve pantallas solo-admin y
  muestra **UnauthorizedScreen** si el rol no tiene permiso.

---

## 🗺️ Pantallas

| Pantalla | HU | Descripción |
|---|---|---|
| Splash | 14 | Auto-login y ruteo inicial |
| Login | 13 | Credenciales + validación + estados de carga |
| Dashboard | — | KPIs (total, disponibles, ocupadas, mantenimiento), ocupación, actividad |
| Habitaciones | 20 | Lista con cards, filtros por estado, skeleton, empty/error |
| Detalle habitación | 21 | Specs, descripción, badge de estado, acciones placeholder |
| Perfil | 15 | Datos del usuario, rol y logout |
| Unauthorized | 17 | Acceso restringido por rol |

---

## ⚠️ Notas de validación

- **Backend:** verificado de extremo a extremo (login → `/me` → `/rooms` →
  detalle → 401 sin token) sobre una base de datos de prueba. ✅
- **Flutter:** el código está organizado y con imports consistentes, pero
  **no se compiló** porque este entorno no tiene el SDK de Flutter instalado.
  Ejecuta `flutter pub get` y `flutter analyze` en tu máquina antes de correr.

## 🧭 Fuera de alcance (intencional)
CRUD de habitaciones, reservas, check-in, cochera, reportes, auditoría,
alertas, Firebase, notificaciones y exportaciones. Se abordan en sprints
posteriores.
