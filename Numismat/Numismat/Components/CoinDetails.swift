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

struct CoinDetails: View {
    let coin: Coin

    // ≈ const [answer, setAnswer] = useState<string | null>(null);
    //   const [loading, setLoading] = useState(false);
    @State private var answer: String?
    @State private var loading = false

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

                // ≈ <Pressable style={styles.aiButton} onPress={askFacts} disabled={loading}>.
                // `Button { дія } label: { вигляд }` — два замикання: що робити і як виглядати.
                // `onPress` не може бути `async`, тому async-функцію запускаємо в `Task { ... }`
                // (≈ `onPress={() => { askFacts(); }}` — промис, який ніхто не чекає).
                Button {
                    Task { await askFacts() }
                } label: {
                    // `Label` = іконка + текст у рядок (≈ <Ionicons name="sparkles" /> + <Text>).
                    // "sparkles" — така сама іконка, тільки з SF Symbols.
                    Label("Дізнатись цікаві факти про цю монету", systemImage: "sparkles")
                        // ≈ styles.aiButtonText: { color: '#fff', fontWeight: '600' }.
                        .fontWeight(.semibold)
                        .foregroundStyle(.white)
                        // ≈ styles.aiButton: { padding: 12, borderRadius: 12, backgroundColor: '#1a73e8' }.
                        // `maxWidth: .infinity` — кнопка на всю ширину, як `<Pressable>` у колонці RN.
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding(12)
                        .background(Color(red: 0x1A / 255, green: 0x73 / 255, blue: 0xE8 / 255),
                                    in: .rect(cornerRadius: 12))
                }
                // `.plain` — без системного стилю кнопки (інакше SwiftUI перефарбує текст у синій).
                .buttonStyle(.plain)
                // ≈ `disabled={loading}`.
                .disabled(loading)
                // ≈ marginTop: 16.
                .padding(.top, 16)

                // ≈ `{loading ? <ActivityIndicator /> : null}`; `ProgressView()` без параметрів — "крутилка".
                if loading {
                    ProgressView()
                        .frame(maxWidth: .infinity)
                }
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

    // ≈ const askFacts = async () => { setLoading(true); try { ... } catch { ... } finally { setLoading(false) } }.
    private func askFacts() async {
        loading = true
        // `defer` виконується при виході з функції за будь-яких умов ≈ блок `finally`.
        defer { loading = false }
        do {
            // ≈ `await startCoinChat(coin).sendMessage('Розкажи цікаві факти про цю монету')`.
            let response = try await startCoinChat(coin).sendMessage("Розкажи цікаві факти про цю монету")
            // ≈ `result.response.text()`; у Swift `text` — optional-властивість (`nil`, якщо тексту немає).
            answer = response.text
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
