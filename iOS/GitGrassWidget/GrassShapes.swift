//
//  GrassShapes.swift
//  GitGrassWidgetExtension
//
//  Created by Takuto Nakamura on 2020/10/04.
//  Copyright 2020 Takuto Nakamura
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

struct BlockShape: Shape {

    func path(in rect: CGRect) -> Path {
        return Path(rect)
    }

}

struct DotShape: Shape {

    func path(in rect: CGRect) -> Path {
        return Path(ellipseIn: rect)
    }

}

struct GrassShape: Shape {

    func path(in rect: CGRect) -> Path {
        let ratio = rect.height / 5.0
        var path = Path()
        path.move(to: CGPoint(x: rect.minX + ratio, y: rect.maxY))
        path.addCurve(to: CGPoint(x: rect.minX, y: rect.minY + 2.0 * ratio),
                      control1: CGPoint(x: rect.minX + ratio, y: rect.maxY - ratio),
                      control2: CGPoint(x: rect.minX + 1.2 * ratio, y: rect.maxY - 1.8 * ratio))
        path.addCurve(to: CGPoint(x: rect.minX + 1.8 * ratio, y: rect.maxY - 1.2 * ratio),
                      control1: CGPoint(x: rect.minX + 0.9 * ratio, y: rect.minY + 2.3 * ratio),
                      control2: CGPoint(x: rect.minX + 1.4 * ratio, y: rect.maxY - 2.0 * ratio))
        path.addCurve(to: CGPoint(x: rect.minX + 0.8 * ratio, y: rect.minY + ratio),
                      control1: CGPoint(x: rect.minX + 1.7 * ratio, y: rect.midY + 0.2 * ratio),
                      control2: CGPoint(x: rect.minX + 1.5 * ratio, y: rect.minY + 2.1 * ratio))
        path.addCurve(to: CGPoint(x: rect.minX + 2.4 * ratio, y: rect.midY),
                      control1: CGPoint(x: rect.minX + 1.7 * ratio, y: rect.minY + 1.4 * ratio),
                      control2: CGPoint(x: rect.minX + 2.2 * ratio, y: rect.minY + 2.1 * ratio))
        path.addCurve(to: CGPoint(x: rect.maxX - 0.8 * ratio, y: rect.minY),
                      control1: CGPoint(x: rect.maxX - 2.3 * ratio, y: rect.minY + 1.6 * ratio),
                      control2: CGPoint(x: rect.maxX - 1.8 * ratio, y: rect.minY + 0.6 * ratio))
        path.addCurve(to: CGPoint(x: rect.maxX - 1.8 * ratio, y: rect.maxY - 1.2 * ratio),
                      control1: CGPoint(x: rect.maxX - 1.6 * ratio, y: rect.minY + 1.2 * ratio),
                      control2: CGPoint(x: rect.maxX - 1.8 * ratio, y: rect.minY + 2.3 * ratio))
        path.addCurve(to: CGPoint(x: rect.maxX, y: rect.minY + 1.5 * ratio),
                      control1: CGPoint(x: rect.maxX - 1.5 * ratio, y: rect.midY),
                      control2: CGPoint(x: rect.maxX - 0.8 * ratio, y: rect.minY + 1.8 * ratio))
        path.addCurve(to: CGPoint(x: rect.maxX - ratio, y: rect.maxY),
                      control1: CGPoint(x: rect.maxX - 0.9 * ratio, y: rect.midY),
                      control2: CGPoint(x: rect.maxX - ratio, y: rect.maxY - ratio))
        path.closeSubpath()
        return path
    }

}
