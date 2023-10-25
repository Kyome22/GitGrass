/*
 StatusIconModel.swift
 GitGrass

 Created by Takuto Nakamura on 2023/10/25.
 
*/

import SwiftUI
import Combine

protocol StatusIconModel: ObservableObject {
    var imageInfo: GGImageInfo { get set }

    init(_ userDefaultsRepository: UserDefaultsRepository,
         _ contributionModel: ContributionModel)
}

final class StatusIconModelImpl: StatusIconModel {
    @Published var imageInfo = GGImageInfo(DayData.default, .monochrome, .block, .lastYear)

    private var cancellables = Set<AnyCancellable>()

    init(
        _ userDefaultsRepository: UserDefaultsRepository,
        _ contributionModel: ContributionModel
    ) {
        let properties = GGProperties(userDefaultsRepository.color,
                                      userDefaultsRepository.style,
                                      userDefaultsRepository.period)
        userDefaultsRepository.propertiesPublisher
            .prepend(properties)
            .combineLatest(contributionModel.dayDataPublisher)
            .map { ($1, $0.0, $0.1, $0.2) }
            .receive(on: DispatchQueue.main)
            .sink { [weak self] (dayData, color, style, period) in
                self?.imageInfo = GGImageInfo(dayData, color, style, period)
            }
            .store(in: &cancellables)
    }
}

// MARK: - Preview Mock
extension PreviewMock {
    final class StatusIconModelMock: StatusIconModel {
        @Published var imageInfo = GGImageInfo(DayData.default, .monochrome, .block, .lastYear)

        init(_ userDefaultsRepository: UserDefaultsRepository,
             _ contributionModel: ContributionModel) {}
        init() {}
    }
}
