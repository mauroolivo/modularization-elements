import SwiftUI

public struct AppButton: View {
    private let title: String
    private let action: () -> Void

    public init(_ title: String, action: @escaping () -> Void) {
        self.title = title
        self.action = action
    }

    public var body: some View {
        Button(title, action: action)
            .buttonStyle(.borderedProminent)
            .controlSize(.small)
    }
}

#Preview("AppButton") {
    AppButton("Retry") {}
        .padding()
}
