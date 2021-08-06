//
/*
 *		Created by 游宗諭 in 2021/8/5
 *
 *		Using Swift 5.0
 *
 *		Running on macOS 12.0
 */

import GenericProtocolVariable

// MARK: - TableViewCell

class TableViewCell: ReturnSelf {
    var name: String { "a name" }

    class func dequeue() -> ReturnSelf {
        TableViewCell()
    }
}

// MARK: - TestingReturnSelf

class TestingReturnSelf: TableViewCell {
    override var name: String {
        "another name"
    }

    override class func dequeue() -> ReturnSelf {
        TestingReturnSelf()
    }
}

import XCTest

// MARK: - ReturnSelfTests

final class ReturnSelfTests: XCTestCase {
    func test() {
        let list: [ReturnSelf.Type] = [
            TableViewCell.self,
            TestingReturnSelf.self,
        ]

        let names = list
            .map { $0.dequeue() }
            .map(\.name)

        XCTAssertEqual(names, ["a name",
                               "another name"])
    }
}
