import os
import XCTest

@testable import DataLayer
@testable import Domain

final class ContributionServiceTests: XCTestCase {
    func test_cycleStream_updateCycle() async {
        let expectation = XCTestExpectation()
        let sut = ContributionService(.testValue, .testValue, .testValue)
        let task = Task {
            for await _ in await sut.cycleStream() {
                expectation.fulfill()
            }
        }
        await Task.yield()
        await sut.updateCycle()
        await fulfillment(of: [expectation], timeout: 0.1)
        task.cancel()
    }

    func test_updateImageInfo_nil() async {
        let expectation = XCTestExpectation()
        let imageProperties = OSAllocatedUnfairLock<ImageProperties?>(initialState: nil)
        let userDefaultsClient = testDependency(of: UserDefaultsClient.self) {
            $0.string = { _ in "" }
            $0.integer = { key in key == "cycle" ? 5 : 0 }
        }
        let sut = ContributionService(.testValue, .testValue, userDefaultsClient)
        let task = Task {
            for await value in await sut.imagePropertiesStream() {
                imageProperties.withLock { $0 = value }
                expectation.fulfill()
            }
        }
        await Task.yield()
        await sut.updateImageInfo(with: nil)
        await fulfillment(of: [expectation], timeout: 0.1)
        task.cancel()
        XCTAssertEqual(imageProperties.withLock(\.?.color), GGColor.monochrome)
        XCTAssertEqual(imageProperties.withLock(\.?.style), GGStyle.block)
        XCTAssertEqual(imageProperties.withLock(\.?.period), GGPeriod.lastYear)
    }

    func test_updateImageInfo_not_nil() async {
        let expectation = XCTestExpectation()
        let imageProperties = OSAllocatedUnfairLock<ImageProperties?>(initialState: nil)
        let userDefaultsClient = testDependency(of: UserDefaultsClient.self) {
            $0.string = { _ in "" }
            $0.integer = { key in key == "cycle" ? 5 : 0 }
        }
        let sut = ContributionService(.testValue, .testValue, userDefaultsClient)
        let task = Task {
            for await value in await sut.imagePropertiesStream() {
                imageProperties.withLock { $0 = value }
                expectation.fulfill()
            }
        }
        await Task.yield()
        await sut.updateImageInfo(with: [[DayData(level: 1, count: 2, date: "dummy")]])
        await fulfillment(of: [expectation], timeout: 0.1)
        task.cancel()
        XCTAssertEqual(imageProperties.withLock(\.?.dayData), [[DayData(level: 1, count: 2, date: "dummy")]])
    }

    func test_fetchGrass() async {}
}
