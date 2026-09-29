//
//  CoinsStore.swift
//  Numismat
//
//  Аналог src/providers/coins-provider.tsx в Expo (і CoinsViewModel.kt у Kotlin).
//
//  В Expo для спільного стану потрібні 3 частини:
//    1) тип + `createContext`         → тут це сам клас `CoinsStore`;
//    2) `CoinsProvider` з `useState`   → `.environment(coinsStore)` у NumismatApp.swift;
//    3) хук `useCoins()`               → `@Environment(CoinsStore.self)` у HomeView.swift.
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
class CoinsStore {
    // ≈ type CoinsState = { coins: Coin[]; loading: boolean; error: string | null }
    //   + початкове значення `{ coins: [], loading: true, error: null }`.
    // `var` — змінна властивість (≈ `let` у JS); тип виводиться з початкового значення.
    // `[Coin]` ≈ `Coin[]`. Раніше тут був "сирий" `[[String: Any]]` для виводу JSON.
    var coins: [Coin] = []
    var loading = true
    // `String?` — optional ≈ `string | null`; без значення за замовчуванням дорівнює `nil` (≈ `null`).
    var error: String?

    // ≈ тіло useEffect у провайдері:
    //   fetchCollection('coins')
    //     .then((coins) => setState({ coins, loading: false, error: null }))
    //     .catch((e) => setState({ coins: [], loading: false, error: String(e) }));
    // Замість `.then/.catch` — `do { try await ... } catch { ... }` (≈ try/catch з await у JS).
    func load() async {
        do {
            // ≈ `coins as Coin[]`: кожен словник перетворюємо на `Coin` через `Coin(_ data:)`.
            coins = try await fetchCollection("coins").map { Coin($0) }
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
