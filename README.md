# HookLove 🎨❤️

Aplicación móvil Android para dibujar y compartir dibujos con tu pareja a distancia. Los dibujos se envían manualmente (no en tiempo real) y se muestran como overlay temporal de pantalla completa.

## Stack Tecnológico

| Capa | Tecnología |
|------|-----------|
| **Frontend** | Flutter 3.x + Dart |
| **Backend** | Firebase (Auth, Firestore, RTDB, FCM, Functions, Storage) |
| **Estado** | Riverpod (StateNotifier + StreamProvider + FutureProvider) |
| **Navegación** | GoRouter (redirect basado en auth + pairing) |
| **Auth** | Firebase Auth (email/password + Google Sign-In) |
| **Base de datos principal** | Cloud Firestore (usuarios, pares, config) |
| **Drawings** | Firebase Realtime Database (strokes, presencia, incoming) |
| **Notificaciones** | Firebase Cloud Messaging + Cloud Functions (v2) |
| **Actualización OTA** | Firestore (config) + dart:io HttpClient + open_file |

## Características

### Autenticación
- ✅ Registro e inicio de sesión con email + password
- ✅ Inicio de sesión con Google
- ✅ Recuperación de contraseña
- ✅ Persistencia de sesión
- ✅ Detección de estado de autenticación con redirect automático

### Vinculación de Pareja
- ✅ Generación de código único de 6 caracteres (alfanumérico sin vocales)
- ✅ Aceptación de código para vincularse
- ✅ Auto-vinculación permitida en modo debug (`kDebugMode`)
- ✅ Actualización en tiempo real del estado de pareja (Firestore snapshots)
- ✅ Desvinculación manual

### Canvas de Dibujo
- ✅ Lápiz con 12 colores predefinidos
- ✅ Control de grosor de trazo (deslizador)
- ✅ Modo borrador
- ✅ Trazos suavizados (StrokeCap.round, StrokeJoin.round)
- ✅ Compresión de puntos (Ramer-Douglas-Peucker)
- ✅ Canvas responsivo (coordenadas normalizadas 0.0–1.0)
- ✅ Indicador "tu pareja está dibujando"
- ✅ Fullscreen + toolbar colapsable
- ✅ Modo lockscreen (showWhenLocked)

### Envío de Dibujos
- ✅ Botón "Enviar" en la barra superior (deshabilitado si el canvas está vacío)
- ✅ Los dibujos se envían explícitamente, NO en tiempo real
- ✅ Al enviar, el dibujo se persiste en RTDB bajo `/drawings/{pairId}/incoming/{pushId}`
- ✅ El canvas se limpia automáticamente después de enviar
- ✅ Feedback visual (SnackBar "Dibujo enviado")

### Recepción de Dibujos (Overlay)
- ✅ Escucha en tiempo real de nuevos dibujos entrantes (`onChildAdded`)
- ✅ Overlay de pantalla completa con fondo semitransparente oscuro
- ✅ Renderizado de todos los trazos recibidos
- ✅ Auto-dismiss después de 5 segundos
- ✅ Botón de cierre manual (X)
- ✅ Eliminación del nodo en RTDB al descartar (`acknowledgeIncomingDrawing`)
- ✅ Etiqueta con el nombre del remitente

### Actualización OTA
- ✅ Verificación al inicio contra Firestore `config/app_version`
- ✅ Comparación semántica de versiones (major.minor.patch)
- ✅ Diálogo con opciones "Actualizar" / "Ahora no"
- ✅ Soporte para updates forzados (`forceUpdate`)
- ✅ Descarga del APK mediante `dart:io` HttpClient
- ✅ Instalación automática vía `open_file`
- ✅ Manejo de errores con feedback visual

### Cloud Functions (FCM)
- ✅ `onNewStroke` — notificación push al dibujar (legacy, no usado por send-drawing)
- ✅ `onPresenceChanged` — notificación cuando la pareja empieza a dibujar
- ✅ Notificaciones con canal dedicado `hooklove_drawing`
- ✅ Datos estructurados para deep linking

### Seguridad
- ✅ Firestore rules: usuarios solo leen/escriben su propio documento
- ✅ Firestore rules: lectura de usuarios permitida para la pareja vinculada
- ✅ Firestore rules: escritura de `partnerId` solo auto-asignable
- ✅ Firestore rules: pares accesibles solo por miembros del par
- ✅ Firestore rules: `config` legible por cualquier usuario autenticado (OTA)
- ✅ RTDB rules: drawings accesibles solo por miembros del par
- ✅ RTDB rules: presencia auto-limitada por userId

## Arquitectura

```
lib/
├── app/
│   ├── app.dart                    # Widget raíz, listener de drawings entrantes
│   └── router/app_router.dart      # GoRouter con redirects por auth + pairing
├── core/
│   ├── constants/app_constants.dart
│   ├── errors/app_exception.dart
│   ├── extensions/
│   ├── network/firebase_providers.dart  # Providers raw de Firebase
│   ├── theme/
│   ├── update/
│   │   ├── update_service.dart     # OTA check, download, install
│   │   └── update_providers.dart
│   └── utils/
├── features/
│   ├── auth/
│   │   ├── data/auth_repository_impl.dart  # Auth + Firestore snapshots
│   │   ├── data/auth_providers.dart
│   │   ├── domain/auth_repository.dart
│   │   ├── domain/user.dart         # AppUser con partnerId, pairingCode
│   │   └── presentation/
│   ├── drawing/
│   │   ├── data/
│   │   │   ├── drawing_repository_impl.dart  # RTDB: strokes, presence, incoming
│   │   │   └── drawing_providers.dart
│   │   ├── domain/
│   │   │   ├── canvas_state.dart
│   │   │   ├── drawing_repository.dart
│   │   │   ├── incoming_drawing.dart  # Modelo de dibujo recibido
│   │   │   └── stroke.dart
│   │   └── presentation/
│   │       ├── providers/drawing_providers.dart  # CanvasController
│   │       ├── screens/canvas_screen.dart
│   │       └── widgets/
│   ├── home/
│   ├── notifications/
│   │   ├── fcm_service.dart
│   │   └── notification_handler.dart
│   ├── pairing/
│   │   ├── data/
│   │   ├── domain/
│   │   └── presentation/
│   └── settings/
└── main.dart
```

