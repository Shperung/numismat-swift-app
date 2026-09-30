//
//  NumismatServer.swift
//  Numismat
//
//  Аналог src/lib/numismat-server.ts в Expo — запити до спільного бекенду numismat-server (AI-проксі):
//  `fetchProviders()` — список моделей (`GET /providers`), `askServer(...)` — питання моделі (`POST /chat`).
//
//    const API_URL = 'https://inua.tetiana-redko.com';
//    type Message = { role: 'user' | 'assistant'; content: string };
//
//    export async function askServer(provider: string, coin: Coin, messages: Message[]) {
//      const res = await fetch(`${API_URL}/chat`, {
//        method: 'POST',
//        headers: { 'Content-Type': 'application/json' },
//        body: JSON.stringify({ provider, coin, messages }),
//      });
//      const data = await res.json();
//      if (!res.ok) throw new Error(`${res.status} ${data.error}`);
//      return data.text as string;
//    }
//

import Foundation

// URL — константа, не секрет (ключі Groq тощо лежать лише на сервері).
// `URL(string:)` повертає optional; `!` — "точно не nil" (≈ `!` non-null assertion у TS):
// для рядка-літерала, який ми бачимо, це безпечно; якби URL був кривий — падіння при старті.
private let apiURL = URL(string: "https://inua.tetiana-redko.com")!

// ≈ `export type Provider = { id: string; title: string; logo: string }` — модель з `GET /providers`.
// `Decodable` — щоб `JSONDecoder` зібрав масив `[Provider]` з JSON-відповіді.
struct Provider: Decodable {
    let id: String
    let title: String
    // URL картинки (напр. "https://github.com/openai.png?size=128").
    let logo: String
}

// ≈ export async function fetchProviders() {
//     const res = await fetch(`${API_URL}/providers`);
//     if (!res.ok) throw new Error(`${res.status}`);
//     return (await res.json()) as Provider[];
//   }
// Для GET досить `data(from: URL)` — без `URLRequest`, як `fetch(url)` без другого аргументу.
func fetchProviders() async throws -> [Provider] {
    let (data, response) = try await URLSession.shared.data(from: apiURL.appending(path: "providers"))
    let status = (response as? HTTPURLResponse)?.statusCode ?? 0
    guard (200..<300).contains(status) else {
        throw ServerError(description: "\(status)")
    }
    // `[Provider].self` — сам тип "масив Provider" як значення (≈ `as Provider[]`, але з реальною перевіркою).
    return try JSONDecoder().decode([Provider].self, from: data)
}

// ≈ `type Message = { role: 'user' | 'assistant'; content: string }`.
struct ChatMessage: Encodable {
    // `enum` з рядковими значеннями ≈ union-тип `'user' | 'assistant'`:
    // інших значень компілятор не пропустить, а в JSON потрапить сам рядок ("user").
    enum Role: String, Encodable {
        case user, assistant
    }

    let role: Role
    let content: String
}

// Тіло запиту `{ provider, coin, messages }`. У TS об'єкт можна зібрати "на льоту",
// а для `JSONEncoder` потрібен тип — `Encodable` сам згенерує JSON з полів.
private struct ChatRequest: Encodable {
    let provider: String
    let coin: Coin
    let messages: [ChatMessage]
}

// Відповідь сервера: `{ text }` при успіху або `{ error }` при помилці.
// `Decodable` — навпаки до `Encodable`: JSON → Swift-значення (≈ `await res.json()` + тип).
private struct ChatResponse: Decodable {
    let text: String?
    let error: String?
}

// ≈ `new Error(...)`. У Swift помилка — будь-який тип, що реалізує протокол `Error`.
// `CustomStringConvertible` + `description` — щоб `"\(error)"` показував наш текст (≈ `error.message`).
struct ServerError: Error, CustomStringConvertible {
    let description: String
}

func askServer(_ provider: String, coin: Coin, messages: [ChatMessage]) async throws -> String {
    // `URLRequest` збирає те, що в `fetch` передається другим аргументом (`method`, `headers`, `body`).
    // `var`, бо далі змінюємо його властивості (у `let`-структури їх змінити не можна).
    var request = URLRequest(url: apiURL.appending(path: "chat"))
    request.httpMethod = "POST"
    request.setValue("application/json", forHTTPHeaderField: "Content-Type")
    // ≈ `body: JSON.stringify({ provider, coin, messages })`.
    request.httpBody = try JSONEncoder().encode(ChatRequest(provider: provider, coin: coin, messages: messages))

    // ≈ `const res = await fetch(...)`. `URLSession.shared` — стандартний HTTP-клієнт iOS
    // (≈ глобальний `fetch`). Повертає пару (тіло, відповідь) — розпаковуємо в дві змінні.
    let (data, response) = try await URLSession.shared.data(for: request)

    // ≈ `const data = await res.json()`.
    let body = try JSONDecoder().decode(ChatResponse.self, from: data)

    // ≈ `res.status` / `res.ok`. `response` має загальний тип `URLResponse`, тому приводимо
    // до `HTTPURLResponse` (`as?` ≈ перевірка типу), щоб дістати HTTP-статус.
    let status = (response as? HTTPURLResponse)?.statusCode ?? 0

    // ≈ `if (!res.ok) throw new Error(`${res.status} ${data.error}`)`.
    // `200..<300` — діапазон 200...299 (саме так визначається `res.ok`).
    guard (200..<300).contains(status), let text = body.text else {
        throw ServerError(description: "\(status) \(body.error ?? "")")
    }
    return text
}
