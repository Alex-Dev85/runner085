# Runner085

Aplicativo Android de treinamento de corrida, focado em planos estruturados —
do iniciante ao avançado, para 5 km, 10 km, meia maratona e maratona. Sem GPS,
sem rastreamento em tempo real: só os planos, treinos e zonas que você precisa
para evoluir.

## Stack

- **Flutter** (Material 3, Dark mode)
- **Riverpod** para state management
- **GoRouter** para navegação declarativa
- **Firebase** (Auth + Firestore) — opcional, ativável via `bootstrap.dart`
- **Clean Architecture** com organização **feature-first**

## Arquitetura

Cada feature segue a separação `presentation / domain / data`:

```
lib/
├── app/                 # Configuração global (router, theme, bootstrap, env)
├── core/                # Camada compartilhada
│   ├── data/            # Datasources e repositórios concretos
│   ├── domain/          # Entidades, falhas, repositórios abstratos
│   ├── providers/       # Providers do core (auth)
│   ├── services/        # Connectivity, storage local
│   ├── utils/           # Result, extensions, constants
│   └── widgets/         # Loading, error widget
└── features/
    ├── auth/
    ├── calendar/
    ├── home/
    ├── onboarding/
    ├── plans/           # Catálogo completo (12 planos mockados)
    │   ├── data/
    │   ├── domain/
    │   └── presentation/
    ├── profile/
    ├── splash/
    └── training/
```

## Catálogo de planos

12 planos disponíveis sempre, independente do nível atual do usuário:

| Distância | Iniciante | Intermediário | Avançado |
|-----------|-----------|---------------|----------|
| 5 km      | 8 sem, 3x/sem | 6 sem, 4x/sem | 8 sem, 5x/sem |
| 10 km     | 10 sem, 4x/sem | 8 sem, 4x/sem | 10 sem, 5x/sem |
| 21 km     | 12 sem, 4x/sem | 10 sem, 4x/sem | 12 sem, 5x/sem |
| 42 km     | 16 sem, 4x/sem | 14 sem, 4x/sem | 16 sem, 5x/sem |

## Como rodar

Pré-requisitos: Flutter 3.19+, Android SDK, emulador ou device com debug USB.

```bash
flutter pub get
dart run build_runner build --delete-conflicting-outputs
flutter run                          # ambiente DEV (default)
flutter run -t lib/main_prod.dart    # ambiente PROD
```

### Modo demo (sem Firebase)

Por padrão o app usa o Firebase (projeto dev em `firebase_options_dev.dart`).
Para testar a interface sem backend, com login fake (qualquer credencial
funciona) e dados só no aparelho:

```bash
flutter run --dart-define=DEMO_MODE=true
```

### Assinatura de release (Android)

1. Gerar a chave de upload (guarde o arquivo e as senhas em local seguro —
   sem eles não dá para publicar atualizações):

   ```bash
   keytool -genkey -v -keystore android/upload-keystore.jks -keyalg RSA -keysize 2048 -validity 10000 -alias upload
   ```

2. Copiar `android/key.properties.example` para `android/key.properties` e
   preencher as senhas (ambos os arquivos `.jks` e `key.properties` ficam
   fora do git).
3. `flutter build appbundle -t lib/main_prod.dart`

Sem `key.properties` o release é assinado com a chave de debug (serve para
testar, mas a Play Store recusa) e o Gradle mostra um aviso.

## Status

- [x] Setup inicial, navegação, theme, splash, login, onboarding
- [x] Módulo de planos com 12 planos mockados
- [x] Calendário com plano ativo
- [x] Persistência local (SharedPreferences) do plano selecionado
- [x] Recomendação automática de plano baseada no perfil
- [x] Progresso, sequência de dias e histórico de treinos
- [x] Configurações (tema, unidade de distância, frequência semanal)
- [x] Zonas de ritmo personalizadas pelo teste de 3 km
- [x] Integração com Firebase (projeto dev)
- [x] Dados e preferências separados por usuário (Firestore)
- [ ] Firebase de produção (`firebase_options_prod.dart`)
- [ ] Exclusão de conta e política de privacidade
