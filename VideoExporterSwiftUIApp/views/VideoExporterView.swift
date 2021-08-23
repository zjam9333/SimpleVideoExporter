//
//  VideoExporterView.swift
//  VideoExporterSwiftUIApp
//
//  Created by zjj on 2021/8/19.
//  Copyright © 2021 zjj. All rights reserved.
//

import SwiftUI
import UniformTypeIdentifiers

struct VideoExporterView: View {
    @State var outputPath: String = ""
    @State var openingFile: Bool = false
    @State var pathAlert: Bool = false
    @State var usingH265: Bool = false
    
    @State var queueObjects = [VideoQueueTask]()
    @State var historyObjects = [VideoQueueTask]()
    
    var body: some View {
        GeometryReader { geo in
            VStack(alignment: .leading, spacing: 16) {
                HStack {
                    Text("Export Video Queue").font(.title)
                    Spacer()
                }
                .padding(.top, 20)
                HStack(spacing: 10) {
                    TextField("Output Path", text: $outputPath)
                        .disabled(true)
                        .disableAutocorrection(true)
                        .textFieldStyle(DefaultTextFieldStyle())
                    Button {
                        openingFile.toggle()
                    } label: {
                        Image(systemName: "folder.fill")
                        Text("Choose Output Path")
                    }
                }
                HStack(spacing: 10) {
//                    ProgressView(value: progress, total: 1)
                    Text("\(queueObjects.count) \(queueObjects.count == 1 ? "File" : "Files") in Queue")
                        .lineLimit(2)
                    Spacer()
                    Button {
                        historyObjects.removeAll()
                    } label: {
                        Image(systemName: "trash.fill")
                        Text("Clean History")
                    }
                    Picker(selection: $usingH265, label: EmptyView(), content: {
                        Text("H264").tag(false)
                        Text("H265").tag(true)
                    })
                    .pickerStyle(SegmentedPickerStyle())
                    .frame(width: 100)
                }
//                if let error = error {
//                    HStack {
//                        Text(error.localizedDescription).foregroundColor(.red)
//                        Spacer()
//                    }
//                }
                GeometryReader { geo in
                    ZStack {
                        ScrollView(.vertical, showsIndicators: true, content: {
                            VStack(spacing: 0) {
                                ForEach(historyObjects, id: \.self) { obj in
                                    VideoQueueCell(task: obj)
                                }
//                                if !historyObjects.isEmpty {
//                                    Color(.black).frame(height: 0.5)
//                                }
                                ForEach(queueObjects, id: \.self) { obj in
                                    VideoQueueCell(task: obj)
                                }
                            }
                        })
                        .frame(width: geo.size.width, height: geo.size.height)
                        if queueObjects.isEmpty && historyObjects.isEmpty {
                            Text("Drag Video Files Here")
                        }
                    }
                }
                .background(Color(NSColor.white))
            }
            .padding(.all, 20).frame(width: geo.size.width, height: geo.size.height)
        }
        .alert(isPresented: $pathAlert, content: {
            Alert(title: Text("Output Path Not Choosed"), message: nil, dismissButton: .default(Text("Go"), action: {
                self.openingFile.toggle()
            }))
        })
        .fileImporter(isPresented: $openingFile, allowedContentTypes: [.directory]) { result in
            if case .success(let url) = result {
                // 必须去除file:// 前缀？？？？
                self.outputPath = url.absoluteString.humanReadableFilePath
                self.shouldStartQueue()
            }
        }
        .onDrop(of: [.fileURL], isTargeted: nil) { providers in
            let id = UTType.fileURL.identifier
            for pro in providers {
                pro.loadItem(forTypeIdentifier: id, options: nil) { coding, err in
                    guard let data = coding as? Data, let url = URL(dataRepresentation: data, relativeTo: nil) else {
                        return
                    }
                    queueObjects.append(VideoQueueTask(inputUrl: url))
                    self.shouldStartQueue()
                }
            }
            return true
        }
    }
    
    func shouldStartQueue() {
        if self.outputPath.isEmpty {
            self.pathAlert.toggle()
            return
        }
        if let first = self.queueObjects.first {
            guard case .waiting = first.state else {
                return
            }
            first.start(outputPath: outputPath, hevc: usingH265, progress: nil) { res in
                var errored = false
                if case .failure = res {
                    errored = true
                }
                self.historyObjects.append(first)
                self.queueObjects.removeAll { tas in
                    tas == first
                }
                DispatchQueue.main.asyncAfter(deadline: .now() + (errored ? 0.5 : 0)) {
                    self.shouldStartQueue()
                }
            }
        }
    }
}

struct VideoQueueCell: View {
    @ObservedObject var task: VideoQueueTask
    var body: some View {
        ZStack(alignment: .bottom) {
            HStack(spacing: 10) {
                Text(task.fileName)
                    .lineLimit(2)
                Spacer(minLength: 10)
                
                switch task.state {
                case .processing:
                    Text(String(format: "%.2f%%", task.progress * 100))
                        .frame(width: 64, alignment: .trailing)
                    ProgressView(value: task.progress, total: 1)
                        .frame(width: 100)
                    self.cancelButton
                case .waiting:
                    Image(systemName: "clock")
                        .foregroundColor(.gray)
                case .failed(let err):
                    Text(err?.localizedDescription ?? "")
                        .foregroundColor(.red)
                    Image(systemName: "xmark.circle.fill")
                        .foregroundColor(.red)
                case .finished:
                    Image(systemName: "checkmark.circle.fill")
                        .foregroundColor(.green)
                case .cancelled:
                    Image(systemName: "xmark")
                        .foregroundColor(.yellow)
                }
            }
            .padding(.horizontal, 10)
            .padding(.vertical, 4)
            Color(NSColor(white: 0.9, alpha: 1)).frame(height: 0.5)
        }
    }
    
    var cancelButton: some View {
        Button {
            task.cancel()
        } label: {
            Image(systemName: "stop.circle.fill")
                .foregroundColor(.red)
        }
        .buttonStyle(PlainButtonStyle())
    }
}

struct VideoExporterView_Previews: PreviewProvider {
    static var previews: some View {
        VideoExporterView().frame(width: 320, height: 320)
    }
}
