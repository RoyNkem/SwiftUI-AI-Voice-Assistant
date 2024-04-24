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
    
    let client = OpenAIClient(apiKey: Constants.apiKey) //key stored in env
    
    
}
