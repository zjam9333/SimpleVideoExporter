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
        WindowGroup {
            VideoExporterView().frame(width: 480, height: 480).navigationTitle("Hello")
        }
    }
}
