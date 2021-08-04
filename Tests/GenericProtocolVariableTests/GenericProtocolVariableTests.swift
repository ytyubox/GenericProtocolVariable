import GenericProtocolVariable
import XCTest

// MARK: - GenericProtocolVariableTests

final class GenericProtocolVariableTests: XCTestCase {
    func testGrammerFit() {
        let intGeneric: AnyGeneric<Int> = TestingGeneric(1).eraseToAnyGeneric()
        XCTAssertEqual(intGeneric.getter(), 1)
    }
}

// MARK: - TestingGeneric

private struct TestingGeneric: Generic {
    init(_ anyType: AnyType) {
        self.anyType = anyType
    }

    typealias AnyType = Int
    private let anyType: AnyType
    func getter() -> AnyType {
        anyType
    }
}
