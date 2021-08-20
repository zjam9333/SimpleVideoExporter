//
//  String+ext.swift
//  VideoExporterSwiftUIApp
//
//  Created by zjj on 2021/8/20.
//  Copyright © 2021 zjj. All rights reserved.
//

import Foundation

extension String {
    var humanReadableFilePath: String {
        var fi = self
        let filePrefix = "file://"
        if fi.hasPrefix(filePrefix) {
            if let range = fi.range(of: filePrefix) {
                fi.removeSubrange(range)
            }
        }
        return fi
    }
}
