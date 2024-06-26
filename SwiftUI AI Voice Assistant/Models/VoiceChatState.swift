//
//  VoiceChatState.swift
//  SwiftUI AI Voice Assistant
//
//  Created by Roy's MacBook M1 on 24/04/2024.
//

import Foundation

enum VoiceChatState {
    case idle, recordingSpeech, processingSpeech, playingSpeech, error(Error)
}

