//
//  SwiftUI_AI_Voice_AssistantApp.swift
//  SwiftUI AI Voice Assistant
//
//  Created by Roy's MacBook M1 on 22/04/2024.
//

import SwiftUI

@main
struct SwiftUI_AI_Voice_AssistantApp: App {
    let size: CGFloat = 400
    
    var body: some Scene {
        WindowGroup {
            ContentView()
            //limit the size of window for macOS -> fixed
#if os(macOS)
                .frame(width: size, height: size)
#endif
        }
#if os(macOS)
        .windowStyle(.hiddenTitleBar)
        .windowResizability(.contentSize)
#elseif os(visionOS)
        .defaultSize(width: size/1000, height: size/1000, depth: 0.0, in: .meters)
        .windowResizability(.contentSize)
#endif
    }
}
