//
//  CoinDetails.swift
//  Numismat
//
//  Аналог src/components/coin-details.tsx в Expo — вміст екрана монети без навігації.
//  Використовується у двох місцях (як і в Expo): екран монети (CoinView) і випадкова монета на Головній.
//
//  AI-кнопки — акордеон: відповідь показується під своєю кнопкою і зберігається;
//  повторний тап ховає/показує її, а якщо була помилка — запитує знову. Можна відкрити всі, запити йдуть паралельно.
//  Кнопка Gemini — завжди є (Firebase AI Logic), решта будуються зі списку моделей сервера (`GET /providers`),
//  тож нова модель на сервері з'являється в додатку без релізу.
//

// Потрібен, хоча `Chat` ми отримуємо з Lib/AI.swift: через налаштування `MEMBER_IMPORT_VISIBILITY`
// методи чужого модуля (`sendMessage`, `text`) видно лише у файлах, які імпортують його явно.
// В ESM аналогічно: щоб викликати функцію з пакета, її треба імпортувати в цьому файлі.
import FirebaseAILogic
import SwiftUI

// ≈ `const QUESTION = 'Розкажи цікаві факти про цю монету'`.
// `private` на рівні файлу ≈ константа модуля без `export`.
private let question = "Розкажи цікаві факти про цю монету"

// ≈ type AiButton = { id: string; title: string; logo: number | string; ask: (coin: Coin) => Promise<string> }.
private struct AIButton: Identifiable {
    // ≈ `logo: number | string`: або локальна картинка (`require(...)`), або URL з сервера.
    // Union-типу в Swift немає — замість нього `enum` з варіантами, що несуть значення
    // (≈ discriminated union `{ kind: 'asset', ... } | { kind: 'url', ... }`).
    enum Logo {
        // Картинка з Assets.xcassets: Xcode генерує константу `.gemini` (≈ `require`, перевіряється під час збірки).
        case asset(ImageResource)
        case url(String)
    }

    let id: String
    let title: String
    let logo: Logo
    // Тип функції як значення: приймає `Coin`, асинхронна, може кинути помилку, повертає `String`.
    let ask: (Coin) async throws -> String
}

// ≈ const geminiButton: AiButton = { id: 'gemini', ..., ask: async (coin) => (...).response.text() }.
private let geminiButton = AIButton(
    id: "gemini",
    title: "Запитати в Gemini про монету",
    logo: .asset(.gemini),
    // `{ coin in ... }` — замикання (≈ стрілкова функція `(coin) => ...`).
    // `text` у Swift SDK — optional, тож `?? ""` (≈ `text()` у JS, що завжди повертає рядок).
    ask: { coin in try await startCoinChat(coin).sendMessage(question).text ?? "" }
)

// ≈ const toButton = (p: Provider): AiButton => ({ id: p.id, title: `Запитати в ${p.title} про монету`, ... }).
private func toButton(_ p: Provider) -> AIButton {
    AIButton(
        id: p.id,
        title: "Запитати в \(p.title) про монету",
        logo: .url(p.logo),
        // `.user` — скорочений запис `ChatMessage.Role.user` (тип відомий з контексту).
        ask: { coin in try await askServer(p.id, coin: coin, messages: [ChatMessage(role: .user, content: question)]) }
    )
}

// Значення для `.fullScreenCover(item:)`: SwiftUI вимагає `Identifiable`, щоб відрізняти, яке саме фото
// показане, тому URL загорнуто в struct з `id`.
private struct Photo: Identifiable {
    let url: String
    var id: String { url }
}

// ≈ `{ text: string; error?: boolean }` — збережена відповідь однієї кнопки.
private struct Answer {
    let text: String
    let isError: Bool
}

struct CoinDetails: View {
    let coin: Coin

    // ≈ const [answers, setAnswers] = useState<Record<string, { text; error? }>>({});
    // `[String: Answer]` — словник ≈ `Record<string, Answer>`.
    @State private var answers: [String: Answer] = [:]
    // ≈ `open` / `loading` — `Record<string, boolean>`. У Swift для "увімкнено чи ні для id"
    // зручніше `Set<String>` — множина id (≈ JS `Set`): `contains`, `insert`, `remove`.
    @State private var openIds: Set<String> = []
    @State private var loadingIds: Set<String> = []
    // ≈ const [providers, setProviders] = useState<Provider[]>([]);
    //   const [providersError, setProvidersError] = useState<string | null>(null);
    @State private var providers: [Provider] = []
    @State private var providersError: String?
    // Фото, відкрите на весь екран (`nil` — нічого не відкрито). В Expo це роут `/photo?uri=...`,
    // а тут модалка керується станом: є значення — показана, `nil` — закрита.
    @State private var photo: Photo?

