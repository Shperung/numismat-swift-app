//
//  CountriesStore.swift
//  Numismat
//
//  Аналог src/providers/countries-provider.tsx в Expo (і CountriesViewModel.kt у Kotlin).
//
//  В Expo для спільного стану потрібні 3 частини:
//    1) тип + `createContext`             → тут це сам клас `CountriesStore`;
//    2) `CountriesProvider` з `useState`   → `.environment(countriesStore)` у NumismatApp.swift;
//    3) хук `useCountries()`               → `@Environment(CountriesStore.self)` у HomeView / ListView.
//
//  `CoinsProvider` з Expo тут не потрібен: там він лише для пошуку монети за `id` на екрані
//  `coin/[id]`, а в SwiftUI екран монети отримує готовий `Coin` (див. CoinView.swift).
//

// Фреймворк з макросом `@Observable` (частина Swift, окремо встановлювати не треба).
import Observation

// `@Observable` ≈ Zustand/MobX-стор: SwiftUI сам відстежує, які властивості читає кожен view,
// і ре-рендерить лише його, коли саме ці властивості змінились. Не треба ні `setState`,
// ні селекторів — достатньо просто присвоїти нове значення (`loading = false`).
//
// `class`, а не `struct`: стор має бути одним спільним об'єктом (передається за посиланням,
// як об'єкт у JS). `struct` копіюється при передачі — кожен екран мав би свою копію.
@Observable
class CountriesStore {
    // ≈ type CountriesState = { countries: Country[]; loading: boolean; error: string | null }
    //   + початкове значення `{ countries: [], loading: true, error: null }`.
    // `var` — змінна властивість (≈ `let` у JS); тип виводиться з початкового значення.
    var countries: [Country] = []
    var loading = true
    // `String?` — optional ≈ `string | null`; без значення за замовчуванням дорівнює `nil` (≈ `null`).
    var error: String?

    // ≈ тіло useEffect у провайдері:
    //   fetchCollection('countries')
    //     .then((countries) => setState({ countries, loading: false, error: null }))
    //     .catch((e) => setState({ countries: [], loading: false, error: String(e) }));
    // Замість `.then/.catch` — `do { try await ... } catch { ... }` (≈ try/catch з await у JS).
    func load() async {
        do {
            // ≈ `countries as Country[]`: кожен словник перетворюємо на `Country` через `Country(_ data:)`.
            countries = try await fetchCollection("countries").map { Country($0) }
        } catch {
            // У `catch` без імені помилка доступна як `error` (≈ `catch (error)`).
            // Вона "затіняє" властивість з тим самим ім'ям, тому до властивості — через `self.`
            // (≈ `this.error`). `String(describing:)` ≈ `String(e)`.
            self.error = String(describing: error)
        }
        // Спільне для обох гілок (≈ `.finally(() => ...)`).
        loading = false
    }
}
