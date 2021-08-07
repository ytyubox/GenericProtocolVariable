//
/*
 *		Created by 游宗諭 in 2021/8/4
 *
 *		Using Swift 5.0
 *
 *		Running on macOS 12.0
 */

// MARK: - AbstractClass

private class AbstractClass<AnyType>: Generic {
    func getter() -> AnyType {
        abstractFunction()
    }
}

// MARK: - AnyGenericContainer

private final class AnyGenericContainer<GenericType: Generic>: AbstractClass<GenericType.AnyType> {
    private let wrappedValue: GenericType

    init(_ wrappedValue: GenericType) {
        self.wrappedValue = wrappedValue
    }

    override func getter() -> AnyType {
        wrappedValue.getter()
    }
}

// MARK: - AnyGeneric

public struct AnyGeneric<AnyType>: Generic {
    private let box: AbstractClass<AnyType>

    public init<GenericType: Generic>(_ generic: GenericType) where AnyType == GenericType.AnyType {
        if let erased = generic as? AnyGeneric<AnyType> {
            self = erased
        } else {
            box = AnyGenericContainer(generic)
        }
    }

    public func getter() -> AnyType {
        box.getter()
    }
}

// MARK: - Generic + eraseToAnyGeneric

public extension Generic {
    func eraseToAnyGeneric() -> AnyGeneric<AnyType> {
        AnyGeneric<AnyType>(self)
    }
}
