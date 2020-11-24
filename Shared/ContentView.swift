import SwiftUI
import Hydrazine


struct ContentView: View {
    let transaction = GeminiTransaction(url: URL(string: "gemini://gemini.circumlunar.space/")!)
    
    var body: some View {
        Text("\(transaction.url)")
            .padding()
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
