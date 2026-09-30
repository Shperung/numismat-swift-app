//
//  AI.swift
//  Numismat
//
//  Аналог src/lib/ai.ts в Expo (Firebase AI Logic, Gemini):
//
//    const ai = getAI(app, { backend: new AgentPlatformBackend("global") });
//
//    export function startCoinChat(coin: Coin) {
//      const model = getGenerativeModel(ai, {
//        model: "gemini-3.5-flash-lite",
//        systemInstruction: "Ти досвідчений нумізмат. ... " + `Розмова про монету: ${JSON.stringify(coin)}, ...`,//      });
//      return model.startChat();
//    }
//

// ≈ `import { getAI, getGenerativeModel, AgentPlatformBackend } from "firebase/ai"`.
// Продукт `FirebaseAILogic` з того самого SPM-пакета firebase-ios-sdk, що й Firestore
// (≈ `firebase/ai` входить у той самий npm-пакет `firebase`). Ключ Gemini в додатку не потрібен —
// запити йдуть через Firebase з конфігом з GoogleService-Info.plist.
import FirebaseAILogic
import Foundation

// ≈ `const ai = getAI(app, { backend: new AgentPlatformBackend("global") })`.
// `app` передавати не треба — береться стандартний FirebaseApp з `FirebaseApp.configure()`.
// Глобальна `let` у Swift ініціалізується ліниво, при першому зверненні (а не при "імпорті" файлу,
// як модуль у JS), тож на момент створення Firebase вже налаштований.
private let ai = FirebaseAI.firebaseAI(backend: .agentPlatform(location: "global"))

// Повертає `Chat` ≈ результат `model.startChat()`: об'єкт розмови, який пам'ятає історію повідомлень.
func startCoinChat(_ coin: Coin) -> Chat {
    // ≈ `JSON.stringify(coin)`. `JSONEncoder` працює з типами, що `Encodable` (див. Coin.swift).
    // `try?` — при помилці `nil`, тоді `?? ""`.
    let coinJSON = (try? JSONEncoder().encode(coin)).map { String(decoding: $0, as: UTF8.self) } ?? ""

    // ≈ `getGenerativeModel(ai, { model, systemInstruction })`.
    // `systemInstruction` у Swift SDK — не рядок, а `ModelContent` (повідомлення з роллю "system").
    let model = ai.generativeModel(
        modelName: "gemini-3.5-flash-lite",
        systemInstruction: ModelContent(
            role: "system",
            // Той самий промпт, що на numismat-server (`systemPrompt`) і в Kotlin.
            // Рядок, розбитий на частини через `+` (≈ `"..." + \`...\`` у TS); `\(x)` ≈ `${x}`.
            parts: "Ти досвідчений нумізмат. Відповідай українською, коротко і цікаво. "
                + "Розмова про монету: \(coinJSON), які факти про неї є, чи вона ще в вжитку, "
                + "що за неї можна купити або можна було купити у рік виходу"
        )
    )
    return model.startChat()
}
