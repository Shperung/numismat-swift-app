//
//  CoinCard.swift
//  Numismat
//
//  Аналог src/components/coin-card.tsx в Expo.
//  Різниця: в Expo картка сама обгорнута в `<Link href={`/coin/${coin.id}`} asChild>`,
//  а тут картка — лише вигляд, а навігацію (`NavigationLink`) додає список у HomeView.
//

import SwiftUI

// ≈ `export function CoinCard({ coin }: { coin: Coin })`.
struct CoinCard: View {
    let coin: Coin

    var body: some View {
        // `HStack(spacing: 12)` ≈ `<View style={{ flexDirection: 'row', gap: 12 }}>`.
        HStack(spacing: 12) {
            // ≈ styles.photos: { flexDirection: 'row', gap: 4 }.
            HStack(spacing: 4) {
                CoinPhoto(url: coin.avers, size: 56)
                CoinPhoto(url: coin.revers, size: 56)
            }

            // `VStack` ≈ `<View>` з `flexDirection: 'column'` (як за замовчуванням у RN).
            // `alignment: .leading` ≈ `alignItems: 'flex-start'` (у SwiftUI за замовчуванням — центр).
            VStack(alignment: .leading, spacing: 2) {
                // ≈ styles.name: { fontSize: 16, fontWeight: '600' }.
                Text(coin.name)
                    .font(.system(size: 16, weight: .semibold))
                // Інтерполяція `"\(x)"` ≈ шаблонний рядок `${x}`.
                Text("\(coin.value) \(coin.currency)")
                // ≈ styles.country: { color: '#666' }; `.secondary` — системний сірий (і для темної теми).
                Text(coin.country)
                    .foregroundStyle(.secondary)
            }

            // `Spacer()` заповнює вільне місце ≈ `<View style={{ flex: 1 }} />`:
            // притискає вміст вліво, щоб картка займала всю ширину.
            Spacer()
        }
        // ≈ styles.card: { padding: 12, borderRadius: 12, backgroundColor: '#fff' }.
        // Модифікатори застосовуються по черзі: спершу відступ, потім фон під уже збільшеним view
        // (тому `.padding` стоїть до `.background` — інакше фон був би без відступів).
        // `secondarySystemGroupedBackground` — білий у світлій темі, темно-сірий у темній.
        .padding(12)
        .background(Color(.secondarySystemGroupedBackground), in: .rect(cornerRadius: 12))
    }
}

// Прев'ю з тестовою монетою: memberwise init `Coin(id:...)` згенерував Swift (див. Coin.swift).
#Preview {
    CoinCard(coin: Coin(id: "1", country: "ua", name: "10 гривень", value: "10", currency: "uag",
                        info: nil, avers: nil, revers: nil))
        .padding()
}
