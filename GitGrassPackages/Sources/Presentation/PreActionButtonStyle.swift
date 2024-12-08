/*
 PreActionButtonStyle.swift
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

import SwiftUI

struct PreActionButtonStyle: PrimitiveButtonStyle {
    let preAction: () -> Void

    init(preAction: @escaping () -> Void) {
        self.preAction = preAction
    }

    func makeBody(configuration: Configuration) -> some View {
        Button(role: configuration.role) {
            preAction()
            configuration.trigger()
        } label: {
            configuration.label
        }
    }
}

struct PreActionButtonStyleModifier: ViewModifier {
    let preAction: () -> Void

    init(preAction: @escaping () -> Void) {
        self.preAction = preAction
    }

    func body(content: Content) -> some View {
        content.buttonStyle(PreActionButtonStyle(preAction: preAction))
    }
}

extension View {
    func preActionButtonStyle(preAction: @escaping () -> Void) -> some View {
        modifier(PreActionButtonStyleModifier(preAction: preAction))
    }
}
