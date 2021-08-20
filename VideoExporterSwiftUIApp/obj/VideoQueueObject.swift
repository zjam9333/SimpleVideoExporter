//
//  VideoQueueObject.swift
//  VideoExporterSwiftUIApp
//
//  Created by zjj on 2021/8/20.
//  Copyright © 2021 zjj. All rights reserved.
//

import Foundation

class VideoQueueObject: ObservableObject, Identifiable, Hashable, Equatable {
    var id: ObjectIdentifier {
        return ObjectIdentifier(self)
    }
    
    static func == (lhs: VideoQueueObject, rhs: VideoQueueObject) -> Bool {
        return lhs.inputUrl == rhs.inputUrl
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(self.inputUrl)
    }
    
    let inputUrl: URL
    
    var fileName: String {
        let lastCom = inputUrl.lastPathComponent
        return lastCom.removingPercentEncoding ?? lastCom
    }
    
    init(inputUrl: URL) {
        self.inputUrl = inputUrl
    }
    
    var didStart: Bool {
        return self.videoExporter?.status == .exporting
    }
    
    @Published var progress: Double = 0
    
    private var videoExporter: VideoExportSession?
    private var timer: Timer?
    
    func start(outputPath: String, hevc: Bool = false, progress: ((Double) -> Void)?, completion: @escaping ((Result<String, Error>) -> Void)) {
        // progress check
        self.timer = Timer(timeInterval: 0.1, repeats: true, block: { [weak self] timer in
            self?.progress = Double(self?.videoExporter?.progress ?? 0)
            progress?(self?.progress ?? 0)
        })
        RunLoop.main.add(self.timer!, forMode: .common)
        
        // file export
        self.videoExporter?.cancel()
        let filename = self.fileName
        var outputFile = outputPath.appending(filename)
        if FileManager.default.fileExists(atPath: outputFile) {
            if let ext = outputFile.split(separator: ".").last {
                let time = Date.timeIntervalSinceReferenceDate.hashValue
                let random = time & 0xFFFFFF
                outputFile = outputFile.appending("\(random).\(ext)")
            }
        }
        
        self.videoExporter = VideoExportSession(input: self.inputUrl, output: URL(fileURLWithPath: outputFile), hevc: hevc)
        self.videoExporter?.start { [weak self] in
            self?.timer?.invalidate()
            if let err = self?.videoExporter?.error {
                completion(.failure(err))
            } else {
                completion(.success(filename))
            }
        }
    }
}
