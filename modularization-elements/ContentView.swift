//

import SwiftUI
import CatalogFeature

struct ContentView: View {
    private let input: CatalogInput

    init(input: CatalogInput) {
        self.input = input
    }

    var body: some View {
        CatalogView(input: input)
    }
}

#Preview {
    ContentView(input: .default)
}
