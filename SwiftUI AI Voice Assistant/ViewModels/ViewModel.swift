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
    
    private var audioplayer: AVAudioPlayer!
    private var audioRecorder: AVAudioRecorder!
    
    //for visionOS and iOS
#if !os(macOS)
    var recordingSession = AVAudioSession.sharedInstance()
#endif
    
    //animationTimer to detect when user stops talking
    var animationTimer: Timer?
    var recordingTimer: Timer?
    var audioPower: CGFloat?
    var selectedVoice: VoiceType = .alloy
    private var prevAudioPower: Double?
    private var processingSpeechTask: Task<Void, Never>?
    
    var state: VoiceChatState = .idle {
        didSet { print( state )}
    }
    
    var isIdle: Bool {
        if case .idle = state { //pattern matching
            return true
        }
        return false
    }
    
    //condition to show the wave form
    var siriWaveFormOpacity: CGFloat {
        switch state {
        case .recordingSpeech, .playingSpeech: return 1
        default: return 0
        }
    }
    
    private var captureURL: URL {
        FileManager.default.urls(for: .cachesDirectory, in: .userDomainMask)
            .first!.appendingPathExtension("recording.m4a")
    }
    
    override init() {
        super.init()
#if !os(macOS)
        do {
#if os(iOS)
            try recordingSession.setCategory(.playAndRecord, options: .defaultToSpeaker)
#else
            try recordingSession.setCategory(.playAndRecord, options: .default)
#endif
            
            try recordingSession.setActive(true)
            
            AVAudioApplication.requestRecordPermission { [unowned self] allowed in
                if !allowed {
                    self.state = .error("Recording not allowed by the user")
                }
            }
        } catch {
            state = .error(error)
        }
#endif
        
    }
    
    func startCaptureAudio() {
        guard audioRecorder == nil else {
            state = .error("Audio recorder is already active")
            return
        }
        resetValues()
        state = .recordingSpeech
        
        do {
            audioRecorder = try AVAudioRecorder(
                url: captureURL,
                settings: audioSettings()
            )
            audioRecorder.isMeteringEnabled = true
            audioRecorder.delegate = self
            audioRecorder.record()
            startTimers() //animation Timer and recording timer
            
        } catch {
            resetValues()
            state = .error(error)
        }
    }
    
    func cancelProcessingTask() {
        processingSpeechTask?.cancel()
        processingSpeechTask = nil
        resetValues()
        state = .idle
    }
    
    func cancelRecording() {
        resetValues()
        state = .idle
    }
    
    //MARK: - Helper Methods: finishCaptureAudio
    
    private func finishCaptureAudio() {
        resetValues()
        do {
            let data = try Data(contentsOf: captureURL)
            let task = processingSpeechTask(audioData: data)
            print("finished processing speech")
        } catch {
            state = .error(error)
            resetValues()
        }
    }
    
    //MARK: - processingSpeechTask(audioData:)
    private func processingSpeechTask(audioData: Data) -> Task<Void, Never> {
        Task { @MainActor [unowned self] in
            do {
                self.state = .processingSpeech
                let prompt = try await client.generateAudioTransciptions(audioData: audioData)
                
                try Task.checkCancellation()
                let responseText = try await client.promptChatGPT(prompt: prompt)
                
                try Task.checkCancellation()
                let data = try await client.generateSpeechFrom(
                    input: responseText,
                    voice: .init(rawValue: selectedVoice.rawValue) ?? .alloy
                )
                
                try Task.checkCancellation()
                try self.playAudio(data: data)
                
            } catch {
                if Task.isCancelled { return }
                state = .error(error.localizedDescription)
                resetValues()
            }
        }
    }
    
    //MARK: - playAudio(data:)
    private func playAudio(data: Data) throws {
        self.state = .playingSpeech
        audioplayer = try AVAudioPlayer(data: data)
        audioplayer.isMeteringEnabled = true
        audioplayer.delegate = self
        audioplayer.play()
        
        animationTimer = Timer.scheduledTimer(withTimeInterval: 0.2, repeats: true, block: { [unowned self] _ in
            guard self.audioplayer != nil else { return }
            self.audioplayer.updateMeters()
            let power = min(1, max(0, 1 - abs(Double(self.audioplayer.averagePower(forChannel: 0)) / 160)))
            self.audioPower = power
        })
    }
    
    //MARK: - startTimers()
    private func startTimers() {
        animationTimer = Timer.scheduledTimer(withTimeInterval: 0.2, repeats: true, block: { [unowned self] _ in
            print("start animationTimer now")
            guard self.audioRecorder != nil else { return }
            self.audioRecorder.updateMeters()
            let power = min(1, max(0, 1 - abs(Double(self.audioRecorder.averagePower(forChannel: 0)) / 50)))
            self.audioPower = power
        })
        
        recordingTimer = Timer.scheduledTimer(withTimeInterval: 1.6, repeats: true, block: { [unowned self] _ in
            print("start recordingTimer now")
            guard self.audioRecorder != nil else { return }
            self.audioRecorder.updateMeters()
            let power = min(1, max(0, 1 - abs(Double(self.audioRecorder.averagePower(forChannel: 0)) / 50)))
            
            self.handlePowerChange(power)
        })
    }
    
    //MARK: - audioSettings()
    private func audioSettings() -> [String: Any] {
        [
            AVFormatIDKey: Int(kAudioFormatMPEG4AAC),
            AVSampleRateKey: 12000,
            AVNumberOfChannelsKey: 1,
            AVEncoderAudioQualityKey: AVAudioQuality.high.rawValue
        ]
    }
    
    //MARK: - handlePowerChange(_:)
    private func handlePowerChange(_ power: Double) {
        if prevAudioPower == 0 {
            prevAudioPower = power
            return
        }
        if let prevAudioPower = prevAudioPower, prevAudioPower < 0.3 && power < 0.25 {
            finishCaptureAudio()
        }
        prevAudioPower = power
    }
    
    //MARK: - resetValues()
    private func resetValues() {
        audioPower = 0
        prevAudioPower = 0
        audioRecorder?.stop()
        audioplayer?.stop()
        audioRecorder = nil
        audioplayer = nil
        recordingTimer?.invalidate()
        recordingTimer = nil
        animationTimer?.invalidate()
        animationTimer = nil
    }
}



//MARK: - AVAudioRecorderDelegate
extension ViewModel: AVAudioRecorderDelegate {
    func audioRecorderDidFinishRecording(_ recorder: AVAudioRecorder, successfully flag: Bool) {
        if !flag {
            resetValues()
            state = .idle
        }
    }
}

//MARK: - AVAudioPlayerDelegate
extension ViewModel: AVAudioPlayerDelegate {
    func audioPlayerDidFinishPlaying(_ player: AVAudioPlayer, successfully flag: Bool) {
        //when chatGPT finishes playing
        resetValues()
        state = .idle
    }
}
