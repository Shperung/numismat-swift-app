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
Hello World запущено в симуляторі. Додано bottom tabs (Головна / Список / Інфо) через `TabView` + `Tab`
у `ContentView.swift`, кожен таб — порожній екран з назвою (`HomeView`, `ListView`, `InfoView`),
так само як в Expo-проєкті. Далі — розбір `NumismatApp.swift` і `ContentView.swift`.
Підключено Firestore (як в Expo / Kotlin): колекція `coins` читається через `CoinsStore` і виводиться
на Головній як JSON. Працює в симуляторі (з `GoogleService-Info.plist` iOS-застосунку з Firebase Console).
У змінених файлах — докладні коментарі з аналогіями Expo. Головна — список карток `CoinCard`
(`LazyVStack`), тап відкриває екран монети `CoinView` (`NavigationStack` усередині таба).
«Список» — фільтр за країною (як в Expo): `Picker` країн (з `CountriesStore`), при старті випадкова країна,
монети запитуються з Firestore через `whereField`.
Крок 1 (основи Swift) поки пропущено — пояснюємо синтаксис по ходу.

## Журнал (що вивчено / зроблено)
- Встановлено Xcode 27.0.
- Створено проєкт Numismat (File → New → Project… → Choose Template… → iOS App; швидкий пункт "App" створює
  мультиплатформну чернетку без налаштувань — не використовувати).
- Іконка додатку: ті самі монетки, що й на Android, PNG 1024×1024 у `Assets.xcassets/AppIcon.appiconset`
  (варіанти light, dark, tinted).
- Bottom tabs: `TabView { Tab("Головна", systemImage: "house.fill") { HomeView() } ... }` ≈ Expo `<Tabs>` +
 `<Tabs.Screen>`; іконки — SF Symbols (вбудовані, аналог Ionicons). Проєкт використовує synchronized
 groups — нові `.swift` файли в `Numismat/Numismat/` Xcode підхоплює сам.
- Firebase Firestore (спільний проєкт `tetiana-redko`): SPM-пакет `firebase-ios-sdk` (продукт `FirebaseFirestore`,
 ≈ `npm i firebase`). iOS SDK, на відміну від Android, не приймає web App ID (падає, якщо App ID не `1:…:ios:…`),
 тому конфіг — стандартний `GoogleService-Info.plist` у `Numismat/Numismat/` (у `.gitignore`, ≈ `.env.local`).
 `NumismatApp.init` → `FirebaseApp.configure()`; `FetchCollection.swift` (`async throws`, `try await getDocuments()`);
 `CoinsStore.swift` (`@Observable`, аналог Context-провайдера) передається через `.environment(...)` + `.task { load() }`;
 `HomeView` — `@Environment(CoinsStore.self)`, JSON через `JSONSerialization`.
- Countries: `CountriesStore.swift` (копія `CoinsStore` для колекції `countries`, ≈ `CountriesViewModel` у Kotlin;
 в Expo — локальний `useState` + `useEffect` у `list.tsx`), підключено в `NumismatApp` (`.environment` + `.task`),
 `ListView` — `@Environment(CountriesStore.self)`, JSON як на Головній.
- Структура папок (як в Expo / Kotlin): `Screens/` (≈ `src/app/`), `Stores/` (≈ `src/providers/`), `Lib/` (≈ `src/lib/`);
 у корені — `NumismatApp.swift`, `ContentView.swift`, `GoogleService-Info.plist`, `Assets.xcassets`.
 Завдяки synchronized groups `project.pbxproj` правити не треба; імпорти не змінюються (увесь таргет — один модуль).
- Картки й екран монети: `Models/Coin.swift` (`struct Coin: Identifiable, Hashable`, init зі словника Firestore
 у `extension`, щоб лишився memberwise init; `value` — `String`, бо у Firestore рядок), `CoinsStore.coins: [Coin]`.
 `Components/CoinPhoto.swift` (`AsyncImage` ≈ `expo-image`, без дискового кешу), `Components/CoinCard.swift`,
 `Screens/CoinView.swift`. Навігація: `NavigationStack` у `HomeView` + `NavigationLink(value: coin)` +
 `.navigationDestination(for: Coin.self)` (≈ `<Link href>` + `<Stack.Screen name="coin/[id]">`); передається вся
 монета, а не `id`. На відміну від Expo (Stack над табами) стек усередині таба — tab bar лишається (iOS-стиль).
- Фільтр за країною: `countries/{id}` = `{ name_ua, name_en, flag }`, `coin.country` = id країни.
 `Models/Country.swift` (`name_ua` → `nameUa`), `CountriesStore.countries: [Country]`,
 `Lib/FetchCoinsByCountry.swift` (`.whereField("country", isEqualTo:)` ≈ `where('country', '==', ...)`).
 `ListView`: локальні `@State` (`country`, `coins`, `error`), `Picker(selection: $country)` зі стилем `.menu`
 (≈ `@expo/ui` Picker, який на iOS і є SwiftUI `Picker`), `.onChange(of: store.countries, initial: true)` →
 випадкова країна, `.task(id: country)` ≈ `useEffect(..., [country])` з автоскасуванням; перевірка
 `Task.isCancelled` після `await` ≈ прапорець `active` проти гонки відповідей.
