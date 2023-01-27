/*
  GGStyle.swift
  GitGrass

  Created by Takuto Nakamura on 2023/01/25.
  Copyright 2023 Takuto Nakamura

  Licensed under the Apache License, Version 2.0 (the "License");
  you may not use this file except in compliance with the License.
  You may obtain a copy of the License at

      http://www.apache.org/licenses/LICENSE-2.0

  Unless required by applicable law or agreed to in writing, software
  distributed under the License is distributed on an "AS IS" BASIS,
  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
  See the License for the specific language governing permissions and
  limitations under the License.
*/

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
