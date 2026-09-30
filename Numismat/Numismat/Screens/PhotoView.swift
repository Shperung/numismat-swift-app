//
//  PhotoView.swift
//  Numismat
//
//  Аналог src/app/photo.tsx в Expo — фото монети на весь екран з pinch zoom.
//  Відкривається з CoinDetails через `.fullScreenCover` (≈ `presentation: 'fullScreenModal'`).
//
//  В Expo для жестів потрібні `react-native-gesture-handler` + `react-native-reanimated` (+ worklets),
//  а в SwiftUI жести й анімації вбудовані: `MagnifyGesture` ≈ `Gesture.Pinch()`,
//  `DragGesture` ≈ `Gesture.Pan()`, `TapGesture(count: 2)` ≈ `Gesture.Tap().numberOfTaps(2)`.
//  Окремий "UI-потік" (worklets / shared values) не потрібен — звичайний `@State` досить швидкий.
//

import SwiftUI

struct PhotoView: View {
    let url: String

    // ≈ `router.back()`: `dismiss` закриває екран, який показали модально (або повертає назад у стеку).
    @Environment(\.dismiss) private var dismiss

    // ≈ useSharedValue(...): поточні значення під час жесту + збережені після його завершення
    // (жест дає зміну відносно початку, тож потрібна "база", до якої її додавати).
    @State private var scale: CGFloat = 1
    @State private var savedScale: CGFloat = 1
    // `CGSize` — пара (width, height); тут це зсув по x / y (≈ `x`, `y` у Expo).
    @State private var offset: CGSize = .zero
    @State private var savedOffset: CGSize = .zero

    var body: some View {
        // `ZStack` ≈ контейнер, де діти лежать один на одному (як `position: 'absolute'` у RN).
        // `alignment: .topTrailing` — кнопку закриття притискаємо в правий верхній кут.
        ZStack(alignment: .topTrailing) {
            // ≈ backgroundColor: '#000'. `ignoresSafeArea()` — фон і під "чубчиком" / home-індикатором.
            Color.black.ignoresSafeArea()

            // ≈ <Image source={uri} contentFit="contain" />; `.scaledToFit()` ≈ `contain`.
            AsyncImage(url: URL(string: url)) { image in
                image.resizable().scaledToFit()
            } placeholder: {
                // `tint(.white)` — біла "крутилка" на чорному фоні.
                ProgressView().tint(.white)
            }
            // ≈ transform: [{ translateX }, { translateY }, { scale }] у `useAnimatedStyle`.
            .scaleEffect(scale)
            .offset(offset)
            // Жести ловимо на всьому екрані, а не лише на картинці (≈ `flex: 1` у Animated.View).
            // `contentShape` робить тап-зоною весь прямокутник, включно з прозорими місцями.
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .contentShape(.rect)
            // ≈ <GestureDetector gesture={Gesture.Simultaneous(pinch, pan, doubleTap)}>.
            // `simultaneously(with:)` — жести працюють одночасно, а не "хто перший".
            .gesture(pinch.simultaneously(with: pan).simultaneously(with: doubleTap))

            // ≈ <Pressable style={styles.close} onPress={() => router.back()}>.
            // Відступ від "чубчика" (`insets.top` в Expo) не потрібен: кнопка й так лишається
            // всередині safe area, бо `ignoresSafeArea` стоїть лише на фоні.
            Button {
                dismiss()
            } label: {
                // SF Symbol "xmark" ≈ Ionicons 'close'.
                Image(systemName: "xmark")
                    .font(.system(size: 20, weight: .semibold))
                    .foregroundStyle(.white)
                    // ≈ { padding: 6, borderRadius: 20, backgroundColor: 'rgba(255,255,255,0.2)' }.
                    .padding(10)
                    .background(.white.opacity(0.2), in: .circle)
            }
            .padding(.trailing, 16)
            .padding(.top, 8)
        }
    }

    // ≈ Gesture.Pinch().onUpdate(...).onEnd(...).
    // `magnification` ≈ `e.scale` — у скільки разів розвели пальці від початку жесту.
    private var pinch: some Gesture {
        MagnifyGesture()
            .onChanged { value in
                // ≈ Math.min(5, Math.max(1, savedScale.value * e.scale)).
                scale = min(5, max(1, savedScale * value.magnification))
            }
            .onEnded { _ in
                savedScale = scale
            }
    }

    // ≈ Gesture.Pan().onUpdate(...).onEnd(...); `translation` ≈ `e.translationX` / `e.translationY`.
    private var pan: some Gesture {
        DragGesture()
            .onChanged { value in
                // ≈ `if (scale.value === 1) return;` — не збільшене фото не рухаємо.
                guard scale > 1 else { return }
                offset = CGSize(width: savedOffset.width + value.translation.width,
                                height: savedOffset.height + value.translation.height)
            }
            .onEnded { _ in
                savedOffset = offset
            }
    }

    // ≈ Gesture.Tap().numberOfTaps(2).onEnd(...) — скинути зум і зсув.
    private var doubleTap: some Gesture {
        TapGesture(count: 2)
            .onEnded {
                // `withAnimation { ... }` ≈ `withTiming(...)`: зміни стану всередині анімуються.
                withAnimation {
                    scale = 1
                    offset = .zero
                }
                savedScale = 1
                savedOffset = .zero
            }
    }
}

#Preview {
    PhotoView(url: "")
}
