//
//  CountriesStore.swift
//  Numismat
//
//  Спільний стор довідника країн (як CoinsStore). В Expo країни вантажаться прямо в list.tsx
//  (`useState<Country[]>` + `useEffect`), тут — один раз при старті додатку (≈ CountriesViewModel у Kotlin).
//

import Observation

@Observable
class CountriesStore {
    // `[Country]` ≈ `Country[]`. Раніше тут був "сирий" `[[String: Any]]` для виводу JSON.
    var countries: [Country] = []
    var loading = true
    var error: String?

    func load() async {
        do {
            // ≈ `data as Country[]`.
            countries = try await fetchCollection("countries").map { Country($0) }
        } catch {
            self.error = String(describing: error)
        }
        loading = false
    }
}
