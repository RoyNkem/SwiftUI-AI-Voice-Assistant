//
//  VoiceType.swift
//  SwiftUI AI Voice Assistant
//
//  Created by Roy's MacBook M1 on 24/04/2024.
//

import Foundation

enum VoiceType: String {
    case alloy, echo, fable, onyx, nova, shimmer
}


//MARK: - Codable
extension VoiceType: Codable {
    
}

//MARK: - Hashable
extension VoiceType: Hashable {
    
}

//MARK: - Sendable
extension VoiceType: Sendable {
    
}

//MARK: - CaseIterable
extension VoiceType: CaseIterable {
    
}
