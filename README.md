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

Por padrão o app sobe em modo demo: login fake (qualquer credencial funciona)
e sem chamadas ao Firebase. Para usar Firebase de verdade:

1. Rodar `flutterfire configure`
2. Substituir os placeholders em `lib/app/config/firebase_options_dev.dart` e
   `firebase_options_prod.dart`
3. Em `lib/app/bootstrap.dart`, mudar `static const bool demoMode = true` para
   `false`

## Status

- [x] Setup inicial, navegação, theme, splash, login, onboarding
- [x] Módulo de planos com 12 planos mockados
- [x] Calendário com plano ativo
- [x] Persistência local (SharedPreferences) do plano selecionado
- [x] Recomendação automática de plano baseada no perfil
- [x] Progresso, sequência de dias e histórico de treinos
- [x] Configurações (tema, unidade de distância, frequência semanal)
- [x] Zonas de ritmo personalizadas pelo teste de 3 km
- [ ] Dados separados por usuário (hoje plano, progresso e perfil são
      globais no aparelho)
- [ ] Integração real com Firebase
