//
//  Country.swift
//  Numismat
//
//  Аналог src/types/country.ts в Expo:
//
//    export type Country = { id: string; name_ua: string; name_en: string; flag: string };
//

// `Identifiable` — для `ForEach` (ключ = `id`), `Hashable` — щоб масив країн можна було
// порівнювати в `.onChange(of: store.countries)` у ListView (≈ залежність у `useEffect`).
struct Country: Identifiable, Hashable {
    let id: String
    // У Swift прийнято camelCase, тому `name_ua` з Firestore → `nameUa` (як і в Kotlin).
    let nameUa: String
    let nameEn: String
    // Прапор — emoji-рядок (напр. "🇺🇦").
    let flag: String
}

// Як і в Coin.swift: ≈ `data as Country[]`, але з перевіркою кожного поля.
extension Country {
    init(_ data: [String: Any]) {
        id = data["id"] as? String ?? ""
        nameUa = data["name_ua"] as? String ?? ""
        nameEn = data["name_en"] as? String ?? ""
        flag = data["flag"] as? String ?? ""
    }
}
