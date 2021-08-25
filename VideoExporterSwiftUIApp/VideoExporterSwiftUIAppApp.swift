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
    }
}
