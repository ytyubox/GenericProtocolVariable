//
/*
 *		Created by 游宗諭 in 2021/8/4
 *
 *		Using Swift 5.0
 *
 *		Running on macOS 12.0
 */

import GenericProtocolVariable
import XCTest


// MARK: - Tests

final class Tests: XCTestCase {
    func test() {
        let i: AnyEquatable = 1.toAnyEquatable()
        let j: AnyEquatable = "2".toAnyEquatable()
        XCTAssertNotEqual(i, j)
    }
}
