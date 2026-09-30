//
//  HomeView.swift
//  Numismat
//
//  Аналог src/app/(tabs)/index.tsx в Expo — одна випадкова монета:
//
//    const { countries, error: countriesError } = useCountries();
//    const [coin, setCoin] = useState<Coin | null>();
//    const [error, setError] = useState<string | null>(null);
//
//    useEffect(() => {
//      const country = pickRandom(countries);
//      if (!country) return;
//      fetchCoinsByCountry(country.id)
//        .then((coins) => setCoin(pickRandom(coins) ?? null))
//        .catch((e) => setError(String(e)));
//    }, [countries]);
//
//    const message = countriesError ?? error ?? (coin === null ? 'Монет не знайдено' : 'Завантаження...');
//    return coin ? <CoinDetails coin={coin} /> : <Text style={{ padding: 16 }}>{message}</Text>;
//

// `import SwiftUI` ≈ `import { Text, View } from 'react-native'`,
// але одразу імпортує весь UI-фреймворк (Text, VStack, TabView, …).
import SwiftUI

// `struct HomeView: View` ≈ `export default function HomeScreen()`.
// Імпорт не потрібен: усі файли одного таргету бачать одне одного (як один модуль).
struct HomeView: View {
    // ≈ `const { countries, error: countriesError } = useCountries();`
    @Environment(CountriesStore.self) private var store

    // В Expo `coin` має три стани: `undefined` — вантажиться, `null` — монет немає, `Coin` — є.
    // У Swift optional має лише два (`nil` або значення), тому "монет немає" — окремий прапорець.
    @State private var coin: Coin?
    @State private var notFound = false
    @State private var error: String?

    var body: some View {
        // `NavigationStack` тут лише заради заголовка "Головна" (≈ header у `<Tabs>`); переходів з Головної немає.
        NavigationStack {
            Group {
                // ≈ `coin ? <CoinDetails coin={coin} /> : <Text>{message}</Text>`.
                if let coin {
                    CoinDetails(coin: coin)
                } else {
                    // ≈ `countriesError ?? error ?? (coin === null ? 'Монет не знайдено' : 'Завантаження...')`.
                    Text(store.error ?? error ?? (notFound ? "Монет не знайдено" : "Завантаження..."))
                        .padding(16)
                }
            }
            .navigationTitle("Головна")
        }
        // ≈ `useEffect(() => {...}, [countries])`: `.task(id:)` запускається при появі екрана
        // і щоразу, коли змінюється `store.countries` (напр. коли країни щойно завантажились).
        .task(id: store.countries) {
            // ≈ `const country = pickRandom(countries); if (!country) return;`.
            // Хелпер `pickRandom` не потрібен: у Swift є вбудований `randomElement()`,
            // який повертає `nil` для порожнього масиву (≈ `T | undefined`).
            guard let country = store.countries.randomElement() else { return }
            do {
                // ≈ `.then((coins) => setCoin(pickRandom(coins) ?? null))`.
                coin = try await fetchCoinsByCountry(country.id).randomElement()
                notFound = coin == nil
            } catch {
                // ≈ `.catch((e) => setError(String(e)))`.
                self.error = String(describing: error)
            }
        }
    }
}

// Живий прев'ю в Xcode (Canvas) — аналогів у RN немає.
// Прев'ю не проходить через NumismatApp, тому стор передаємо вручну
// (≈ обгорнути компонент у провайдер у Storybook). Стор порожній, тож прев'ю показує "Завантаження...".
#Preview {
    HomeView()
        .environment(CountriesStore())
}
