//
//  HomeView.swift
//  Numismat
//
//  Аналог src/app/index.tsx в Expo.
//

// `import SwiftUI` ≈ `import { Text, View } from 'react-native'`,
// але одразу імпортує весь UI-фреймворк (Text, VStack, TabView, …).
import SwiftUI

// `struct HomeView: View` ≈ `export default function HomeScreen()`.
// Імпорт не потрібен: усі файли одного таргету бачать одне одного (як один модуль).
struct HomeView: View {
    // `body` ≈ `return (...)` у компоненті — опис того, що рендерити.
    var body: some View {
        // `<View style={{ flex: 1, alignItems: 'center', justifyContent: 'center' }}>`
        // не потрібен: SwiftUI за замовчуванням центрує вміст на екрані.
        Text("Головна")
    }
}

// Живий прев'ю в Xcode (Canvas) — аналогів у RN немає.
#Preview {
    HomeView()
}
