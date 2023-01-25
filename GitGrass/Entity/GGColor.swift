//
//  GGColor.swift
//  GitGrass
//
//  Created by Takuto Nakamura on 2023/01/25.
//

import SwiftUI

enum GGColor: Int, CaseIterable, LocalizedEnum {
    case monochrome = 0
    case greenGrass = 1
    case accentColor = 2

    var localizedKey: LocalizedStringKey {
        switch self {
        case .monochrome:  return "monochrome"
        case .greenGrass:  return "greenGrass"
        case .accentColor: return "accentColor"
        }
    }
}
