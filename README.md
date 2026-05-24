Ejecución del backend
Con Docker
cd backend
cp .env.example .env
docker compose up --build

El servicio inicia PostgreSQL y la API en:

http://localhost:8000

Durante el arranque se ejecutan:

migraciones
carga de datos iniciales
creación de usuarios demo
Usuarios de prueba
Rol	Correo	Contraseña
Administrador	admin@pachasuite.com	admin123
Recepcionista	recepcion@pachasuite.com	recepcion123
Verificación rápida
curl http://localhost:8000/api/health/

curl -X POST http://localhost:8000/api/auth/login/ \
  -H "Content-Type: application/json" \
  -d '{"email":"admin@pachasuite.com","password":"admin123"}'
Sin Docker (opcional)
cd backend

python -m venv .venv
source .venv/bin/activate

pip install -r requirements.txt

python manage.py migrate
python manage.py seed
python manage.py runserver 0.0.0.0:8000

Requiere una instancia local de PostgreSQL y configurar correctamente las variables de entorno.

Ejecución de la app Flutter
cd app

flutter create .
flutter pub get
Configuración del backend
Android Emulator
http://10.0.2.2:8000/api
iOS Simulator o escritorio
flutter run --dart-define=API_BASE_URL=http://localhost:8000/api
Dispositivo físico
flutter run --dart-define=API_BASE_URL=http://192.168.x.x:8000/api
Configuración Android

El paquete flutter_secure_storage requiere:

minSdkVersion 23

Editar:

android/app/build.gradle
 Flujo de autenticación
La pantalla Splash verifica si existen tokens almacenados.
Si la sesión sigue siendo válida, se obtiene la información del usuario mediante /auth/me/.
Si no hay sesión activa, el usuario es redirigido a Login.
Después del inicio de sesión:
se almacenan los tokens en el Keystore seguro
se carga el perfil del usuario
se habilita la navegación principal
Ante un error 401, el cliente intenta renovar el token automáticamente usando /auth/refresh/.
Si la renovación falla, se ejecuta el cierre de sesión y se limpian los datos locales.
 Control de acceso por roles

El sistema diferencia dos tipos de usuario:

ADMIN
RECEPCIONISTA

Se implementó:

renderizado condicional de acciones
protección de pantallas administrativas mediante AdminGuard
pantalla de acceso restringido (UnauthorizedScreen)
 Pantallas implementadas
Pantalla	Descripción
Splash	Validación automática de sesión
Login	Inicio de sesión y validación
Dashboard	Indicadores generales y resumen
Habitaciones	Listado con filtros y estados
Detalle habitación	Información básica y estado
Perfil	Datos del usuario y logout
Unauthorized	Acceso restringido
Consideraciones
Backend

Las pruebas principales fueron verificadas correctamente:

login
validación de sesión
obtención de habitaciones
acceso protegido por token
Flutter

El proyecto mantiene una estructura modular y consistente.
Sin embargo, no fue compilado en este entorno debido a la ausencia del SDK de Flutter.

Antes de ejecutar:

flutter pub get
flutter analyze
 Alcance del entregable

Este avance no incluye:

reservas
check-in/check-out
CRUD completo de habitaciones
reportes
notificaciones
auditoría
integración con Firebase
exportaciones

Estas funcionalidades quedan planificadas para los siguientes sprints.
