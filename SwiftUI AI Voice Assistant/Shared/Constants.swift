//
//  Constants.swift
//  SwiftUI AI Voice Assistant
//
//  Created by Roy's MacBook M1 on 24/04/2024.
//

import Foundation

// sk-proj-YSzTMRuBilM96se0IDkaT3BlbkFJuKl6iuFY9Wv0qLKhWzpg

struct Constants {
    
    
    static var apiKey: String {
        guard let apiKey = ProcessInfo.processInfo.environment["OPENAI_API_KEY"] else {
            fatalError("OpenAI API Key not found in environment variables")
        }
        
        return apiKey
    }
}

