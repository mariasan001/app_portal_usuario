# Auth Architecture

Esta carpeta sigue una estructura por capas para que el modulo crezca sin que
la UI termine mezclada con llamadas HTTP o reglas de negocio.

## Idea general

El recorrido normal es este:

`UI -> Controller -> UseCase -> Repository -> DataSource -> ApiClient -> API`

Y la respuesta regresa asi:

`API -> DTO -> Repository -> Entity/Result -> Controller -> State -> UI`

## Que significa cada carpeta

### `application/`

Aqui vive la coordinacion del flujo.

- `auth_controller.dart`
  - recibe acciones desde la UI
  - llama use cases
  - actualiza `AuthState`
- `auth_state.dart`
  - guarda el estado visible para pantallas y widgets
- `auth_providers.dart`
  - conecta dependencias usando Riverpod

### `domain/`

Es la parte mas cercana al negocio.

- `entities/`
  - objetos limpios que usa la app
  - no deberian depender de JSON ni de Dio
- `repositories/`
  - contratos que el dominio necesita
  - ejemplo: `AuthRepository`
- `usecases/`
  - acciones puntuales del negocio
  - ejemplo: `LoginUseCase`, `ForgotPasswordUseCase`

### `data/`

Es la capa que aterriza la comunicacion real con backend.

- `datasources/`
  - hablan directamente con HTTP
  - conocen endpoints y payloads
- `dtos/`
  - objetos de transferencia para request/response
  - representan el formato exacto que envia o recibe la API
- `repositories/`
  - implementan los contratos del dominio
  - convierten DTOs a entidades/resultados

## Por que no llamar la API desde la UI

Porque si una pantalla hace HTTP directo:

- mezcla vista con infraestructura
- se vuelve dificil de probar
- duplicas validaciones y mapeos
- cambiar backend rompe muchas pantallas

Con esta estructura, si cambia la API normalmente ajustamos `dto`,
`datasource` o `repository`, y la UI casi no se toca.

## Regla practica para leer archivos

- Si ves `Dto`: piensa "formato del backend"
- Si ves `Entity` o `Result`: piensa "objeto que usa la app"
- Si ves `UseCase`: piensa "accion del negocio"
- Si ves `Repository`: piensa "puente entre negocio y datos"
- Si ves `DataSource`: piensa "llamada real a la API"
- Si ves `Controller`: piensa "director del flujo"

## Ejemplo con login

1. `LoginPage` pide iniciar sesion
2. `AuthController.login()` coordina el proceso
3. `LoginUseCase` expresa la accion de negocio
4. `AuthRepository` define el contrato
5. `AuthRepositoryImpl` usa `AuthRemoteDataSource`
6. `AuthRemoteDataSourceImpl` llama `/auth/login`
7. `LoginResponseDto` lee la respuesta
8. el repository convierte eso a `LoginResult`
9. el controller actualiza `AuthState`
10. la UI reacciona

## Ejemplo con recuperacion

1. pantalla de recuperar -> `forgotPassword`
2. pantalla de token -> usuario captura OTP
3. pantalla nueva contrasena -> `resetPassword`

Nota:
el flujo actual no usa `otp/request`, `otp/verify` ni `ping`; se retiraron para
mantener esta sesion enfocada solo en login, registro, recuperacion y control
de dispositivo.

## Ambientes y `dart-define`

La configuracion base vive en `lib/core/config/app_environment.dart`.

- `APP_FLAVOR`
  - acepta `dev`, `qa` o `prod`
- `IAM_BASE_URL`
  - override directo para IAM
- `IAM_BASE_URL_DEV`
  - URL por defecto del ambiente dev
- `IAM_BASE_URL_QA`
  - URL por defecto del ambiente qa
- `IAM_BASE_URL_PROD`
  - URL por defecto del ambiente prod
- `IAM_APP_CODE`
  - codigo de aplicacion que viaja con auth

Ejemplos:

```bash
flutter run --dart-define=APP_FLAVOR=dev
flutter run --dart-define=APP_FLAVOR=qa --dart-define=IAM_BASE_URL_QA=https://qa.mi-backend.com/iam
flutter run --dart-define=IAM_BASE_URL=http://10.0.32.46:8081/iam --dart-define=IAM_APP_CODE=PLAT_SERV
```

## Nota importante

No todo archivo necesita mucha logica. Algunos existen para que el modulo sea:

- mantenible
- testeable
- facil de leer
- facil de cambiar cuando la API evolucione
