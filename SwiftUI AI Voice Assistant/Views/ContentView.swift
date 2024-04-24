//
//  ContentView.swift
//  SwiftUI AI Voice Assistant
//
//  Created by Roy's MacBook M1 on 22/04/2024.
//

import SwiftUI
import SiriWaveView


struct ContentView: View {
    @State var vm = ViewModel()
    @State var isSymbolAnimating: Bool = false
    
    var body: some View {
        VStack {
            Text("AI Voice Assistant")
                .font(.title)
            
            Spacer()
            SiriWaveView()
                .power(power: vm.audioPower)
                .opacity(vm.siriWaveFormOpacity)
                .frame(height: 25)
                .overlay {
                    overlayView
                }
            Spacer()
            
            switch vm.state {
            case .recordingSpeech:
                cancelRecordingButton
                
            case .processingSpeech, .playingSpeech:
                cancelButton
                
            default: EmptyView()
                
            }
            
            Picker("Select Voice", selection: $vm.selectedVoice) {
                ForEach(VoiceType.allCases, id: \.self) {
                    Text($0.rawValue).id($0)
                }
            }
            .pickerStyle(.segmented)
            .disabled(!vm.isIdle)
            
            if case let .error(error) = vm.state {
                Text(error.localizedDescription)
                    .foregroundStyle(Color.red)
                    .font(.caption)
                    .lineLimit(2)
            }
            
        }
        .padding()
    }
    
    
    //MARK: - overlayView
    @ViewBuilder
    private var overlayView: some View {
        switch vm.state {
        case .idle, .error:
            startCaptureButton
        case .processingSpeech:
            animatedButton
        default: EmptyView()
        }
    }
    
    @ViewBuilder
    private var animatedButton: some View {
        Image(systemName: "brain")
            .symbolEffect(
                .bounce.up.byLayer,
                options: .repeating,
                value: isSymbolAnimating
            )
    }
    
    //MARK: - startCaptureButton
    private var startCaptureButton: some View {
        Button(action: { vm.startCaptureAudio()
        }) {
            
            Image(systemName: "mic.circle")
                .symbolRenderingMode(.multicolor)
                .font(.system(size: 128))
        }
        .buttonStyle(.borderless)
    }
    
    
    //MARK: - cancelButton
    private var cancelButton: some View {
        Button(role: .destructive,
               action: { vm.cancelProcessingTask()
        }) {
            
            Image(systemName: "stop.circle.fill")
                .symbolRenderingMode(.monochrome)
                .foregroundStyle(Color.red)
                .font(.system(size: 44))
        }
        .buttonStyle(.borderless)
    }
    
    //MARK: - cancelRecordingButton
    private var cancelRecordingButton: some View {
        Button(role: .destructive,
               action: { vm.cancelRecording()
            
        }) {
            
            Image(systemName: "mark.circle.fill")
                .symbolRenderingMode(.multicolor)
                .font(.system(size: 44))
        }
        .buttonStyle(.borderless)
    }
}

#Preview("Processing Speech") {
    return ContentView()
    
}
