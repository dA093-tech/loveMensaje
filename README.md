# HookLove 🎨❤️

Aplicación móvil Android para dibujar en tiempo real con tu pareja.

## Stack

- **Flutter** + Dart
- **Firebase Auth** (email + Google)
- **Cloud Firestore** (usuarios, parejas)
- **Firebase Realtime Database** (strokes en tiempo real)
- **Riverpod** (state management)
- **GoRouter** (navegación)

## Requisitos

- Flutter SDK ^3.7.0
- JDK 17
- Proyecto Firebase con Auth, Firestore y Realtime Database habilitados

## Setup

1. Clonar el repo
2. Crear proyecto en [Firebase Console](https://console.firebase.google.com)
3. Habilitar: Authentication (Email + Google), Firestore, Realtime Database, FCM
4. Descargar `google-services.json` y colocarlo en `android/app/`
5. Copiar `lib/firebase_options.dart` generado por FlutterFire CLI, o editar el existente con tus credenciales
6. Ejecutar:

```bash
flutter pub get
flutter run
```

## Características

- ✅ Autenticación email/password + Google
- ✅ Vinculación por código único
- ✅ Canvas de dibujo con colores, grosores y borrador
- ✅ Sincronización en tiempo real vía Firebase RTDB
- ✅ Indicador "tu pareja está dibujando"
- ✅ Modo lockscreen (showWhenLocked)
- ✅ Tema oscuro Material 3
- ✅ Compresión de trazos
- ✅ Reconexión automática
- ✅ Sin overlays (100% Google Play compliant)
