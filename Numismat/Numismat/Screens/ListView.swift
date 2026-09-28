//
//  ListView.swift
//  Numismat
//
//  Аналог src/app/list.tsx в Expo.
//

import SwiftUI

// Назва `ListView`, а не `List`, бо `List` — вбудований компонент SwiftUI (≈ FlatList).
struct ListView: View {
    @Environment(CountriesStore.self) private var store
    
    var body: some View {
        // ≈ `<ScrollView>`. Скрол у SwiftUI не вмикається сам — як і в RN, потрібен ScrollView.
        ScrollView {
            // Той самий вираз, що в Expo: `loading ? '...' : error ?? JSON.stringify(...)`.
            // Тернарник `? :` і `??` у Swift працюють так само, як у TS.
            Text(store.loading ? "Завантаження..." : store.error ?? json(store.countries))
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
    
    private func json(_ value: Any) -> String {
        guard JSONSerialization.isValidJSONObject(value),
              let data = try? JSONSerialization.data(withJSONObject: value, options: .prettyPrinted)
        else { return String(describing: value) }
        return String(decoding: data, as: UTF8.self)
    }
}

#Preview {
    ListView().environment(CountriesStore())
}