### Flujo de datos

#### Envío de dibujo
1. Usuario dibuja en el canvas (todo local, en memoria)
2. Presiona "Enviar"
3. `CanvasController.sendDrawing()` → `DrawingRepository.sendDrawing()`
4. Se escribe en RTDB: `/drawings/{pairId}/incoming/{pushId}`
5. Canvas se limpia

#### Recepción de dibujo
1. `app.dart` escucha `watchIncomingDrawings(pairId)` mediante `onChildAdded`
2. Cuando llega un nuevo nodo en `/incoming/`, se crea un `IncomingDrawing`
3. Se muestra `DrawingOverlay` como `showDialog` de pantalla completa
4. A los 5 segundos (o al presionar X), se llama `acknowledgeIncomingDrawing()`
5. El nodo se elimina de RTDB

#### OTA Update
1. `SplashScreen._checkForUpdate()` → `UpdateService.checkForUpdate()`
2. Se lee `config/app_version` de Firestore
3. Si `latestVersion > appVersion` → se muestra diálogo
4. Usuario acepta → `downloadApk()` + `installApk()`
5. Si `forceUpdate` es true, el diálogo no es dismissible

## Firebase

### Proyecto
- **ID:** `lovemensaje`
- **Plan:** Blaze (pay-as-you-go, requiere para FCM + Functions)

### Servicios habilitados

| Servicio | Uso |
|----------|-----|
| **Authentication** | Email/Password + Google Sign-In |
| **Cloud Firestore** | `users/`, `pairs/`, `config/` |
| **Realtime Database** | `/drawings/{pairId}/{strokes,incoming,presence}` |
| **Cloud Functions** | `onNewStroke`, `onPresenceChanged` (FCM triggers) |
| **Cloud Messaging** | Notificaciones push |
| **Cloud Storage** | (Opcional, para almacenar APK de OTA) |

### Firestore Collections

```
users/{uid}
  ├── email: string
  ├── displayName: string
  ├── photoUrl: string?
  ├── partnerId: string?
  ├── pairingCode: string?
  ├── fcmToken: string?
  ├── fcmTokenUpdatedAt: string?
  └── createdAt: string

pairs/{pairId}
  ├── user1Id: string
  ├── user2Id: string
  ├── status: "pending" | "active" | "disconnected"
  ├── createdAt: string
  └── activatedAt: string?

config/app_version
  ├── latestVersion: string (ej. "1.1.0")
  ├── apkUrl: string
  └── forceUpdate: boolean
```

### Realtime Database Structure

```
/drawings/{pairId}/
  ├── strokes/{strokeId}        # (legacy, no usado para send-drawing)
  │   ├── userId, tool, color, width, timestamp, deleted
  │   └── points/{pushId}
  │       ├── x: double (0.0–1.0)
  │       └── y: double (0.0–1.0)
  ├── incoming/{pushId}         # Dibujos enviados manualmente
  │   ├── fromUserId: string
  │   ├── timestamp: number
  │   └── strokes: [{userId, tool, color, width, points: [{x, y}], timestamp, id}]
  └── presence/{userId}
      └── "drawing" | "idle"
```

## Setup Local

### Requisitos
- Flutter SDK ^3.7.0
- JDK 17
- Proyecto Firebase con Auth, Firestore, RTDB, FCM habilitados
- Node.js 22 (para Firebase Functions)

### Pasos

```bash
# Clonar
git clone https://github.com/dA093-tech/loveMensaje.git
cd loveMensaje

# Configurar Firebase
# 1. Ir a Firebase Console > Project Settings > General
# 2. Descargar google-services.json → android/app/
# 3. Generar firebase_options.dart (opcional, ya existe)
# 4. firebase use --add lovemensaje

# Dependencias Flutter
flutter pub get

# Dependencias Cloud Functions
cd functions
npm install
cd ..

# Ejecutar en emulador
flutter run
```

### Testing con dos emuladores

Se necesitan **dos cuentas de Google distintas** (una por emulador).

```bash
# Emulador 1 (ej. emulator-5554)
flutter run -d emulator-5554

# Emulador 2 (ej. emulator-5556)
flutter run -d emulator-5556
```

### Generar APK

```bash
flutter build apk --release
# Output: build/app/outputs/flutter-apk/app-release.apk
```

## Firebase Deploy Completo

```bash
# Desplegar todo
firebase deploy --project lovemensaje

# O servicios individuales
firebase deploy --only firestore:rules
firebase deploy --only database:rules
firebase deploy --only functions
firebase deploy --only auth
```

## OTA Update — Configuración

Para activar la actualización OTA, crear el documento en Firestore:

```
Colección: config
Documento: app_version
Campos:
  - latestVersion: "1.1.0"      # Versión a comparar con AppConstants.appVersion
  - apkUrl: "https://storage..." # URL pública del APK (Firebase Storage o CDN)
  - forceUpdate: false           # true = obligatorio, no dismissible
```

## Licencia

Uso privado — Proyecto personal.
