//
//  VideoQueueObject.swift
//  VideoExporterSwiftUIApp
//
//  Created by zjj on 2021/8/20.
//  Copyright © 2021 zjj. All rights reserved.
//

import Foundation

extension VideoQueueTask: Identifiable, Hashable, Equatable {
    static func == (lhs: VideoQueueTask, rhs: VideoQueueTask) -> Bool {
        return lhs.hashValue == rhs.hashValue
    }
    
    var id: ObjectIdentifier {
        return ObjectIdentifier(self)
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(self.inputUrl)
        hasher.combine(self.randomId)
    }
}

class VideoQueueTask: ObservableObject {
    enum State {
        case waiting
        case processing
        case finished
        case cancelled
        case failed(_ err: Error?)
    }
    
    let inputUrl: URL
    let randomId: Int = Date.timeIntervalSinceReferenceDate.hashValue & 0xFFFFFF
    
    var fileName: String {
        let lastCom = inputUrl.lastPathComponent
        return lastCom.removingPercentEncoding ?? lastCom
    }
    
    init(inputUrl: URL) {
        self.inputUrl = inputUrl
    }
    
    @Published private(set) var state: State = .waiting
    @Published private(set) var progress: Double = 0
    
    private var videoExporter: Session?
    private var timer: Timer?
    
    func start(outputPath: String, hevc: Bool = false, progress: ((Double) -> Void)?, completion: @escaping ((Result<String, Error>) -> Void)) {
        guard self.videoExporter == nil else {
            return
        }
        
        // progress check
        self.state = .processing
        
        self.timer = Timer(timeInterval: 0.1, repeats: true, block: { [weak self] timer in
            self?.progress = Double(self?.videoExporter?.progress ?? 0)
            if let status = self?.videoExporter?.status {
                switch status {
                case .exporting:
                    self?.state = .processing
                case .completed:
                    self?.state = .finished
                case .cancelled:
                    self?.state = .cancelled
                case .failed:
                    self?.state = .failed(self?.videoExporter?.error)
                default:
                    self?.state = .waiting
                }
            }
            progress?(self?.progress ?? 0)
        })
        RunLoop.main.add(self.timer!, forMode: .common)
        
        // file export
        let filename = self.fileName
        var outputFile = outputPath.appending(filename)
        if FileManager.default.fileExists(atPath: outputFile) {
            if let ext = outputFile.split(separator: ".").last {
                outputFile = outputFile.appending("\(self.randomId).\(ext)")
            }
        }
        
        self.videoExporter = Session(input: self.inputUrl, output: URL(fileURLWithPath: outputFile), hevc: hevc)
        self.videoExporter?.start { [weak self] in
            self?.timer?.invalidate()
            if let err = self?.videoExporter?.error {
                self?.state = .failed(err)
                completion(.failure(err))
            } else {
                if self?.videoExporter?.status == .cancelled {
                    self?.state = .cancelled
                } else {
                    self?.state = .finished
                }
                completion(.success(filename))
            }
        }
    }
    
    func cancel() {
        self.videoExporter?.cancel()
        self.state = .cancelled
    }
}

import AVFoundation

extension VideoQueueTask {
    class Session {
        private let session: AVAssetExportSession?
        
        init(input: URL, output: URL, hevc: Bool) {
            let inputAsset = AVURLAsset(url: input, options: nil)
            let preset = hevc ? AVAssetExportPresetHEVCHighestQuality : AVAssetExportPresetHighestQuality
            self.session = AVAssetExportSession(asset: inputAsset, presetName: preset)
            self.session?.outputURL = output
            self.session?.outputFileType = .mp4
        }
        
        var status: AVAssetExportSession.Status? {
            return session?.status
        }
        
        var progress: Double? {
            if let pro = self.session?.progress {
                return Double(pro)
            }
            return nil
        }
        
        var error: Error? {
            return self.session?.error
        }
        
        func start(completion: @escaping () -> Void) {
            self.session?.exportAsynchronously {
                DispatchQueue.main.async {
                    completion()
                }
            }
        }
        
        func cancel() {
            self.session?.cancelExport()
        }
    }
}
