# 📦 `SwincyBox`
A Swift dependency injection *(IOC Container)* framework for iOS, supporting the "inversion of control" principle.

## Overview
This small yet powerful iOS framework operates within 201 lines of code applying principles from Swift Generics and light recursion for dependency resolution. A simple ``Box`` is all that is required to first register any dependencies known as ``Services``, followed by repeated calls to resolve.

This framework supports the `Any` type for registration and resolution of both `Classes` and `Structs`.  


## Features

- Transient life cycle	(creating a new instance per call)
- Permanent life cycle (singletons essentially)
- Supports POP (Protocol Oriented Programming)
- Multiple box support
- Storyboard support (using @propertyWrapper)

## Supported Types
- Reference and value types of type `Any`.

## Installation
1. Drag & drop the `SwincyBox.xcframework` file into any Xcode project.
2. Import SwincyBox at the top of each file. For example...

```swift
import UIKit
import SwincyBox // 👈 this imports SwincyBox
```

## Framework File Generation
1. Open the Terminal mac app.
2. Change directory to "Framework Development/SwincyBox".
3. Copy & paste the contents of the "Building Framework File" found within the framework Xcode project into the terminal. Press enter.
4. Locate the newly created `SwincyBox.xcframework` file within the build folder "Framework Development/SwincyBox/build".

## A Basic Example
For a basic example let's consider using a new `Box` for a car creation factory. First, we'll need to declare a `Car` class and immediatey register a factory method to generate new instances with each call.

```swift
class Car { }
let box = Box()
box.register() { Car() }
```

Now we are ready to create our `Car` objects by simply telling our `Box` what `Type` we need to create.

```swift
let car = box.resolve() as Car
```

It's that simple!

## An Example Using Keys

We can also use keys to retrieve specific services registered with the same `Type`.

```swift
box.register(key: "BMW") { Car() }
box.register(key: "Mercedes") { Car() }

let bmw = box.resolve(key: "BMW") as Car
let mercedes = box.resolve(key: "Mercedes") as Car
```

## Dependency Injection Explained

A typical example of dependency injection is when `Class A` also requires the usage of `Class B`. To prevent `Class A` from creating `Class B` we can invert the control flow by simply passing in this already-instantiated type into the constructor of `Class A`. Look at the following example:

```swift
class B {}

class A {
    let b: B
    init () {
        self.b = B()
    }
}
```

`Class A` is creating an instance of `Class B` inside its constructor. This is considered bad practice as it tightly couples `Class A` to `Class B`. Such tight coupling means that we cannot mock a test object and assign it to stored property `B`.

Now let's consider refactoring with dependency injection.

```swift
class A {
    let b: B
    init (b: B) {
        self.b = b
    }
}

let b = B()
let a = A(b: b)
```

`Class A` is also very easy to test as we can simply pass in the dependency of `Class B`. In fact, we could easily create a mocked `Class B` and control its behaviour specifically for our tests.

This is a widely accepted solution to handle dependencies and our SwincyBox framework compliments this design very well.

```swift
let box = Box()
box.register() { A(b: B()) }
let instanceOfClassA = box.resolve() as A
```