    // ≈ `const aiButtons = [geminiButton, ...providers.map(toButton)]` у тілі компонента.
    // Обчислювана властивість перераховується при кожному зверненні — як змінна в тілі функції-компонента.
    // `+` для масивів ≈ спред `[a, ...b]`.
    private var aiButtons: [AIButton] {
        [geminiButton] + providers.map { toButton($0) }
    }

    var body: some View {
        // ≈ <ScrollView contentContainerStyle={{ padding: 16, gap: 8 }}>.
        ScrollView {
            VStack(alignment: .leading, spacing: 8) {
                // ≈ styles.photos: { flexDirection: 'row', gap: 12, justifyContent: 'center', marginBottom: 8 }.
                HStack(spacing: 12) {
                    photoButton(coin.avers)
                    photoButton(coin.revers)
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
                    // ≈ `aiButtons.map((button) => <View key={button.id} style={styles.aiItem}>...)`.
                    ForEach(aiButtons) { button in
                        aiItem(button)
                    }
                    // ≈ `{providersError ? <Text style={styles.error}>...</Text> : null}`.
                    if let providersError {
                        Text("Помилка завантаження моделей: \(providersError)")
                            .foregroundStyle(.red)
                    }
                }
                .padding(.top, 16)
            }
            .padding(16)
        }
        // ≈ `useEffect(() => { fetchProviders().then(setProviders).catch(...) }, [])`.
        // `.task` запускається щоразу, коли view з'являється (напр. повернення на таб),
        // тому `guard` — щоб не перезапитувати список, якщо він уже є.
        .task {
            guard providers.isEmpty else { return }
            do {
                providers = try await fetchProviders()
            } catch {
                providersError = String(describing: error)
            }
        }
        // ≈ <Stack.Screen name="photo" options={{ presentation: 'fullScreenModal' }} />.
        // `item: $photo` — коли `photo` стає не `nil`, екран відкривається з цим значенням;
        // `dismiss()` у PhotoView сам поверне `photo` в `nil`.
        // Як і `fullScreenModal`, на відміну від sheet, не закривається свайпом вниз — тож не конфліктує з pan-жестом.
        .fullScreenCover(item: $photo) { photo in
            PhotoView(url: photo.url)
        }
    }

    // ≈ <Link href={{ pathname: '/photo', params: { uri } }} asChild disabled={!uri}><Pressable><Image/></Pressable></Link>.
    // Кодувати URL (`encodeURIComponent`, як в Expo) не треба: у екран передається саме значення, а не URL роуту.
    private func photoButton(_ url: String?) -> some View {
        Button {
            // `if let` — відкриваємо лише, якщо фото є.
            if let url {
                photo = Photo(url: url)
            }
        } label: {
            CoinPhoto(url: url, size: 150)
        }
        .buttonStyle(.plain)
        .disabled(url == nil)
    }

