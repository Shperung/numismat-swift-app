//
//  Coin.swift
//  Numismat
//
//  Аналог src/types/coin.ts в Expo:
//
//    export type Coin = {
//      id: string; country: string; name: string; value: number; currency: string;
//      info?: string; avers?: string; revers?: string;
//    };
//

// `struct` ≈ `type Coin = {...}`, але це справжній тип у рантаймі, а не лише підказка для компілятора.
// Протоколи після `:` ≈ `implements` інтерфейсів:
// - `Identifiable` — має поле `id`; потрібен для `ForEach` (≈ `keyExtractor={(coin) => coin.id}`).
// - `Hashable` — можна порівнювати й хешувати; потрібен, щоб передати монету в `NavigationLink(value:)`.
// Реалізацію обох протоколів Swift генерує сам, бо всі поля — прості типи.
struct Coin: Identifiable, Hashable {
    let id: String
    let country: String
    let name: String
    // У типі Expo це `number`, але у Firestore лежить рядок ("25"), тож тут `String`.
    // TS це "проковтнув" через `as Coin`, а Swift перевіряє типи і в рантаймі.
    let value: String
    let currency: String
    // `String?` ≈ `info?: string` (optional, може бути `nil`).
    let info: String?
    let avers: String?
    let revers: String?
}

// ≈ `coins as Coin[]` у coins-provider.tsx, але з реальною перевіркою кожного поля.
// `extension` — додати до типу щось окремо від його оголошення. Init винесено сюди, щоб Swift
// зберіг автоматичний "memberwise" init `Coin(id:country:...)` (він потрібен для прев'ю):
// якщо написати свій init усередині `struct`, автоматичний зникає.
extension Coin {
    // `_ data` — без імені аргументу: викликаємо як `Coin(dict)`.
    init(_ data: [String: Any]) {
        // `as? String` ≈ `typeof x === 'string' ? x : undefined`; `?? ""` — значення за замовчуванням.
        id = data["id"] as? String ?? ""
        country = data["country"] as? String ?? ""
        name = data["name"] as? String ?? ""
        // `value` може прийти і рядком, і числом — перетворюємо будь-що в рядок (≈ `String(x)`).
        // `.map` на optional ≈ `x != null ? String(x) : undefined`.
        value = data["value"].map { "\($0)" } ?? ""
        currency = data["currency"] as? String ?? ""
        info = data["info"] as? String
        avers = data["avers"] as? String
        revers = data["revers"] as? String
    }
}
