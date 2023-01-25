//
//  Utils.swift
//  GitGrass
//
//  Created by Takuto Nakamura on 2023/01/25.
//

import Foundation

func logput(
    _ items: Any...,
    file: String = #file,
    line: Int = #line,
    function: String = #function
) {
#if DEBUG
    let fileName = URL(fileURLWithPath: file).lastPathComponent
    var array: [Any] = ["💫Log: \(fileName)", "Line:\(line)", function]
    array.append(contentsOf: items)
    Swift.print(array)
#endif
}

let NOT_IMPLEMENTED = "not implemented"
struct PreviewMock {}
