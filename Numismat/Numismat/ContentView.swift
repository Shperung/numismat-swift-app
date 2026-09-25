//
//  ContentView.swift
//  Numismat
//
//  Created by Viktor Kravchuk on 24.09.2026.
//
//  Аналог src/app/_layout.tsx в Expo: кореневий навігатор з нижніми табами.
//

import SwiftUI

struct ContentView: View {
    var body: some View {
        // `TabView` ≈ `<Tabs>` з expo-router (під капотом — Bottom Tab Navigator).
        // Різниця: в Expo екрани знаходяться за іменем файлу (file-based routing),
        // а тут ми явно вкладаємо view кожного таба — як у класичному React Navigation.
        TabView {
            // `Tab(...)` ≈ `<Tabs.Screen name="index" options={{ title, tabBarIcon }} />`.
            // - перший аргумент — `title`;
            // - `systemImage` — `tabBarIcon`: іконка з SF Symbols (вбудований набір Apple,
            //   аналог Ionicons, але без жодної бібліотеки). Колір/розмір (`color`, `size`
            //   у RN) система підставляє сама, залежно від того, чи таб активний.
            // - у `{ }` (trailing closure) — сам екран, як `component` у React Navigation.
            Tab("Головна", systemImage: "house.fill") {
                HomeView()
            }

            Tab("Список", systemImage: "list.bullet") {
                ListView()
            }

            Tab("Інфо", systemImage: "info.circle.fill") {
                InfoView()
            }
        }
        // Заголовка зверху (header), як у Expo `Tabs`, тут немає: у SwiftUI він
        // з'являється лише всередині `NavigationStack` — додамо на кроці навігації.
    }
}

#Preview {
    ContentView()
}
