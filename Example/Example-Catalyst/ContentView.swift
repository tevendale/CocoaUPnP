//
//  ContentView.swift
//  Example-Catalyst
//
//  Created by Stuart Tevendale on 05/11/2023.
//  Copyright © 2023 ARCAM. All rights reserved.
//

import SwiftUI

struct ContentView: View {
    var body: some View {
        VStack {
            Image(systemName: "globe")
                .imageScale(.large)
                .foregroundStyle(.tint)
            Text("Hello, world!")
        }
        .padding()
    }
}

#Preview {
    ContentView()
}