For more information watch this **Google Tech Talk** [https://www.youtube.com/watch?v=acjvKJiOvXw&t=13s](url)

## A Detailed Example

Let's build a virtual showroom of cars. The `Car` manufacturer will be **BMW** and each `Car` will contain one **Volkswagen (VW)** `Engine`. We'll keep our `Showroom` simple and only stock two vehicles, a sports car and a more-reliable family car.

As engineers, we'll build a general `Showroom` class storing two `Car` properties. One `Car` will be selected and displayed inside the shop window.

```swift
protocol Vehicle { } 	
class Car: Vehicle { }

class BMWX3: Car { }
class BMWRoadster: Car { }

box.register(key: "familyCar") { BMWX3() as Car } 
box.register(key: "sportsCar") { BMWRoadster() as Car }
        
let familyCar = box.resolve(key: "familyCar") as Car
let sportsCar = box.resolve(key: "sportsCar") as Car
```

Our `Box` 📦 can now provide `Car` objects. What's amazing though is that we registered a `BMWX3` `Car` (with a key) to be used for the `Car` type. This allows us to create a `Showroom` of `Car` types that can simply be passed in (as parameters) without any knowledge of the subclass type.

```swift
class Showroom {
    
    let familyCar: Car
    let sportsCar: Car
    
    init (_ familyCar: Car, _ sportsCar: Car) {
        self.familyCar = familyCar
        self.sportsCar = sportsCar
    }
}
```

```swift
let showroom = Showroom(box.resolve(key: "familyCar"), box.resolve(key: "sportsCar"))
```

Our `Showroom` utilises DI (Dependency Injection), it's not tightly coupled to the manufacturer and thus provides control over testing as we control each internally-used dependency.


Also, in the future, we can register different `Car` objects, such as if the manufacturer changes or we rotate the stock for later models.

```swift
box.register(key: "sportsCar") { MercedesAMG() as Car } // Now it's Mercedes!
```

If the manufacturer changes our code remains the same! 👏

## POP (Protocol Oriented Programming)

In this example, we'll register concrete types against a `protocol`.
Each time we resolve the `Vehicle` protocol we'll recieve a `Car` object from SwincyBox. However, in our code we now have the flexibility of refering to the `Vehicle` protocol without any understanding of the concrete types used.

```swift
protocol Transmission {}
protocol Vehicle {
    var engine: Transmission { get }
}

class Engine: Transmission { }
class Car: Vehicle {
    
    let engine: Transmission
    
    init(engine: Transmission) {        
        self.engine = engine
    }
}
```

```swift
box.register() { Car(engine: Engine()) as Vehicle }
let vehicle = box.resolve() as Vehicle
```

## Circular Dependencies
#### ⚠️ WARNING - Avoid Circular Dependencies In Your Architecture
Circular dependencies can cause retain cycles and are usually caused by poor architectural descisions. 😬

Let's consider a scenario where two classes reference each other. In the example below we have a `CrashTestDummy` class which requires a property reference to an associated `SafetyTestCar`. Also though, each instance of SafetyTestCar will require a reference to a `CrashTestDummy`.

How would SwincyBox handle this scenario?

```swift
class CrashTestDummy {
    var car: SafetyTestCar
    
    init (car: SafetyTestCar) {
        self.car = car
    }
}

class SafetyTestCar {
    var dummy: CrashTestDummy
    
    init(dummy: CrashTestDummy) {
        self. dummy = dummy
    }
}
```

First, let's decide to use a `.permanent` `LifeType` inside our `Box`. This will immediately create an instance of each class upon registration. Speaking in terms of memory management (Apples ARC system), we know the `retain count` of each object will be at least `1`.

But we immediately run into a problem. 

```swift
box.register(CrashTestDummy.self, life: .permanent) { r in
    let crashTestDummy = CrashTestDummy(car: SafetyTestCar(driver: ??? ))

...
```

How do we inject our instance of `CrashTestDummy` into `SafetyTestCar` when we can never complete the instantiation process?

🤔💭

Circular dependencies have this problem (amongst many). The solution is of course that we must first complete the instantiation of `CrashTestDummy` and then connect any references to it afterwards.

We can use a mutable property to accomplish this like so:

```swift
class CrashTestDummy {
    var car: SafetyTestCar
    
    init (car: SafetyTestCar) {
        self.car = car
    }
}

class SafetyTestCar {
    var dummy: CrashTestDummy?
}
```

Wont This Create A Retain Cycle? 

Yes, both classes use a strong reference to each other which creates a retain cycle. This is when both objects increase the retain count of the other object but never decrement it. As the retain count never decrements down to `0`, both objects wont ever be released from memory. This is known as a memory leak. 🚱💦

Weak references can solve this problem as they don't increase the retain count. But be careful! Increasing the retain count keeps objects in memory! If we didn't use a `LifeType` of `.permanent` in our `Box` then the object without the increment in retain count would simply be deallocated from memory and our property would be immediately set to `nil`!

😭 

Our solution now becomes:

```swift
class CrashTestDummy {
    var car: SafetyTestCar
    
    init (car: SafetyTestCar) {
        self.car = car
    }
}

class SafetyTestCar {
    weak var dummy: CrashTestDummy?
}
```

With our registration logic becoming:

```swift
box.register(life: .permanent) { SafetyTestCar() }

box.register(CrashTestDummy.self, life: .permanent) { r in
    let car = r.resolve() as SafetyTestCar
    let dummy = CrashTestDummy(car: car)
    car.dummy = dummy

    return dummy
}
```

## Transient Circular Dependencies
In the previous section we explained `.permanent` circular dependencies with a supported solution. However, if we adopt the same approach with `.transient` `LifeType` services the weak reference quickly is set to `nil` by the ARC memory management system.  Why is that?

Let's consider the following registration code for our `Box` using a `.transient`  `LifeType`. The concept is essentially the same as the `.permanent` registration except each instance can't be connected outside the factory closure which creates new instances per call to resolve. Therefore we must register the same logic for each `Type`.

```swift
box.register(CrashTestDummy.self, life: . transient) {
    let car = SafetyTestCar()
    let dummy = CrashTestDummy(car: car)
    car.dummy = dummy

    return dummy
}
```

```swift
box.register(SafetyTestCar.self, life: .transient) {
    let car = SafetyTestCar()
    let dummy = CrashTestDummy(car: car)
    car.dummy = dummy

    return car
}
```

Resolving `CrashTestDummy` returns a complete circular reference.

```swift
let dummy = box.resolve() as CrashTestDummy
let circularRef = dummy.car.dummy // ✅
```

Resolving `SafetyTestCar` results in a `nil` value for the `dummy` property.

```swift
let car = box.resolve() as SafetyTestCar
let circularRef = car.dummy?.car // ❌ is nil
```

If we resolve `CrashTestDummy` no strong reference is held to the instance of `SafetyTestCar`. The `Box` doesn't increment the retain count and neither does the weak reference stored within `SafetyTestCar`. There is in fact, not even one strong reference to `CrashTestDummy` and the created instance is deallocated immediately after being returned from the `resolve` function.

Essentially the solution here (if any) is to understand our architecture and make good architectural descisions!

## Shared Box Singleton

We don't include singletons inside the SwincyBox framework as it's not the responsibility of the framework. If we did, it might make life more difficult for client apps that use multiple boxes.

If you wanted to access a single instance of your box then consider creating a simple singleton similar to the following example:

```swift
struct App {
    static let box = Box()
}
```

To access simply write:

```swift
let box = App.box   
```

## Supporting Storyboards

Storyboards can create `UIViewControllers` automatically which can make dependency injection somewhat difficult. 

Swift has a feature that can help, property wrappers. Create a new file to your Xcode project and paste in the following code.

```swift
@propertyWrapper
public struct AutoBoxed<T> {
    
    private var service: T?
    
    public init() {}
    
    public var wrappedValue: T {
        mutating get {
            if service == nil {
                service = App.box.resolve(T.self) // Change this to your shared box
            }
            return service!
        }
        set { service = newValue }
    }
    
    public var projectedValue: T {
        return service!
    }
}
```

Then you can simply prefix your properties with `@AutoBoxed`. The service should be automatically resolved using the box supplied within your implementation of `@AutoBoxed`.   

```swift
class ShowroomViewController: UIViewController {

    @AutoBoxed var showroom: Showroom

...
```
-------------------

@ [MatthewpHarding](https://github.com/MatthewpHarding) 🔗

```Swift
let myLife = [learning, coding, happiness] 
```
### 🧕🏻👨🏿‍💼👩🏼‍💼👩🏻‍💻👨🏼‍💼🧛🏻‍♀️👩🏼‍💻💁🏽‍♂️🕵🏻‍♂️🧝🏼‍♀️🦹🏼‍♀🧕🏾🧟‍♂️
