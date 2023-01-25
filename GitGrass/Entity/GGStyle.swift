//
//  GGStyle.swift
//  GitGrass
//
//  Created by Takuto Nakamura on 2023/01/25.
//

import SwiftUI

enum GGStyle: Int, CaseIterable, LocalizedEnum {
    case block = 0
    case dot = 1

    var localizedKey: LocalizedStringKey {
        switch self {
        case .block: return "block"
        case .dot:   return "dot"
        }
    }
}
