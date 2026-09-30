//
//  CoinView.swift
//  Numismat
//
//  Аналог src/app/coin/[id].tsx в Expo — екран однієї монети.
//  Сам вміст — у CoinDetails (≈ `return <CoinDetails coin={coin} />`), тут лише заголовок екрана.
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
        CoinDetails(coin: coin)
            // ≈ <Stack.Screen name="coin/[id]" options={{ title: 'Монета' }} />.
            // В Expo заголовок задає батьківський `_layout.tsx`, а в SwiftUI — сам екран.
            // `.inline` — маленький заголовок по центру (як у Expo), а не великий зліва (стиль iOS за замовчуванням).
            // Кнопку "Назад" iOS додає сама; як підпис бере заголовок попереднього екрана ("Список").
            .navigationTitle("Монета")
            .navigationBarTitleDisplayMode(.inline)
    }
}

// `NavigationStack` у прев'ю — щоб побачити заголовок, як на реальному екрані.
#Preview {
    NavigationStack {
        CoinView(coin: Coin(id: "1", country: "ua", name: "10 гривень", value: "10", currency: "uag",
                            year: "2025", info: "ДСНС України Сміливі рятувати життя", avers: nil, revers: nil))
    }
}
