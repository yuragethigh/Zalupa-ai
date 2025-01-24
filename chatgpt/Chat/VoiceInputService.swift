//
//  VoiceInputService.swift
//  GPTClone
//
//  Created by Yuriy on 03.10.2024.
//

import AVFoundation
import Speech

final class VoiceInputService {
        
    private let speechRecognizer = SFSpeechRecognizer(locale: Locale.current)
    private var recognitionRequest: SFSpeechAudioBufferRecognitionRequest?
    private var recognitionTask: SFSpeechRecognitionTask?
    private let audioEngine = AVAudioEngine()

#if DEBUG
    deinit {
        print("✅ deinit - VoiceInput")
    }
#endif
    

    func startRecognition(completion: @escaping (String?) -> Void) {
        do {
            recognitionRequest = SFSpeechAudioBufferRecognitionRequest()
            guard let recognitionRequest = recognitionRequest else {
                return completion(nil)
            }
            
            recognitionTask = speechRecognizer?.recognitionTask(with: recognitionRequest) { result, error in
                if let result = result {
                    completion(result.bestTranscription.formattedString)
                }
            }
            
            let recordingFormat = audioEngine.inputNode.outputFormat(forBus: 0)
            audioEngine.inputNode.installTap(onBus: 0, bufferSize: 1024, format: recordingFormat) { buffer, _ in
                recognitionRequest.append(buffer)
            }
            
            audioEngine.prepare()
            try audioEngine.start()
        } catch {
#if DEBUG
            print("❌ Start recording error - ", error)
#endif

            completion(nil)
        }
    }

    
    
    
    func stop() {
        audioEngine.inputNode.removeTap(onBus: 0)
        audioEngine.stop()
        audioEngine.reset()
        recognitionRequest?.endAudio()
        recognitionTask?.cancel()
        recognitionTask = nil
        recognitionRequest = nil
        
    }
}


final class PermissionVoiceInput {
    
#if DEBUG
    deinit {
        print("✅ deinit - PermissionVoiceInput")
    }
#endif
    
    
    func checkPermission(_ completion: @escaping (Bool) -> Void) {
        AVAudioSession.sharedInstance().requestRecordPermission {  isGranded in
            print(isGranded)
            guard isGranded else {
                return completion(false)
            }
            
            SFSpeechRecognizer.requestAuthorization { status in
                switch status {
                case .notDetermined, .denied, .restricted:
#if DEBUG
                    print("❌ Speech recognition not authorized")
#endif
                    
                    completion(false)
                    
                case .authorized:
#if DEBUG
                    print("✅ Speech recognition authorized")
#endif
                    
                    completion(true)
                @unknown default:
                    completion(false)
                }
            }
        }
    }
}
