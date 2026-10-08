import SwiftUI
import CatalogFeature
import Networking

struct ContentView: View {
    /// App layer creates infrastructure and passes it to features via lightweight inputs
    private let catalogInput: CatalogInput
    
    init() {
        // App layer: assemble infrastructure
        let httpClient = HTTPClient()
        let repository = LiveCatalogRepository(httpClient: httpClient)
        
        // App layer: wrap in feature input
        self.catalogInput = CatalogInput(repository: repository)
    }
    
    var body: some View {
        CatalogView(input: catalogInput)
    }
}

#Preview {
    ContentView()
}
