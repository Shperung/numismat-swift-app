//
//  CoinDetails.swift
//  Numismat
//
//  Аналог src/components/coin-details.tsx в Expo — вміст екрана монети без навігації.
//  Використовується у двох місцях (як і в Expo): екран монети (CoinView) і випадкова монета на Головній.
//

// Потрібен, хоча `Chat` ми отримуємо з Lib/AI.swift: через налаштування `MEMBER_IMPORT_VISIBILITY`
// методи чужого модуля (`sendMessage`, `text`) видно лише у файлах, які імпортують його явно.
// В ESM аналогічно: щоб викликати функцію з пакета, її треба імпортувати в цьому файлі.
import FirebaseAILogic
import SwiftUI

// ≈ `const QUESTION = 'Розкажи цікаві факти про цю монету'`.
// `private` на рівні файлу ≈ константа модуля без `export`.
private let question = "Розкажи цікаві факти про цю монету"

// Тип елемента масиву `aiButtons`. У TS тип виводиться з самого масиву (`(typeof aiButtons)[number]`),
// у Swift масив з різнорідними полями потребує явного типу — оголошуємо struct.
private struct AIButton: Identifiable {
    let id: String
    let title: String
    // ≈ `logo: require('../../assets/ai/gemini.png')`. Картинки лежать в Assets.xcassets,
    // а Xcode сам генерує для кожної константу (`.gemini`, `.groq`) — як `require`, помилка
    // в назві видна під час збірки, а не в рантаймі.
    let logo: ImageResource
    // ≈ `ask: async (coin: Coin) => string`. Тип функції як значення: приймає `Coin`,
    // асинхронна, може кинути помилку, повертає `String?` (Gemini може повернути відповідь без тексту).
    let ask: (Coin) async throws -> String?
}

// ≈ `const aiButtons = [{ id: 'gemini', ... }, { id: 'groq', ... }]`.
private let aiButtons = [
    AIButton(
        id: "gemini",
        title: "Запитати в Gemini про монету",
        logo: .gemini,
        // ≈ `async (coin) => (await startCoinChat(coin).sendMessage(QUESTION)).response.text()`.
        // `{ coin in ... }` — замикання (≈ стрілкова функція `(coin) => ...`).
        ask: { coin in try await startCoinChat(coin).sendMessage(question).text }
    ),
    AIButton(
        id: "groq",
        title: "Запитати в Groq про монету",
        logo: .groq,
        // ≈ `(coin) => askServer('groq-gpt-oss', coin, [{ role: 'user', content: QUESTION }])`.
        // `.user` — скорочений запис `ChatMessage.Role.user` (тип відомий з контексту).
        ask: { coin in
            try await askServer("groq-gpt-oss", coin: coin, messages: [ChatMessage(role: .user, content: question)])
        }
    ),
]

struct CoinDetails: View {
    let coin: Coin

    // ≈ const [answer, setAnswer] = useState<string | null>(null);
    //   const [loadingId, setLoadingId] = useState<string | null>(null);
    // `loadingId` — яка саме кнопка зараз чекає відповідь (щоб показати крутилку саме на ній).
    @State private var answer: String?
    @State private var loadingId: String?

