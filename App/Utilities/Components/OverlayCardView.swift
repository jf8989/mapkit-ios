// App/Shared/Components/OverlayCardView.swift

import SwiftUI

/// Reusable scrim + card overlay. Dismiss on tap outside or OK.
public struct OverlayCardView<Content: View>: View {
    public let title: String?
    public let onDismiss: () -> Void
    @ViewBuilder public let content: () -> Content
    @State private var shown = false

    public init(
        title: String? = nil,
        onDismiss: @escaping () -> Void,
        @ViewBuilder content: @escaping () -> Content
    ) {
        self.title = title
        self.onDismiss = onDismiss
        self.content = content
    }

    public var body: some View {
        ZStack {
            Color.black.opacity(shown ? 0.35 : 0).ignoresSafeArea()
                .contentShape(Rectangle())
                .onTapGesture { dismiss() }

            VStack(spacing: 12) {
                if let title {
                    Text(title).font(.headline)
                        .frame(maxWidth: .infinity, alignment: .leading)
                    Divider().opacity(0.6)
                }
                content()
                Button("OK", action: dismiss).buttonStyle(.borderedProminent)
            }
            .padding(16)
            .frame(maxWidth: 360)
            .background(
                .ultraThinMaterial,
                in: RoundedRectangle(cornerRadius: 18, style: .continuous)
            )
            .shadow(color: .black.opacity(0.18), radius: 18, y: 8)
            .scaleEffect(shown ? 1 : 0.98)
            .offset(y: shown ? 0 : 10)
            .opacity(shown ? 1 : 0)
        }
        .onAppear {
            withAnimation(.spring(response: 0.36, dampingFraction: 0.9)) {
                shown = true
            }
        }
        .accessibilityAddTraits(.isModal)
    }

    private func dismiss() {
        withAnimation(.easeInOut(duration: 0.22)) { shown = false }
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.22) { onDismiss() }
    }
}
