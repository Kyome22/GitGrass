/*
 SMAppServiceClient.swift
 DataLayer

 Created by Takuto Nakamura on 2024/11/24.
 Copyright 2022 Takuto Nakamura (Kyome22)

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

import ServiceManagement

public struct SMAppServiceClient: DependencyClient {
    var status: @Sendable () -> SMAppService.Status
    var register: @Sendable () throws -> Void
    var unregister: @Sendable () throws -> Void

    public static let liveValue = Self(
        status: { SMAppService.mainApp.status },
        register: { try SMAppService.mainApp.register() },
        unregister: { try SMAppService.mainApp.unregister() }
    )

    public static let testValue = Self(
        status: { .notFound },
        register: {},
        unregister: {}
    )
}