    // Один елемент акордеону: кнопка + відповідь під нею (≈ <View style={styles.aiItem}>).
    private func aiItem(_ button: AIButton) -> some View {
        let answer = answers[button.id]
        let isLoading = loadingIds.contains(button.id)
        let isOpen = openIds.contains(button.id)

        // `spacing: 0` — кнопка й відповідь впритул, відступи задають самі елементи.
        return VStack(alignment: .leading, spacing: 0) {
            // ≈ <Pressable style={styles.aiButton} onPress={() => onPress(button)} disabled={loading[button.id]}>.
            // Дія кнопки не може бути `async`, тому async-функцію запускаємо в `Task { ... }`.
            Button {
                Task { await onPress(button) }
            } label: {
                // ≈ styles.aiButton: { flexDirection: 'row', alignItems: 'center', gap: 10, padding: 12 }.
                HStack(spacing: 10) {
                    logo(button.logo)
                    // ≈ styles.aiButtonText: { fontWeight: '600', flex: 1 }; `maxWidth: .infinity` ≈ `flex: 1`.
                    Text(button.title)
                        .fontWeight(.semibold)
                        .frame(maxWidth: .infinity, alignment: .leading)
                    // ≈ loading ? <ActivityIndicator /> : (є відповідь без помилки ? <Ionicons chevron /> : null).
                    if isLoading {
                        ProgressView()
                    } else if let answer, !answer.isError {
                        // SF Symbols "chevron.up" / "chevron.down" ≈ Ionicons 'chevron-up' / 'chevron-down'.
                        Image(systemName: isOpen ? "chevron.up" : "chevron.down")
                            .foregroundStyle(.secondary)
                    }
                }
                .padding(12)
                // З `.buttonStyle(.plain)` тапається лише "непрозорий" вміст (текст, картинка).
                // `contentShape` робить тап-зоною весь прямокутник рядка, як у `<Pressable>`.
                .contentShape(.rect)
            }
            // `.plain` — без системного стилю кнопки (інакше SwiftUI перефарбує текст у синій).
            .buttonStyle(.plain)
            .disabled(isLoading)

            // ≈ `{open[id] && answers[id] ? (error ? <Text style={styles.error}> : <MarkdownText />) : null}`.
            if isOpen, let answer {
                Group {
                    if answer.isError {
                        Text(answer.text)
                            .foregroundStyle(.red)
                    } else {
                        MarkdownText(value: answer.text)
                    }
                }
                // ≈ styles.answer: { paddingHorizontal: 12, paddingBottom: 12 }.
                .padding([.horizontal, .bottom], 12)
            }
        }
        // ≈ styles.aiItem: { borderRadius: 12, borderWidth: 1, borderColor: '#ddd', backgroundColor: '#fff' }.
        // Рамки як CSS-властивості в SwiftUI немає: малюємо контур тієї ж форми
        // поверх view через `.overlay` (`stroke` — лише лінія, без заливки).
        .background(Color(.systemBackground), in: .rect(cornerRadius: 12))
        .overlay {
            RoundedRectangle(cornerRadius: 12)
                .stroke(Color(.systemGray4))
        }
    }

    // ≈ <Image source={button.logo} style={{ width: 24, height: 24, borderRadius: 4 }} />.
    // `expo-image` сам приймає і `require`, і URL, а тут розбираємо варіанти `enum` через `switch`
    // (≈ `switch (logo.kind)` для discriminated union; `let` витягує значення з варіанта).
    private func logo(_ logo: AIButton.Logo) -> some View {
        Group {
            switch logo {
            case .asset(let resource):
                Image(resource).resizable()
            case .url(let url):
                // Картинка з мережі (як у CoinPhoto); поки вантажиться — сірий квадрат.
                AsyncImage(url: URL(string: url)) { image in
                    image.resizable()
                } placeholder: {
                    Color(.systemGray5)
                }
            }
        }
        .frame(width: 24, height: 24)
        .clipShape(.rect(cornerRadius: 4))
    }

    // ≈ const onPress = async ({ id, ask }: AiButton) => { ... }.
    private func onPress(_ button: AIButton) async {
        let id = button.id
        // Уже є відповідь без помилки — лише сховати/показати (≈ `setOpen((o) => ({ ...o, [id]: !o[id] }))`).
        if let answer = answers[id], !answer.isError {
            if openIds.contains(id) {
                openIds.remove(id)
            } else {
                openIds.insert(id)
            }
            return
        }
        // ≈ setLoading((l) => ({ ...l, [id]: true })); setOpen((o) => ({ ...o, [id]: true })).
        // У React стан змінюють через нову копію об'єкта (`{ ...o }`), а тут просто змінюємо `Set` —
        // SwiftUI сам помітить зміну `@State` і перемалює view.
        loadingIds.insert(id)
        openIds.insert(id)
        // `defer` виконується при виході з функції за будь-яких умов ≈ блок `finally`.
        defer { loadingIds.remove(id) }
        do {
            // ≈ setAnswers((a) => ({ ...a, [id]: { text } })).
            answers[id] = Answer(text: try await button.ask(coin), isError: false)
        } catch {
            // ≈ setAnswers((a) => ({ ...a, [id]: { text: `Помилка: ${String(e)}`, error: true } })).
            answers[id] = Answer(text: "Помилка: \(error)", isError: true)
        }
    }
}

#Preview {
    CoinDetails(coin: Coin(id: "1", country: "ua", name: "10 гривень", value: "10", currency: "uag",
                           year: "2025", info: "ДСНС України Сміливі рятувати життя", avers: nil, revers: nil))
}