    var body: some View {
        // ≈ <ScrollView contentContainerStyle={{ padding: 16, gap: 8 }}>.
        ScrollView {
            VStack(alignment: .leading, spacing: 8) {
                // ≈ styles.photos: { flexDirection: 'row', gap: 12, justifyContent: 'center', marginBottom: 8 }.
                HStack(spacing: 12) {
                    CoinPhoto(url: coin.avers, size: 150)
                    CoinPhoto(url: coin.revers, size: 150)
                }
                // `maxWidth: .infinity` розтягує рядок на всю ширину, а `HStack` усередині
                // за замовчуванням центрується ≈ `justifyContent: 'center'`.
                .frame(maxWidth: .infinity)
                .padding(.bottom, 8)

                // ≈ styles.name: { fontSize: 22, fontWeight: '700' }.
                Text(coin.name)
                    .font(.system(size: 22, weight: .bold))
                Text("\(coin.value) \(coin.currency)")
                Text("Рік: \(coin.year)")
                Text("Країна: \(coin.country)")

                // ≈ `{coin.info ? <Text style={styles.info}>{coin.info}</Text> : null}`.
                // `if let info = coin.info` — "розпакувати optional": всередині `info` вже `String`, не `String?`.
                if let info = coin.info {
                    Text(info)
                        // ≈ styles.info: { marginTop: 8, lineHeight: 20 }; `lineSpacing` — відступ між рядками.
                        .padding(.top, 8)
                        .lineSpacing(4)
                }

                // ≈ <View style={styles.aiButtons}> ({ gap: 8, marginTop: 16 }).
                VStack(spacing: 8) {
                    // ≈ `aiButtons.map((button) => <Pressable key={button.id} ...>)`; ключ — `id` з `Identifiable`.
                    ForEach(aiButtons) { button in
                        // ≈ <Pressable onPress={() => askFacts(button)} disabled={loadingId !== null}>.
                        // `Button { дія } label: { вигляд }` — два замикання: що робити і як виглядати.
                        // Дія кнопки не може бути `async`, тому async-функцію запускаємо в `Task { ... }`
                        // (≈ промис, який ніхто не чекає).
                        Button {
                            Task { await askFacts(button) }
                        } label: {
                            // ≈ styles.aiButton: { flexDirection: 'row', alignItems: 'center', gap: 10 }.
                            HStack(spacing: 10) {
                                // ≈ <Image source={button.logo} style={{ width: 24, height: 24, borderRadius: 4 }} />.
                                Image(button.logo)
                                    .resizable()
                                    .frame(width: 24, height: 24)
                                    .clipShape(.rect(cornerRadius: 4))
                                // ≈ styles.aiButtonText: { fontWeight: '600', flex: 1 }.
                                // `maxWidth: .infinity` ≈ `flex: 1` — текст забирає все вільне місце.
                                Text(button.title)
                                    .fontWeight(.semibold)
                                    .frame(maxWidth: .infinity, alignment: .leading)
                                // ≈ `{loadingId === button.id ? <ActivityIndicator /> : null}`.
                                if loadingId == button.id {
                                    ProgressView()
                                }
                            }
                            // ≈ { padding: 12, borderRadius: 12, backgroundColor: '#fff', borderWidth: 1, borderColor: '#ddd' }.
                            // Рамки як CSS-властивості в SwiftUI немає: малюємо контур тієї ж форми
                            // поверх view через `.overlay` (`stroke` — лише лінія, без заливки).
                            .padding(12)
                            .background(Color(.systemBackground), in: .rect(cornerRadius: 12))
                            .overlay {
                                RoundedRectangle(cornerRadius: 12)
                                    .stroke(Color(.systemGray4))
                            }
                        }
                        // `.plain` — без системного стилю кнопки (інакше SwiftUI перефарбує текст у синій).
                        .buttonStyle(.plain)
                        // ≈ `disabled={loadingId !== null}`: поки чекаємо відповідь, вимкнені обидві кнопки.
                        .disabled(loadingId != nil)
                    }
                }
                .padding(.top, 16)

                // ≈ `{answer ? <Text style={styles.info}>{answer}</Text> : null}`.
                // Markdown у відповіді, як і в Expo, поки не рендериться: `Text(String)` показує текст як є.
                if let answer {
                    Text(answer)
                        .padding(.top, 8)
                        .lineSpacing(4)
                }
            }
            .padding(16)
        }
    }

    // ≈ const askFacts = async (button) => {
    //     setLoadingId(button.id);
    //     try { setAnswer(await button.ask(coin)); } catch (e) { ... } finally { setLoadingId(null); }
    //   };
    private func askFacts(_ button: AIButton) async {
        loadingId = button.id
        // `defer` виконується при виході з функції за будь-яких умов ≈ блок `finally`.
        defer { loadingId = nil }
        do {
            // Кнопка сама знає, кого питати: Gemini через Firebase чи Groq через numismat-server.
            answer = try await button.ask(coin)
        } catch {
            // ≈ setAnswer(`Помилка: ${String(e)}`).
            answer = "Помилка: \(error)"
        }
    }
}

#Preview {
    CoinDetails(coin: Coin(id: "1", country: "ua", name: "10 гривень", value: "10", currency: "uag",
                           year: "2025", info: "ДСНС України Сміливі рятувати життя", avers: nil, revers: nil))
}
