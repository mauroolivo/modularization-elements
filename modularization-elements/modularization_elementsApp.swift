//

import SwiftUI

@main
struct modularization_elementsApp: App {
    var body: some Scene {
        WindowGroup {
            ContentView(
                catalogInput: AppComposition.catalogInput(),
                favoritesInput: AppComposition.favoritesInput()
            )
        }
    }
}
