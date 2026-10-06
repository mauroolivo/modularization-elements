import SwiftUI

public struct Card<Content: View>: View {
    private let content: Content

    public init(@ViewBuilder content: () -> Content) {
        self.content = content()
    }

    public var body: some View {
        content
            .padding(AppSpacing.small)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(
                RoundedRectangle(cornerRadius: 12, style: .continuous)
                    .fill(Color.secondary.opacity(0.12))
            )
    }
}

#Preview("Card") {
    Card {
        VStack(alignment: .leading, spacing: AppSpacing.xSmall) {
            Text("Canvas Tote")
                .font(.headline)
            Text("Everyday carry")
                .font(.subheadline)
                .foregroundStyle(.secondary)
        }
    }
    .padding()
}
