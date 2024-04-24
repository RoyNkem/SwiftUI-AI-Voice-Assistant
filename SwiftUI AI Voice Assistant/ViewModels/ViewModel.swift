//
//  ViewModel.swift
//  SwiftUI AI Voice Assistant
//
//  Created by Roy's MacBook M1 on 24/04/2024.
//

import Foundation
import AVFoundation
import Observation
import XCAOpenAIClient //communicate with openAI APIs


@Observable
class ViewModel: NSObject {
    
    let client = OpenAIClient(apiKey: Constants.apiKey) //key stored in env var
    
    var selectedVoice: VoiceType = .alloy
    var state: VoiceChatState = .idle {
        didSet { print( state )}
    }
    
    var isIdle: Bool {
        if case .idle = state { //pattern matching
            return true
        }
        return false
    }
    
    var audioPower: CGFloat = 0.0
    var siriWaveFormOpacity: CGFloat = 0.0
    
    func startCaptureAudio() {
        
    }
    
    func cancelProcessingTask() {
        
        
    }
    
    func cancelRecording() {
        
    }
 
}
