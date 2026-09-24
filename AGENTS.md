# Numismat — персональна колекція монет (Swift / iOS)

## Мета проєкту
Навчальний проєкт: вивчити Swift з нуля, будуючи iOS-додаток для обліку
особистої колекції монет. Починаємо від Hello World і рухаємося малими кроками.
Паралельно той самий додаток робиться на Kotlin: `/Users/viktor_kravchuk/traning/numismat-kotlin-app`
(кроки плану синхронізовані між проєктами).

## Про автора
- Великий досвід у React Native / TypeScript.
- Swift та нативний iOS не знає — вчить по ходу.
- Паралельно вчить Kotlin — корисно порівнювати Swift ↔ Kotlin.

## Як працюємо (правила для AI)
- НЕ генерувати готовий проєкт чи великі шматки коду за раз — лише малі кроки.
- Кожну нову концепцію пояснювати через аналогію з React Native / TypeScript (і, де доречно, з Kotlin).
- Код мінімальний і простий, без передчасних абстракцій та зайвих бібліотек.
- Перед новою темою коротко пояснити "навіщо", потім "як".
- Мова спілкування — українська.
- Після завершення кроку оновлювати розділи "План", "Поточний стан" і "Журнал" у цьому файлі.

## Функціональність додатку (цільова)
- Список монет колекції.
- Додавання / редагування / видалення монети.
- Поля монети: назва, країна, рік, номінал, метал, стан (grade), ціна покупки,
  дата придбання, нотатки, фото аверсу та реверсу.
- Деталі монети на окремому екрані.
- Пошук і фільтри (країна, рік, метал).
- Статистика колекції (кількість, загальна вартість, розподіл за країнами).
- Локальне збереження даних (офлайн, без бекенду).
- Можливо пізніше: експорт/імпорт, інтеграція з каталогом Numista API.

## Стек
- Мова: Swift
- UI: SwiftUI
- Навігація: `NavigationStack`
- Стан / логіка: `@State`, `@Observable`, async/await
- База даних: SwiftData
- Зображення: `PhotosPicker`, `AsyncImage`
- Збірка / залежності: Xcode project, Swift Package Manager (за потреби)
- IDE: Xcode
- Тестовий пристрій: iOS Simulator (пізніше — реальний iPhone)

## Шпаргалка React Native → Swift/iOS (→ Kotlin)
| React Native            | Swift / SwiftUI                     | Kotlin / Compose                 |
|-------------------------|-------------------------------------|----------------------------------|
| Функціональний компонент | `struct ... : View` + `body`        | `@Composable` функція            |
| `useState`              | `@State`                            | `remember { mutableStateOf() }`  |
| `useEffect`             | `.onAppear` / `.task`               | `LaunchedEffect`                 |
| `FlatList`              | `List` / `LazyVStack`               | `LazyColumn`                     |
| `style` / flexbox       | модифікатори, `VStack`/`HStack`/`ZStack` | `Modifier`, `Column`/`Row`/`Box` |
| React Navigation        | `NavigationStack`                   | Navigation Compose               |
| Redux / Zustand         | `@Observable` клас                  | `ViewModel` + `StateFlow`        |
| `async/await`           | `async/await`, `Task`               | корутини, `suspend`              |
| SQLite / AsyncStorage   | SwiftData / `UserDefaults`          | Room / DataStore                 |
| `package.json`          | `.xcodeproj` + SPM                  | `build.gradle.kts`               |

## План
0. [x] Середовище: Xcode + iOS Simulator
1. [ ] Основи Swift: let/var, optionals, struct, closures, колекції
2. [ ] Hello World на SwiftUI, розбір структури проєкту
3. [ ] Основи SwiftUI: верстка, модифікатори, стан (лічильник)
4. [ ] Модель `Coin` + список монет із захардкодженими даними (`List`)
5. [ ] Форма додавання монети, `@Binding`
6. [ ] Навігація: Список → Деталі → Додати
7. [ ] `@Observable` модель стану
8. [ ] SwiftData: збереження між запусками
9. [ ] Фото монет (камера/галерея)
10. [ ] Пошук, фільтри, статистика

## Поточний стан
Крок 2 — проєкт створено з шаблону iOS App (SwiftUI) у `Numismat/`, Bundle ID `com.example.Numismat`.
Hello World запущено в симуляторі. Далі — розбір `NumismatApp.swift` і `ContentView.swift`.
Крок 1 (основи Swift) поки пропущено — пояснюємо синтаксис по ходу.

## Журнал (що вивчено / зроблено)
- Встановлено Xcode 27.0.
- Створено проєкт Numismat (File → New → Project… → Choose Template… → iOS App; швидкий пункт "App" створює
  мультиплатформну чернетку без налаштувань — не використовувати).
- Іконка додатку: ті самі монетки, що й на Android, PNG 1024×1024 у `Assets.xcassets/AppIcon.appiconset`
  (варіанти light, dark, tinted).
