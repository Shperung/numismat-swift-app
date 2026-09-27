//
//  HomeView.swift
//  Numismat
//
//  Аналог src/app/index.tsx в Expo:
//
//    export default function HomeScreen() {
//      const { coins, loading, error } = useCoins();
//      return (
//        <ScrollView contentContainerStyle={{ padding: 16 }}>
//          <Text selectable style={{ fontFamily: 'Menlo', fontSize: 12 }}>
//            {loading ? 'Завантаження...' : error ?? JSON.stringify(coins, null, 2)}
//          </Text>
//        </ScrollView>
//      );
//    }
//

// `import SwiftUI` ≈ `import { Text, View } from 'react-native'`,
// але одразу імпортує весь UI-фреймворк (Text, VStack, TabView, …).
import SwiftUI

// `struct HomeView: View` ≈ `export default function HomeScreen()`.
// Імпорт не потрібен: усі файли одного таргету бачать одне одного (як один модуль).
struct HomeView: View {
    // ≈ `const store = useCoins()` (тобто `useContext(CoinsContext)`).
    // `@Environment(CoinsStore.self)` бере стор, який поклали вище через `.environment(coinsStore)`
    // у NumismatApp.swift. `CoinsStore.self` — сам тип як значення (≈ передати `CoinsContext`).
    // Якщо провайдера вище немає — падіння (в React був би дефолт з `createContext(...)`).
    @Environment(CoinsStore.self) private var store

    // `body` ≈ `return (...)` у компоненті — опис того, що рендерити.
    // Перераховується, коли змінюються `store.loading` / `store.error` / `store.coins`.
    var body: some View {
        // ≈ `<ScrollView>`. Скрол у SwiftUI не вмикається сам — як і в RN, потрібен ScrollView.
        ScrollView {
            // Той самий вираз, що в Expo: `loading ? '...' : error ?? JSON.stringify(...)`.
            // Тернарник `? :` і `??` у Swift працюють так само, як у TS.
            Text(store.loading ? "Завантаження..." : store.error ?? json(store.coins))
                // ≈ style={{ fontFamily: 'Menlo', fontSize: 12 }}; `.monospaced` — системний моноширинний шрифт.
                .font(.system(size: 12, design: .monospaced))
                // ≈ проп `selectable` у <Text>.
                .textSelection(.enabled)
                // ≈ { width: '100%', alignItems: 'flex-start' }: розтягнути на всю ширину
                // і притиснути текст вліво (інакше SwiftUI центрує його).
                .frame(maxWidth: .infinity, alignment: .leading)
                // ≈ contentContainerStyle={{ padding: 16 }}.
                .padding(16)
        }
    }

    // ≈ `JSON.stringify(coins, null, 2)`; `.prettyPrinted` — відступи, як третій аргумент `2`.
    // `JSONSerialization` повертає байти (`Data`, ≈ Uint8Array), тому потім перетворюємо їх у рядок.
    //
    // Перевірка `isValidJSONObject` потрібна, бо на значеннях, яких немає в JSON
    // (напр. Firestore `Timestamp`), `JSONSerialization` не кидає помилку, а валить додаток.
    // - `guard ... else { return ... }` ≈ ранній вихід `if (!ok) return ...;`.
    // - `try?` ≈ `try { ... } catch { return null }` одним словом: при помилці буде `nil`.
    // - `String(describing:)` — запасний варіант, ≈ `String(value)`.
    private func json(_ value: Any) -> String {
        guard JSONSerialization.isValidJSONObject(value),
              let data = try? JSONSerialization.data(withJSONObject: value, options: .prettyPrinted)
        else { return String(describing: value) }
        return String(decoding: data, as: UTF8.self)
    }
}

// Живий прев'ю в Xcode (Canvas) — аналогів у RN немає.
// Прев'ю не проходить через NumismatApp, тому стор передаємо вручну
// (≈ обгорнути компонент у провайдер у Storybook). Firebase тут не викликається —
// стор порожній, тож прев'ю показує "Завантаження...".
#Preview {
    HomeView()
        .environment(CoinsStore())
}
