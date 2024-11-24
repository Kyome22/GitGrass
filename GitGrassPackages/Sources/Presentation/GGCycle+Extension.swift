/*
 GGCycle+Extension.swift
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

extension GGCycle: Localizable {
    var label: String {
        switch self {
        case .minutes5:
            String(localized: "minutes5", bundle: .module)
        case .minutes10:
            String(localized: "minutes10", bundle: .module)
        case .minutes15:
            String(localized: "minutes15", bundle: .module)
        case .minutes30:
            String(localized: "minutes30", bundle: .module)
        case .hour1:
            String(localized: "hour1", bundle: .module)
        }
    }
}
