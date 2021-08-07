# How to Put Generic Protocol as Variable Type

Have you ever put a Protocol on a variable? I believe you do. The Delegate pattern is using a lot in UIKit, and we are get use to it. For example, you can put a  `UITableViewDelegate` in a variable like `var delegate: UITableViewDelegate?`. Simple right?

However when it come to Generic protocol a.k.a. protocol with `associatedtype`, put it in a variable become nearly impossible. For example, `var publish: Publisher<Int, Never>` is an invalid Swift code.

> Protocol 'Publisher' can only be used as a generic constraint because it has Self or associated type requirements

Usually we put that under `AnyPublisher<Int, Never>`, which is :

> A publisher that performs type erasure by wrapping another publisher.
>> [AnyPublisher - Apple Developer Documentation](https://developer.apple.com/documentation/combine/anypublisher)

Wait, wait, wait, but HOW to do that? Do we need magic to achieve that? the short answer is we need `AbstractClass`, `Dependency injection`

---

## Before start, here is a protocol: Generic

To narrow down this is a Swift topic, not an Apple framework topic, we can start with a hand-make protocol, I call it `Generic`. 

`Generic` has 
1. An associated type without constraint,
2. A function that is return the associated type.

```swift
// Swift

public protocol Generic {
    associatedtype AnyType
    func getter() -> AnyType
}
```

## First attempt: By Dependency Injection

So I first came up with a idea, if we can put that Generic protocol into a wrapper type, that is a concrete type should be able to put on variable.

```swift
// Swift
class AnyGeneric:Generic {
    var wrappedGeneric: Generic 
    
    func getter() -> AnyType {
        return wrappedGeneric.getter()
    }
}
```

This should work. Really? ***No!*** the `wrappedGeneric` still show as the same error, since we just move code around. But I like it, it tell us that on the Clint side, we don't need to worry about the error, and the Class name is easy to switch (only add prefix `Any...`).

## Second Attempt: Generic by `<T>` syntax

By the documentation on Swift.org, we can specify the Generic either on the class / struct / enum / actor or on a function. So maybe we change the `AnyGeneric` with a `<GenericType>`:

```swift
// Swift
class AnyGeneric<GenericType>:Generic where GenericType: Generic {

    typealias AnyType = GenericType.AnyType

    var wrappedGeneric: GenericType

    
    func getter() -> AnyType {
        return wrappedGeneric.getter()
    }
}
```
And we are done. ***NOPE***, I am sorry. The question is on the client side. Can you tell me how the client side put these code? 

```swift
// Swift

/** client side */

struct AGeneric<T>: Generic {
    var t:T
    func getter() -> T { t }
}

let sut: AGeneric<Int> = AGeneric(42)
let anyGeneric: AnyGeneric<AGeneric> = AnyGeneric(sut)  
```
`Senior Developer`: AnyPublisher<Success,Failure> required the `associatedtype`, not the who its wrapping. nice try. 
> `Pull request rejected`

## Third Attempt: Depend on  A type, but Store its Subclass

Last attempt is creative, but not enough. I took me a few days to think about how it can be. I felt like I was limited by the knowledge I have. The more I knew, the less I can do. Therefore I tried gather information on the clues.

1. A generic container syntax can be shared within the class
2. A subclass can be generic container,even if its super is not.
3. A generic container subclass can fix in super class variable, even if super class is not a generic container.

So I draw this URL digram. And start working on it.
```
                ┌────────────────────────┐           
                │  <Generic / AnyType>   │           
                └────────────────────────┘           
                             ▲                       
                             │                       
           ┌─────────────────┴───────────────┐       
           │                                 │       
           │                                 │       
┌────────────────────┐                ┌─────────────┐
│                    │                │             │
│   ABSGenericBox    │◁───────────────│ AnyGeneric  │
│                    │                │             │
└────────────────────┘                └─────────────┘
           ▲                                         
           │                                         
           │                                         
┌────────────────────┐                               
│                    │                               
│GenericBox<Generic> │                               
│                    │                               
└────────────────────┘                               
```

```swift
// swift

class AbstractClass<AnyType>: Generic {
    func getter() -> AnyType {
        abstractFunction()
    }
}


class AnyGenericContainer<GenericType: Generic>: AbstractClass<GenericType.AnyType> {
    private let wrappedValue: GenericType

    init(_ wrappedValue: GenericType) {
        self.wrappedValue = wrappedValue
    }

    override func getter() -> AnyType {
        wrappedValue.getter()
    }
}
```
Then I replace `AnyGeneric`'s wrappedGeneric to `AbstractClass`

```swift
var wrappedGeneric: AbstractClass<AnyType>
```

But that is not all, in `init`, we need to using another generic syntax on function.

```swift
init<G:Generic>(wrappedGeneric: G) where G.AnyType == AnyType {
    self.wrappedGeneric = AnyGenericContainer(wrappedGeneric)
}
```

With extension to make it fluent.

```swift
// Swift
extension Generic {
    func eraseToAnyGeneric() -> AnyGeneric<AnyType> {
        AnyGeneric<AnyType>(self)
    }
}
```

So my `AnyGeneric` becoming look like this. A class with two `<T>`, one on class annotation, one on init function.

```swift
// Swift
class AnyGeneric<AnyType>:Generic {
    
    private var wrappedGeneric: AbstractClass<AnyType>
    
    init<G:Generic>(wrappedGeneric: G) where G.AnyType == AnyType {
        self.wrappedGeneric = AnyGenericContainer(wrappedGeneric)
    }
    
    func getter() -> AnyType {
        return wrappedGeneric.getter()
    }
}
extension Generic {
   func eraseToAnyGeneric() -> AnyGeneric<AnyType> {
       AnyGeneric<AnyType>(self)
   }
}
```

So I make another Pull request. Surprisingly, I have a change request, he never do that to me, I must did something...

```text
LGTM, but I think that you can change that into struct, it make more sense.
    ```different
    struct AnyGeneric<AnyType>: Generic {
    ```
```

## final  Attempt: change into struct, what's different?

So I start to investigate what is the "sense" in his mind. 
What if the client using many many, many eraseToAnyGeneric, like:

```swift
// Swift

struct AGeneric<T>: Generic {
    var t:T
    func getter() -> T { t }
}
let sut: AnyGeneric<Int> = AGeneric(t: 1)
                            .eraseToAnyGeneric()
                            .eraseToAnyGeneric()
                            ...
                            .eraseToAnyGeneric()
                            .eraseToAnyGeneric()
```

> I know it's crazy, but hey, clients are like a baby we need to take care!

The memory will keep alloc the AnyGeneric again and again, make it struct will to alloc th.... no it still cost memory for those struct! I start to realize that it is a Swift language grammar issue. 

1. In any class init function, a new object must be created.
2. In any struct init function, self can be a copy of another one

Therefore I made a change request to that change request:

```swift
// Swift
struct AnyGeneric<AnyType>:Generic {
    
    private var wrappedGeneric: AbstractClass<AnyType>
    
    init<G:Generic>(wrappedGeneric: G) where G.AnyType == AnyType {
      if let erased = wrappedGeneric as? AnyGeneric<AnyType> {
            self = erased
        } else {
            box = AnyGenericContainer(wrappedGeneric)
        }
    }
    
    func getter() -> AnyType {
        return wrappedGeneric.getter()
    }
}
extension Generic {
   func eraseToAnyGeneric() -> AnyGeneric<AnyType> {
       AnyGeneric<AnyType>(self)
   }
}
```

## This is a work of fiction.

To be honest, I did not came out this idea by my self, I have study a lot of open source code and have I personal opinion on it. Wish you enjoy reading this, and feel free to share, comment. 


> BTW, there is `AnyEquatable` is the source code, go digging, go, go, go.
