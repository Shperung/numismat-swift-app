//
//  MarkdownText.swift
//  Numismat
//
//  Аналог src/components/markdown-text.tsx в Expo — показ відповіді AI як markdown.
//
//  В Expo це робить бібліотека `react-native-marked` (`useMarkdown`). У SwiftUI бібліотека не потрібна
//  для inline-розмітки: `AttributedString(markdown:)` вбудований і розуміє **жирний**, *курсив*,
//  `код` і [посилання]. А от блоки (заголовки, списки) `Text` не малює, тож їх розбираємо самі
//  по рядках — для коротких відповідей моделі цього достатньо. Таблиці й блоки коду показуються як є.
//

import SwiftUI

struct MarkdownText: View {
    let value: String

    var body: some View {
        // ≈ `elements.map((element, index) => <Fragment key={index}>{element}</Fragment>)`.
        // Рядки не мають власного `id`, тому ключ — номер рядка (`\.offset` ≈ `key={index}`).
        // `enumerated()` дає пари (offset, element) ≈ `array.map((element, index) => ...)`.
        VStack(alignment: .leading, spacing: 6) {
            ForEach(Array(value.components(separatedBy: "\n").enumerated()), id: \.offset) { item in
                block(item.element.trimmingCharacters(in: .whitespaces))
            }
        }
        // ≈ styles.text: { fontSize: 14 }; `lineSpacing(4)` ≈ lineHeight: 20.
        .font(.system(size: 14))
        .lineSpacing(4)
    }

    // `@ViewBuilder` дозволяє повертати різні view з гілок `if / else`
    // (як функція, що повертає різний JSX залежно від умови).
    @ViewBuilder
    private func block(_ line: String) -> some View {
        // `prefix(while:)` — початок рядка, поки виконується умова: "## Заголовок" → "##".
        let hashes = line.prefix(while: { $0 == "#" }).count
        let digits = line.prefix(while: \.isNumber)

        if line.isEmpty {
            // Порожній рядок між абзацами — відступ і так дає `spacing` у VStack.
            EmptyView()
        } else if line == "---" || line == "***" {
            // ≈ <hr />.
            Divider()
        } else if (1...6).contains(hashes), line.dropFirst(hashes).hasPrefix(" ") {
            // "# ..." … "###### ..." ≈ h1…h6: розмір шрифту як в Expo (20, 18, 16, 15, 14, 14).
            let sizes: [CGFloat] = [20, 18, 16, 15, 14, 14]
            Text(inline(String(line.dropFirst(hashes + 1))))
                .font(.system(size: sizes[hashes - 1], weight: .bold))
                .padding(.top, 4)
        } else if line.hasPrefix("- ") || line.hasPrefix("* ") || line.hasPrefix("+ ") {
            // "- пункт" ≈ <li>: маркер + текст.
            listItem("•", String(line.dropFirst(2)))
        } else if !digits.isEmpty, line.dropFirst(digits.count).hasPrefix(". ") {
            // "1. пункт" — нумерований список, номер лишаємо як є.
            listItem("\(digits).", String(line.dropFirst(digits.count + 2)))
        } else {
            Text(inline(line))
        }
    }

    // Пункт списку: маркер і текст в один рядок; `.firstTextBaseline` вирівнює їх
    // по першому рядку тексту, коли текст пункту переноситься на кілька рядків.
    private func listItem(_ marker: String, _ text: String) -> some View {
        HStack(alignment: .firstTextBaseline, spacing: 6) {
            Text(marker)
            Text(inline(text))
        }
    }

    // Inline-markdown у межах рядка: `**жирний**`, `*курсив*`, `` `код` ``, посилання.
    // `.inlineOnlyPreservingWhitespace` — розбирати лише inline-розмітку і не "з'їдати" пробіли.
    // Якщо розбір не вдався — показуємо рядок як є (`try?` → `nil` → `??`).
    private func inline(_ text: String) -> AttributedString {
        (try? AttributedString(markdown: text, options: .init(interpretedSyntax: .inlineOnlyPreservingWhitespace)))
            ?? AttributedString(text)
    }
}

#Preview {
    MarkdownText(value: """
        ## Цікаві факти
        **10 гривень** — *обігова* монета.
        - Випущена у `2025` році
        - Присвячена ДСНС
        1. Перший пункт
        2. Другий пункт
        """)
        .padding()
}
