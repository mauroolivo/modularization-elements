import XCTest
@testable import StressCore

final class ArchitectureSmellsTests: XCTestCase {
    func testContainsFiveExercises() {
        XCTAssertEqual(Stage16StressKit.exercises.count, 5)
    }

    func testEachExerciseHasDetectionRule() {
        for exercise in Stage16StressKit.exercises {
            XCTAssertFalse(exercise.detectionRule.isEmpty)
        }
    }
}
