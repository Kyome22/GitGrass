/*
 Color+Extensions.swift
 GitGrass

 Created by Takuto Nakamura on 2023/10/25.
 Copyright 2022 Takuto Nakamura

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

extension Color {
    static func fillColor(_ level: Int, _ color: GGColor) -> Color {
        if color == .monochrome {
            return Color.black.opacity(0.2 * Double(level + 1))
        } else if color == .greenGrass {
            return Color(.grass).opacity(0.2 * Double(level + 1))
        } else {
            return Color.accentColor.opacity(0.2 * Double(level + 1))
        }
    }
}
