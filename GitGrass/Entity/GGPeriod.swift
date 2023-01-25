//
//  GGPeriod.swift
//  GitGrass
//
//  Created by Takuto Nakamura on 2023/01/25.
//

import SwiftUI

enum GGPeriod: Int, CaseIterable, LocalizedEnum {
    case lastYear = 0
    case thisWeek = 1

    var localizedKey: LocalizedStringKey {
        switch self {
        case .lastYear: return "thisYear"
        case .thisWeek: return "thisWeek"
        }
    }
}
