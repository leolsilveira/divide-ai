//
//  LocalLLMApp.swift
//  LocalLLM
//
//  Created by Leonardo Silveira on 11/5/25.
//

import SwiftUI

@main
struct LocalLLMApp: App {
    @StateObject private var model = Model()
    
    init() {}
    
    var body: some Scene {
        WindowGroup {
            NavigationView {
                WelcomeView()
                    .environmentObject(model)
            }
            .navigationViewStyle(StackNavigationViewStyle())
        }
    }
}
