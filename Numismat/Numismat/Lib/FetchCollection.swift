//
//  FetchCollection.swift
//  Numismat
//
//  Аналог src/lib/fetch-collection.ts в Expo:
//
//    export async function fetchCollection(name: string) {
//      const snapshot = await getDocs(collection(db, name));
//      return snapshot.docs.map((doc) => ({ id: doc.id, ...doc.data() }));
//    }
//

// ≈ `import { collection, getDocs } from 'firebase/firestore'`.
// Окремого файлу firebase.ts з `export const db = getFirestore(app)` не потрібно:
// `Firestore.firestore()` сам повертає один спільний екземпляр (singleton) для вже
// ініціалізованого в NumismatApp.init Firebase.
import FirebaseFirestore

// Сигнатура:
// - `func` ≈ `function`, без `export`: у Swift усе, що в таргеті, і так видно з інших файлів.
// - `_ name: String` — `_` означає "без імені аргументу при виклику": пишемо
//   `fetchCollection("coins")`, а не `fetchCollection(name: "coins")`.
// - `async` ≈ `async`, `throws` ≈ "може кинути помилку" (у TS це не видно в типі, тут — видно).
// - `-> [[String: Any]]` — тип результату: масив словників ≈ `Record<string, unknown>[]`.
//   `Any` ≈ `unknown`: поки що без типу `Coin`, як і в Expo на цьому кроці.
func fetchCollection(_ name: String) async throws -> [[String: Any]] {
    // ≈ `const snapshot = await getDocs(collection(db, name))`.
    // `try` обов'язковий перед викликом функції, що кидає помилку: компілятор змушує
    // явно позначити місце, де може вилетіти exception (у JS це ніяк не позначається).
    // `let` ≈ `const`.
    let snapshot = try await Firestore.firestore().collection(name).getDocuments()

    // ≈ `snapshot.docs.map((doc) => ({ id: doc.id, ...doc.data() }))`.
    // - `{ ... }` після `map` — замикання (≈ стрілкова функція); `$0` — її перший аргумент (≈ `doc`).
    // - Спреду `...` для словників у Swift немає, тому `merging(...)` — злиття двох словників
    //   (≈ `{ ...doc.data(), id: doc.id }`). Останнє замикання `{ _, id in id }` вирішує конфлікт
    //   однакових ключів: беремо значення з другого словника, тобто `id` документа.
    // - `return` в однорядковому замиканні не потрібен (як у `(doc) => ({...})`).
    return snapshot.documents.map { $0.data().merging(["id": $0.documentID]) { _, id in id } }
}
