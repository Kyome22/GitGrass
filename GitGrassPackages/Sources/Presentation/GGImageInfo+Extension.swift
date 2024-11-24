/*
 ImageProperties+Extension.swift
 Presentation

 Created by Takuto Nakamura on 2024/11/24.
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

import DataLayer
import SwiftUI

extension ImageProperties {
    var renderingMode: Image.TemplateRenderingMode {
        switch color {
        case .monochrome: .template
        case .greenGrass: .original
        case .accentColor: .original
        }
    }

    func fillColor(level: Int) -> Color {
        let fillColor: Color = switch color {
        case .monochrome: Color.black
        case .greenGrass: Color(.grass)
        case .accentColor: Color(nsColor: NSColor.controlAccentColor)
        }
        return fillColor.opacity(0.2 * Double(level + 1))
    }
}