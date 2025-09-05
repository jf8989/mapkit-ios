// App/Shared/Components/OverlayCardView.swift

import SwiftUI

/// Reusable scrim + card overlay. Dismisses on background tap or OK button.
/// Usage:
/// OverlayCardView(title:"Title", onDismiss:{ ... }) { Text("Body") }
public struct OverlayCardView<Content: View>: View {
    public let title: String?
    public let onDismiss: () -> Void
    @ViewBuilder public let content: () -> Content

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
            Color.black.opacity(0.35)
                .ignoresSafeArea()
                .onTapGesture { onDismiss() }

            VStack(spacing: 12) {
                if let title { Text(title).font(.headline) }
                content()
                Button("OK", action: onDismiss)
                    .buttonStyle(.borderedProminent)
            }
            .padding(16)
            .frame(maxWidth: 320)
            .background(
                .ultraThinMaterial,
                in: RoundedRectangle(cornerRadius: 16, style: .continuous)
            )
            .shadow(radius: 10)
        }
        .transition(.opacity.combined(with: .scale))
    }
}
