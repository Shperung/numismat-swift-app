//
//  CoinPhoto.swift
//  Numismat
//
//  Кругле фото монети. В Expo це повторюваний шматок у coin-card.tsx і coin/[id].tsx:
//    <Image source={coin.avers} style={{ width, height, borderRadius: width / 2, backgroundColor: '#eee' }}
//           contentFit="cover" />
//  Тут винесено в окремий view, бо в SwiftUI маленькі компоненти — звична практика (як і в RN).
//

import SwiftUI

struct CoinPhoto: View {
    // Пропси ≈ `{ url, size }: { url?: string; size: number }`.
    // У SwiftUI пропси — це просто властивості struct; викликаємо `CoinPhoto(url: ..., size: 56)`.
    let url: String?
    let size: CGFloat

    var body: some View {
        // `AsyncImage` ≈ `<Image source={{ uri }} />` з expo-image: сам завантажує картинку за URL.
        // Різниця: expo-image кешує на диску, а AsyncImage — ні (лише стандартний HTTP-кеш).
        // `URL(string:)` повертає optional: для `nil` чи кривого рядка AsyncImage покаже placeholder.
        AsyncImage(url: URL(string: url ?? "")) { image in
            // Перше замикання — що показати, коли картинка завантажилась.
            // `.resizable()` — дозволити міняти розмір (за замовчуванням Image рендериться 1:1 у пікселях),
            // `.scaledToFill()` ≈ `contentFit="cover"`.
            image.resizable().scaledToFill()
        } placeholder: {
            // Друге замикання — поки вантажиться (≈ `backgroundColor: '#eee'` під картинкою).
            // `systemGray5` — системний світло-сірий, який сам адаптується до темної теми.
            Color(.systemGray5)
        }
        // ≈ `{ width: size, height: size }`.
        .frame(width: size, height: size)
        // ≈ `borderRadius: size / 2` + `overflow: 'hidden'`: обрізати по колу.
        .clipShape(.circle)
    }
}

#Preview {
    CoinPhoto(url: nil, size: 150)
}
