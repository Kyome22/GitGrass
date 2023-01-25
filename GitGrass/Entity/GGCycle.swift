//
//  GGCycle.swift
//  GitGrass
//
//  Created by Takuto Nakamura on 2023/01/25.
//

import SwiftUI

enum GGCycle: Int, CaseIterable, LocalizedEnum {
    case minutes5 = 5
    case minutes10 = 10
    case minutes15 = 15
    case minutes30 = 30
    case hour1 = 60

    var localizedKey: LocalizedStringKey {
        switch self {
        case .minutes5:  return "minutes5"
        case .minutes10: return "minutes10"
        case .minutes15: return "minutes15"
        case .minutes30: return "minutes30"
        case .hour1:     return "hour1"
        }
    }
}
