//
//  ListView.swift
//  Numismat
//
//  Аналог src/app/list.tsx в Expo.
//

import SwiftUI

// Назва `ListView`, а не `List`, бо `List` — вбудований компонент SwiftUI (≈ FlatList).
struct ListView: View {
    var body: some View {
        Text("Список")
    }
}

#Preview {
    ListView()
}
