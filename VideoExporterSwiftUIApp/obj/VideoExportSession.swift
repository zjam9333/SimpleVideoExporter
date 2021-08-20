//
//  VideoExportSession.swift
//  VideoExporterSwiftUIApp
//
//  Created by zjj on 2021/8/20.
//  Copyright © 2021 zjj. All rights reserved.
//

import Foundation
import AVFoundation

class VideoExportSession {
//    let input: URL
//    let output: URL
//    private let hevc: Bool
    
    private let session: AVAssetExportSession?
    
    init(input: URL, output: URL, hevc: Bool) {
//        self.input = input
//        self.output = output
//        self.hevc = hevc
        
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
