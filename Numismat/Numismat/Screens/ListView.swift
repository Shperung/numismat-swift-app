//
//  ListView.swift
//  Numismat
//
//  Аналог src/app/(tabs)/list.tsx в Expo — монети з фільтром за країною.
//
//  Логіка та сама:
//  1) країни завантажені → вибрати випадкову;
//  2) вибрана країна змінилась → запитати її монети з Firestore (`where`);
//  3) зверху — Picker країн, нижче — картки монет або "Монет цієї країни немає".
//

import SwiftUI

// Назва `ListView`, а не `List`, бо `List` — вбудований компонент SwiftUI (≈ FlatList).
struct ListView: View {
    // Країни беремо зі спільного стора (в Expo — локальний `useState<Country[]>` + `useEffect`).
    @Environment(CountriesStore.self) private var store

    // Локальний стан екрана ≈ `useState` у list.tsx:
    //   const [country, setCountry] = useState<string>();
    //   const [coins, setCoins] = useState<Coin[]>([]);
    //   const [error, setError] = useState<string | null>(null);
    // `String?` без значення = `nil` ≈ `undefined`, поки країну не вибрано.
    @State private var country: String?
    @State private var coins: [Coin] = []
    @State private var error: String?

    var body: some View {
        // Свій стек навігації, як у HomeView, — щоб з картки відкривався екран монети.
        NavigationStack {
            Group {
                // ≈ `if (error) return <Text>{error}</Text>;`
                // `if let error = ...` — розпакувати optional; помилка або стора країн, або запиту монет.
                if let error = store.error ?? error {
                    Text(error).padding(16)
                // ≈ `if (!country) return <Text>Завантаження...</Text>;`
                } else if country == nil {
                    Text("Завантаження...").padding(16)
                } else {
                    // ≈ <FlatList ... ListHeaderComponent={<Picker/>} ListEmptyComponent={<Text/>} />.
                    // У SwiftUI "header" і "empty" — просто елементи в тому ж стеку, без спеціальних пропсів.
                    ScrollView {
                        LazyVStack(spacing: 12) {
                            picker

                            if coins.isEmpty {
                                // ≈ ListEmptyComponent.
                                Text("Монет цієї країни немає")
                                    .frame(maxWidth: .infinity, alignment: .leading)
                            } else {
                                // Той самий список карток, що й на Головній.
                                ForEach(coins) { coin in
                                    NavigationLink(value: coin) {
                                        CoinCard(coin: coin)
                                    }
                                    .buttonStyle(.plain)
                                }
                            }
                        }
                        .padding(16)
                    }
                    .background(Color(.systemGroupedBackground))
                }
            }
            .navigationTitle("Список")
            .navigationDestination(for: Coin.self) { coin in
                CoinView(coin: coin)
            }
        }
        // Крок 1 ≈ `setCountry(list[Math.floor(Math.random() * list.length)]?.id)` після завантаження країн.
        // `.onChange(of:)` ≈ `useEffect(() => {...}, [store.countries])`; `initial: true` — викликати
        // і одразу при появі екрана (як useEffect на першому рендері), бо країни могли вже завантажитись.
        // `randomElement()` — випадковий елемент масиву (або `nil`, якщо масив порожній).
        .onChange(of: store.countries, initial: true) {
            country = store.countries.randomElement()?.id
        }
        // Крок 2 ≈ `useEffect(() => { fetchCoinsByCountry(country)... }, [country])`.
        // `.task(id: country)` перезапускається щоразу, коли змінюється `country` (≈ масив залежностей),
        // і сам скасовує попередній запуск (≈ cleanup `return () => { active = false }`).
        .task(id: country) {
            // ≈ `if (!country) return;` + водночас розпаковує `String?` у `String`.
            guard let country else { return }
            do {
                let result = try await fetchCoinsByCountry(country)
                // ≈ `active && setCoins(data)`. Скасування в Swift лише "позначає" задачу:
                // запит Firestore все одно доходить до кінця, тож перевіряємо вручну, щоб відповідь
                // для старої країни не перезаписала монети нової (та сама гонка, що й у RN).
                guard !Task.isCancelled else { return }
                coins = result
            } catch {
                guard !Task.isCancelled else { return }
                self.error = String(describing: error)
            }
        }
    }

    // Винесений шматок UI — обчислювана властивість (≈ `const picker = <Picker .../>` у тілі компонента).
    // `some View` — "якийсь view", конкретний тип виводить компілятор.
    private var picker: some View {
        // ≈ <Picker selectedValue={country} onValueChange={setCountry}>.
        // `$country` — Binding: пара "значення + сеттер" в одному (≈ `value` + `onChange` разом).
        // До речі, `Picker` з `@expo/ui` на iOS — це і є цей SwiftUI `Picker`, загорнутий у React-компонент.
        // "Країна" — підпис для VoiceOver; у стилі `.menu` на екрані його не видно.
        Picker("Країна", selection: $country) {
            // ≈ countries.map((c) => <Picker.Item key={c.id} label={`${c.flag} ${c.name_ua}`} value={c.id} />).
            ForEach(store.countries) { c in
                Text("\(c.flag) \(c.nameUa)")
                    // `.tag` ≈ `value`. Тип тегу має збігатися з типом `country` (`String?`),
                    // тому `as String?` — інакше Picker не знайде вибраний пункт.
                    .tag(c.id as String?)
            }
        }
        // `.menu` — кнопка з випадним меню (так само показує `@expo/ui` Picker на iOS).
        .pickerStyle(.menu)
        .frame(maxWidth: .infinity, alignment: .leading)
    }
}

#Preview {
    ListView().environment(CountriesStore())
}
