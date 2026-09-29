//
//  FetchCoinsByCountry.swift
//  Numismat
//
//  Аналог src/lib/fetch-coins-by-country.ts в Expo:
//
//    export async function fetchCoinsByCountry(country: string) {
//      const snapshot = await getDocs(query(collection(db, 'coins'), where('country', '==', country)));
//      return snapshot.docs.map((doc) => ({ id: doc.id, ...doc.data() }) as Coin);
//    }
//

import FirebaseFirestore

func fetchCoinsByCountry(_ country: String) async throws -> [Coin] {
    // У JS запит збирається функціями `query(collection(...), where(...))`,
    // а в Swift SDK — ланцюжком методів: `.collection(...).whereField(...)`.
    // `whereField("country", isEqualTo: country)` ≈ `where('country', '==', country)`.
    // Фільтрує сервер Firestore — завантажуються лише монети потрібної країни.
    let snapshot = try await Firestore.firestore()
        .collection("coins")
        .whereField("country", isEqualTo: country)
        .getDocuments()

    // Те саме злиття `{ id, ...data }`, що й у fetchCollection, і одразу перетворення на `Coin`.
    return snapshot.documents.map { Coin($0.data().merging(["id": $0.documentID]) { _, id in id }) }
}
