//
//  LaunchAtLoginRepository.swift
//  GitGrass
//
//  Created by Takuto Nakamura on 2023/01/25.
//

import Foundation
import ServiceManagement

protocol LaunchAtLoginRepository: AnyObject {
    var current: Bool { get }

    func switchRegistration(_ newValue: Bool, failureHandler: @escaping () -> Void)
}

final class LaunchAtLoginRepositoryImpl: LaunchAtLoginRepository {
    var current: Bool {
        if #available(macOS 13, *) {
            return SMAppService.mainApp.status == .enabled
        }
        return false
    }

    func switchRegistration(_ newValue: Bool, failureHandler: @escaping () -> Void) {
        guard #available(macOS 13, *) else { return }
        do {
            if newValue {
                try SMAppService.mainApp.register()
            } else {
                try SMAppService.mainApp.unregister()
            }
        } catch {
            logput(error.localizedDescription)
        }
        if current != newValue {
            failureHandler()
        }
    }
}

// MARK: - Preview Mock
extension PreviewMock {
    final class LaunchAtLoginRepositoryMock: LaunchAtLoginRepository {
        var current: Bool = false
        func switchRegistration(_ newValue: Bool, failureHandler: @escaping () -> Void) {}
    }
}
