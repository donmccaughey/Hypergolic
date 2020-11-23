//
//  ContentView.swift
//  Shared
//
//  Created by Don McCaughey on 11/22/20.
//

import SwiftUI
import Hydrazine


struct ContentView: View {
    let transaction = GeminiTransaction()
    
    var body: some View {
        Text("Hello, world!")
            .padding()
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
