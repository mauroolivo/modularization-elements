import SwiftUI

public struct Badge: View {
    private let text: String

    public init(_ text: String) {
        self.text = text
    }

    public var body: some View {
        Text(text)
            .font(.caption)
            .fontWeight(.semibold)
            .foregroundStyle(.blue)
            .padding(.horizontal, AppSpacing.xSmall)
            .padding(.vertical, AppSpacing.xxSmall)
            .background(Color.blue.opacity(0.12), in: Capsule())
    }
}

#Preview("Badge") {
    Badge("Popular")
        .padding()
}
