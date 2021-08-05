//
/*
 *		Created by 游宗諭 in 2021/8/5
 *
 *		Using Swift 5.0
 *
 *		Running on macOS 12.0
 */

// MARK: - ABSClass

class ABSClass: Equatable {
    static func == (lhs: ABSClass, rhs: ABSClass) -> Bool {
        Self.isEqual(lhs: lhs, rhs: rhs)
    }

    class func isEqual(lhs: ABSClass, rhs: ABSClass) -> Bool {
        abstractFunction()
    }

    func isEqual(to other: ABSClass) -> Bool {
        abstractFunction()
    }
}

// MARK: - AnyEquatableBox

final class AnyEquatableBox<EquatableType: Equatable>: ABSClass {
    internal init(abs: EquatableType) {
        self.abs = abs
    }

    var abs: EquatableType

    override class func isEqual(lhs: ABSClass, rhs: ABSClass) -> Bool {
        let l = (lhs as? AnyEquatableBox)?.abs
        let r = (rhs as? AnyEquatableBox)?.abs
        return l == r
    }

    override func isEqual(to other: ABSClass) -> Bool {
        Self.isEqual(lhs: self, rhs: other)
    }
}

// MARK: - AnyEquatable

public struct AnyEquatable: Equatable {
    init<EquatableType>(_ e: EquatableType) where EquatableType: Equatable {
        if let erased = e as? AnyEquatable {
            box = erased.box
        } else {
            box = AnyEquatableBox(abs: e)
        }
    }

    let box: ABSClass
    public static func == (lhs: AnyEquatable, rhs: AnyEquatable) -> Bool {
        Self.isEqual(lhs: lhs, rhs: rhs)
    }

    static func isEqual(lhs: AnyEquatable, rhs: AnyEquatable) -> Bool {
        lhs.box.isEqual(to: rhs.box)
    }
}

public extension Equatable {
    func toAnyEquatable() -> AnyEquatable {
        AnyEquatable(self)
    }
}
