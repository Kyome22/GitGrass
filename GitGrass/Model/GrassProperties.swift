//
//  GrassImageProperties.swift
//  GitGrass
//
//  Created by Takuto Nakamura on 2022/10/11.
//  Copyright 2022 Takuto Nakamura
//
//  Licensed under the Apache License, Version 2.0 (the "License");
//  you may not use this file except in compliance with the License.
//  You may obtain a copy of the License at
//
//      http://www.apache.org/licenses/LICENSE-2.0
//
//  Unless required by applicable law or agreed to in writing, software
//  distributed under the License is distributed on an "AS IS" BASIS,
//  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
//  See the License for the specific language governing permissions and
//  limitations under the License.
//

import SwiftUI

enum GGCycle: Int, CaseIterable {
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

enum GGColor: Int, CaseIterable {
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

enum GGStyle: Int, CaseIterable {
    case block = 0
    case dot = 1

    var localizedKey: LocalizedStringKey {
        switch self {
        case .block: return "block"
        case .dot:   return "dot"
        }
    }
}

enum GGPeriod: Int, CaseIterable {
    case lastYear = 0
    case thisWeek = 1

    var localizedKey: LocalizedStringKey {
        switch self {
        case .lastYear: return "thisYear"
        case .thisWeek: return "thisWeek"
        }
    }
}
