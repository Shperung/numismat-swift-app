//
//  NumismatApp.swift
//  Numismat
//
//  Created by Viktor Kravchuk on 24.09.2026.
//
//  Точка входу додатку. В Expo її роль ділять між собою:
//  - `expo-router/entry` (що запускати першим),
//  - src/lib/firebase.ts (ініціалізація Firebase при імпорті модуля),
//  - src/app/_layout.tsx (обгортка `<CountriesProvider>` навколо навігації).
//

// `import FirebaseCore` ≈ `import { initializeApp } from 'firebase/app'`.
// Модуль приходить із SPM-пакета firebase-ios-sdk (≈ пакет `firebase` у package.json).
import FirebaseCore
import SwiftUI

// `@main` — «запускати звідси», як `"main": "expo-router/entry"` у package.json.
@main
struct NumismatApp: App {
    // `init()` ≈ constructor: викликається один раз при старті додатку, ще до першого рендеру.
    //
    // В Expo:
    //   const app = initializeApp({ apiKey: process.env.EXPO_PUBLIC_FIREBASE_API_KEY, ... });
    // Тут без аргументів: SDK сам читає ключі з GoogleService-Info.plist, який лежить поруч
    // із .swift файлами і потрапляє в бандл додатку (≈ .env.local, що вшивається в JS-бандл).
    // Якщо файлу немає — додаток падає одразу на цьому рядку (помилка "could not find ... plist").
    init() {
        FirebaseApp.configure()
    }

    // В Expo стан живе всередині провайдера:
    //   const [state, setState] = useState<CountriesState>(...)
    // Тут створюємо стор один раз і тримаємо в `@State`, щоб SwiftUI не створював його заново
    // при кожному перерахунку `body` (як `useState` зберігає значення між рендерами).
    // `private` — видно лише в цьому struct (≈ змінна, не експортована з модуля).
    @State private var countriesStore = CountriesStore()

    // `body` — що показати. `WindowGroup` — вікно додатку (≈ корінь, який рендерить Expo Router).
    var body: some Scene {
        WindowGroup {
            // `ContentView` — таби (≈ `<Tabs>` з _layout.tsx).
            ContentView()
                // ≈ `<CountriesProvider>{children}</CountriesProvider>`:
                // стор стає доступним усім вкладеним view через `@Environment(CountriesStore.self)`
                // (≈ `useContext(CountriesContext)`). Модифікатори в SwiftUI "обгортають" view,
                // тож `.environment` тут — це і є провайдер навколо табів.
                .environment(countriesStore)
                // ≈ `useEffect(() => { fetchCollection('countries')... }, [])` у провайдері.
                // `.task` запускає async-код, коли view з'являється, і сам скасовує його,
                // коли view зникає (в RN для цього треба повертати cleanup / AbortController).
                // `await` — як у JS: чекаємо на асинхронну функцію.
                .task { await countriesStore.load() }
        }
    }
}
