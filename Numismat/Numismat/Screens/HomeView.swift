//
//  HomeView.swift
//  Numismat
//
//  Аналог src/app/(tabs)/index.tsx в Expo:
//
//    export default function HomeScreen() {
//      const { coins, loading, error } = useCoins();
//      if (loading || error) {
//        return <Text style={{ padding: 16 }}>{error ?? 'Завантаження...'}</Text>;
//      }
//      return (
//        <FlatList
//          data={coins}
//          keyExtractor={(coin) => coin.id}
//          renderItem={({ item }) => <CoinCard coin={item} />}
//          contentContainerStyle={{ padding: 16, gap: 12 }}
//        />
//      );
//    }
//

// `import SwiftUI` ≈ `import { Text, View } from 'react-native'`,
// але одразу імпортує весь UI-фреймворк (Text, VStack, TabView, …).
import SwiftUI

// `struct HomeView: View` ≈ `export default function HomeScreen()`.
// Імпорт не потрібен: усі файли одного таргету бачать одне одного (як один модуль).
struct HomeView: View {
    // ≈ `const { coins, loading, error } = useCoins();`
    // `@Environment(CoinsStore.self)` бере стор, який поклали вище через `.environment(coinsStore)`
    // у NumismatApp.swift. Якщо провайдера вище немає — падіння (в React був би дефолт з `createContext(...)`).
    @Environment(CoinsStore.self) private var store

    var body: some View {
        // `NavigationStack` ≈ `<Stack>` з src/app/_layout.tsx: дає заголовок зверху і стек екранів.
        //
        // Різниця зі структурою Expo: там Stack — корінь, а таби всередині нього, тому екран
        // монети відкривається ПОВЕРХ табів (tab bar зникає). В iOS прийнято навпаки: свій
        // NavigationStack усередині кожного таба, тож екран монети відкривається всередині
        // "Головної", tab bar лишається, а при перемиканні табів стек кожного зберігається.
        NavigationStack {
            // `Group` — "невидимий" контейнер (≈ `<>...</>` фрагмент), щоб навісити модифікатори
            // (`.navigationTitle` нижче) на будь-яку з гілок `if`.
            Group {
                // ≈ `if (loading || error) return <Text ...>`. У SwiftUI не можна "рано повернути"
                // з `body`, тому гілки пишуться через `if / else` прямо в описі UI.
                if store.loading || store.error != nil {
                    Text(store.error ?? "Завантаження...")
                        .padding(16)
                } else {
                    // `ScrollView` + `LazyVStack` ≈ `<FlatList>`: "Lazy" — рендерить лише те,
                    // що видно на екрані (як віртуалізація у FlatList). Звичайний `VStack` створив би все одразу.
                    // Є ще `List` (≈ FlatList зі стилем iOS-таблиці), але для власних карток простіше так.
                    ScrollView {
                        // `spacing: 12` ≈ `gap: 12`.
                        LazyVStack(spacing: 12) {
                            // `ForEach(store.coins)` ≈ `data={coins}` + `renderItem`.
                            // `keyExtractor` не потрібен: `Coin` — `Identifiable`, ключ береться з `coin.id`.
                            ForEach(store.coins) { coin in
                                // `NavigationLink(value:)` ≈ `<Link href={`/coin/${coin.id}`} asChild>`:
                                // тап кладе `coin` у стек, а який екран показати — вирішує
                                // `.navigationDestination` нижче (≈ таблиця маршрутів у `<Stack>`).
                                NavigationLink(value: coin) {
                                    CoinCard(coin: coin)
                                }
                                // Без цього весь текст у посиланні стане синім (як у кнопки).
                                // `.plain` ≈ `<Pressable>` без стилів — лише обробка тапу.
                                .buttonStyle(.plain)
                            }
                        }
                        // ≈ contentContainerStyle={{ padding: 16 }}.
                        .padding(16)
                    }
                    // Сірий фон під білими картками (як фон екрана за замовчуванням у React Navigation).
                    .background(Color(.systemGroupedBackground))
                }
            }
            // ≈ `title: 'Головна'` у `<Tabs.Screen>`; тут великий заголовок зліва — стиль iOS.
            .navigationTitle("Головна")
            // ≈ `<Stack.Screen name="coin/[id]" />`: "коли в стек потрапляє `Coin` — показати CoinView".
            // Маршрут визначається типом значення, а не рядком-URL.
            .navigationDestination(for: Coin.self) { coin in
                CoinView(coin: coin)
            }
        }
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
