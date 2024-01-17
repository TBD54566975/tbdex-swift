import Foundation
import XCTest

extension XCTest {

    /// Asserts that an asynchronous expression throws an error.
    /// (Intended to function as a drop-in asynchronous version of `XCTAssertThrowsError`.)
    ///
    /// Example usage:
    ///
    ///     await XCTAssertThrowsErrorAsync(
    ///         try await sut.function()
    ///     ) { error in
    ///         XCTAssertEqual(error as? MyError, MyError.specificError)
    ///     }
    ///
    /// - Parameters:
    ///   - expression: An asynchronous expression that can throw an error.
    ///   - message: An optional description of a failure.
    ///   - file: The file where the failure occurs.
    ///     The default is the filename of the test case where you call this function.
    ///   - line: The line number where the failure occurs.
    ///     The default is the line number where you call this function.
    ///   - errorHandler: An optional handler for errors that expression throws.
    public func XCTAssertThrowsErrorAsync<T: Sendable>(
        _ expression: @autoclosure () async throws -> T,
        _ message: @autoclosure () -> String = "",
        file: StaticString = #filePath,
        line: UInt = #line,
        _ errorHandler: (_ error: Error) -> Void = { _ in }
    ) async {
        do {
            _ = try await expression()
            XCTFail(message(), file: file, line: line)
        } catch {
            errorHandler(error)
        }
    }
}
