import SwiftTestReporter
import XCTest

/// This test class must be executed first. The `AAA_` prefix helps ensure this,
/// but it is not guaranteed. Make sure that this is alphabetically the first test
/// class in the `tbDEXTestVectors` target!
///
/// This is necessary to allow `SwiftTestReporterInit` to create a `tests.xml`.
/// See https://github.com/allegro/swift-junit/issues/12#issuecomment-725264315
class AAA_JUnitReportInitializer: XCTestCase {
    override class func setUp() {
        _ = TestObserver()
        super.setUp()
    }

    // No-op test function to be interpreted as a test case
    func testInit() {}
}
