//
//  VideoExporterSwiftUIAppApp.swift
//  VideoExporterSwiftUIApp
//
//  Created by zjj on 2021/8/19.
//  Copyright © 2021 zjj. All rights reserved.
//

import SwiftUI

@main
struct VideoExporterSwiftUIAppApp: App {
    var body: some Scene {
        WindowGroup("Hello") {
            VideoExporterView()
                .frame(minWidth: 480, idealWidth: 480, maxWidth: nil, minHeight: 360, idealHeight: 480, maxHeight: nil, alignment: .center)
        }
//        .commands {
//            ToolbarCommands()
//        }
//        .windowStyle(HiddenTitleBarWindowStyle())
    }
}

//@main
//class AppDelegate: NSObject, NSApplicationDelegate {
//
//    var window: NSWindow!
//
//
//    func applicationDidFinishLaunching(_ aNotification: Notification) {
//        // Create the SwiftUI view that provides the window contents.
//
//        let contentView = VideoExporterView()
////            .frame(width: 480, height: 480)
//            .navigationTitle("Hello")
//
//        // Create the window and set the content view.
//        window = NSWindow(
//            contentRect: NSRect(x: 0, y: 0, width: 480, height: 300),
//            styleMask: [.titled, .closable, .miniaturizable, .resizable, .fullSizeContentView],
//            backing: .buffered, defer: false)
//        window.isReleasedWhenClosed = false
//        window.center()
//        window.setFrameAutosaveName("Main Window")
//        window.contentView = NSHostingView(rootView: contentView)
//        window.makeKeyAndOrderFront(nil)
//    }
//
//    func applicationWillTerminate(_ aNotification: Notification) {
//        // Insert code here to tear down your application
//    }
//
//
//}
