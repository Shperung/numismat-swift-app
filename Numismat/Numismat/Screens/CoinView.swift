//
//  CoinView.swift
//  Numismat
//
//  Аналог src/app/coin/[id].tsx в Expo — екран однієї монети.
//
//  Різниця в тому, як екран отримує монету:
//  - Expo Router будує навігацію на URL (`/coin/123`), а в URL можна передати лише рядок,
//    тому екран бере `id` з `useLocalSearchParams()` і шукає монету в провайдері.
//  - SwiftUI передає в екран будь-яке Swift-значення, тож отримуємо одразу готовий `Coin`
//    (≈ `navigation.navigate('Coin', { coin })` у класичному React Navigation).
//    Тому і стану "Монету не знайдено" тут не буває.
//

import SwiftUI

struct CoinView: View {
    let coin: Coin

    var body: some View {
        // ≈ <ScrollView contentContainerStyle={{ padding: 16, gap: 8 }}>.
        ScrollView {
            VStack(alignment: .leading, spacing: 8) {
                // ≈ styles.photos: { flexDirection: 'row', gap: 12, justifyContent: 'center', marginBottom: 8 }.
                HStack(spacing: 12) {
                    CoinPhoto(url: coin.avers, size: 150)
                    CoinPhoto(url: coin.revers, size: 150)
                }
                // `maxWidth: .infinity` розтягує рядок на всю ширину, а `HStack` усередині
                // за замовчуванням центрується ≈ `justifyContent: 'center'`.
                .frame(maxWidth: .infinity)
                .padding(.bottom, 8)

                // ≈ styles.name: { fontSize: 22, fontWeight: '700' }.
                Text(coin.name)
                    .font(.system(size: 22, weight: .bold))
                Text("\(coin.value) \(coin.currency)")
                Text("Країна: \(coin.country)")

                // ≈ `{coin.info ? <Text style={styles.info}>{coin.info}</Text> : null}`.
                // `if let info = coin.info` — "розпакувати optional": всередині `info` вже `String`, не `String?`.
                if let info = coin.info {
                    Text(info)
                        // ≈ styles.info: { marginTop: 8, lineHeight: 20 }; `lineSpacing` — відступ між рядками.
                        .padding(.top, 8)
                        .lineSpacing(4)
                }
            }
            .padding(16)
        }
        // ≈ <Stack.Screen name="coin/[id]" options={{ title: 'Монета' }} />.
        // В Expo заголовок задає батьківський `_layout.tsx`, а в SwiftUI — сам екран.
        // `.inline` — маленький заголовок по центру (як у Expo), а не великий зліва (стиль iOS за замовчуванням).
        // Кнопку "Назад" iOS додає сама; як підпис бере заголовок попереднього екрана ("Головна").
        .navigationTitle("Монета")
        .navigationBarTitleDisplayMode(.inline)
    }
}

// `NavigationStack` у прев'ю — щоб побачити заголовок, як на реальному екрані.
#Preview {
    NavigationStack {
        CoinView(coin: Coin(id: "1", country: "ua", name: "10 гривень", value: "10", currency: "uag",
                            info: "ДСНС України Сміливі рятувати життя", avers: nil, revers: nil))
    }
}
