# 📦 ``SwincyBox``


A Swift DI (Dependency Injection) Framework  for iOS.

Also known as an IOC Container.

## Overview

A framework to store dependency-creation logic in one centralised area quickly resolving dependencies, utilising dependency injection and writing cleaner code.

We create a ``Box``, register factory methods to create ``Classes`` or ``Structs`` (actually any type really) and call ``box.resolve()`` to access or create registered values called ``Services``.

#### Supported Types
``SwincyBox`` resolves Swift reference and value types of type ``Any``.

#### Example
We will use alot of ``Car`` examples in this document as well as our sample project too.
1. First, create a ``Box`` to contain our ``Services``
2. Register a factory method (closure) to return the desired ``Type``
3. Call ``box.resolve() as Type`` to retrieve desired ``Type``
```
// 1.
let box = Box()
// 2.
box.register() { Car() }
// 3.
let car = box.resolve() as Car
```
We can also use ``keys`` to retrieve specific types registered with the same ``Type``.
```
// 2. register
box.register(key: "BMW") { Car() }
box.register(key: "Mercedes") { Car() }

// 3. resolve (i.e. retrieve)
let bmw = box.resolve(key: "BMW") as Car
let mercedes = box.resolve(key: "Mercedes") as Car
```
## Topics
### Dependency Injection

A typical example of dependency injection is when ``Class A`` also requires the usage of ``Class B``. To prevent ``Class A`` from creating ``Class B`` we can invert the control flow by simply passing in this already-instantiated type into the constructor of ``Class A``. Look at the following example:

```
class B {}

class A {
    let b: B
    init () {
        self.b = B()
    }
}
```
``Class A`` is creating an instance of ``Class B`` inside its constructor. This is considered bad practice as it tightly couples ``Class A`` to ``Class B``. Such tight coupling means that we cannot mock a test object and assign it to stored property ``B``.

Now let's consider refactoring with dependency injection.
```
class A {
    let b: B
    init (b: B) {
        self.b = b
    }
}

let b = B()
let a = A(b: b)
```
``Class A`` is also very easy to test as we can simply pass in the dependency of ``Class B``. In fact, we could easily create a mocked ``Class B`` and control its behaviour specifically for our tests.

This is a widely accepted solution to handle dependencies and our ``SwincyBox framework`` compliments this design very well.
```
let box = Box()
box.register() { A(b: B()) }
let instanceOfClassA = box.resolve() as A
```

For more information watch this **Google Tech Talk** [https://www.youtube.com/watch?v=acjvKJiOvXw&t=13s](url)
### SwincyBox - Basic Usage

Let's consider using the ``SwincyBox framework`` to create ``Car`` objects.
Firect, We register a closure that understands how to create such ``Car`` objects.
```
class Car { }
```
```
let box = Box()
box.register() { Car() }
```
After registration, we simply ask our ``Box`` 📦 to create ``Car`` objects for us.
```
let car = box.resolve() as Car
```
It's that simple!
### Shared Box Singleton

We don't include ``singletons`` inside the ``Swincy framework`` as it's not the responsibility of the framework. If we did, it might make life more difficult for client apps that use multiple ``Boxes``.

Instead, we include a helpful ``SharedBox.swift`` file for client apps to add to their Xcode project. Then it's also editable too.
```
// A basic and very simple shared box!
struct App {
    static let box = Box()
}
```
To access simply write:
```
let box = App.box   // Wow. That was easy!
```
### A More Detailed Example
#### A Virtual Car Showroom 🚗

Let's build a virtual ``Showroom`` of ``Cars``. The ``Car`` manufacturer will be **BMW** and each ``Car`` will contain 1 **Volkswagen (VW)** ``Engine``. We'll keep our ``Showroom`` simple and only stock 2 ``Vehicles``, a ``sportsCar`` and a more-reliable ``familyCar``.

As engineers, we'll build a general ``Showroom class`` storing 2 ``Car`` properties. 1 ``Car`` will be selected and displayed inside the shop window.
```
protocol Vehicle { } 	
class Car: Vehicle { }

class BMWX3: Car { }
class BMWRoadster: Car { }

box.register(key: "familyCar") { BMWX3() as Car } // notice the downcast
box.register(key: "sportsCar") { BMWRoadster() as Car }
        
let familyCar = box.resolve(key: "familyCar") as Car
let sportsCar = box.resolve(key: "sportsCar") as Car
```
Our ``Box`` 📦 can now provide ``Car`` objects. What's amazing though is that we registered a ``BMWX3`` ``Car`` (with a key) to be used for the ``Car`` type. This allows us to create a ``Showroom`` of ``Car`` types that can simply be passed in (as parameters) without any knowledge of the ``subclass`` type.
```
class Showroom {
    
    let familyCar: Car
    let sportsCar: Car
    
    init (_ familyCar: Car, _ sportsCar: Car) {
        self.familyCar = familyCar
        self.sportsCar = sportsCar
    }
}
```

```
let showroom = Showroom(box.resolve(key: "familyCar"), box.resolve(key: "sportsCar"))
```
Our ``Showroom`` utilises DI (Dependency Injection), it's not ``tightly coupled`` to the manufacturer and thus provides control over testing as we control each internally-used dependency.


Also, in the future, we can ``register`` different ``Car`` objects, such as if the manufacturer changes or we rotate the stock for later models.
```
box.register(key: "sportsCar") { MercedesAMG() as Car } // Now it's Mercedes!
```
If the manufacturer changes our code remains the same! 👏

### Sample Project
The ``Showroom`` example is also used within our sample project. The ``SwincyBoxDemo.xcodeproj`` is a ``UIKit`` project and has not been created as a showcase of coding skill, good architecture or  beautiful UI. It is simply a quick prototype and demonstration of the ``SwincyBox framework`` in action. 

### SwincyBox In Action

Below are a few scenarios and examples of how we may use ``SwincyBox``. 

#### Creating Your Box 📦
First, we'll need to create our ``Box`` (also known as an ``IOC Container``) which stores the collection of ``Services``. Each ``Service`` is either stored as a created ``instance`` or a factory method which can be called multiple times to create a new ``instance``. We simply use the ``LifeTime`` enum for this purpose. ``.transient`` is the default value and creates a new instance on demand. ``.permanent`` creates an ``instance`` immediately and simply stores it inside the ``Box``.
```
let box = Box()
```
We may want to store our box within a shared location such as the ``AppDelegate class`` or even create a simple ``Singleton struct`` for easily access. Such as the following example:
```
struct App {
    static let box = Box()
}

// then to access
let sharedBox = App.box
```

#### 1. A Basic Factory
The code below sets a ``.transient`` factory method inside ``SwincyBox`` creating a new ``instance`` of ``Car`` each time it's called.

```
box.register() { Car() }
let car = box.resolve() as Car
```
#### 2. Dependency Resolution Factory
In this example, ``Car`` has a dependency on ``Engine``. The factory method creates a new instance of ``Car`` using constructor dependency injection to insert a new instance of ``Engine``.
```
class Engine { }

class Car {
    
    let engine: Engine
    
    init(engine: Engine) {        
        self.engine = engine
    }
}
```
```
box.register() { Car(engine: Engine()) }
let car = box.resolve() as Car
```
#### 3. Dependency Resolution With Protocols
In this example, we'll register ``concrete types`` against a ``protocol``.
Each time we resolve the ``Vehicle`` ``protocol`` we'll recieve a ``Car`` object from ``SwincyBox``. However, in our code we now have the flexibility of refering to the ``Vehicle`` ``protocol`` without any understanding of the s``concrete types`` used.

This layer of abstraction can be very useful in solid application architecture. 
```
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
```
box.register() { Car(engine: Engine()) as Vehicle }
let vehicle = box.resolve() as Vehicle
```
#### 4. Resolving Dependencies
Using the same ``class`` and ``protocol`` declarations from the previous example we can resolve the ``Transmission`` dependency on our ``Car class`` simply can by utilising ``Swift Generics`` and ``Type Inference``.

We access the ``resolver`` parameter passed into the factory method and simply ask it to resolve the inferred type.
```
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
```
box.register() { Engine()) as Transmission }
box.register() { r in Car(engine: r.resolve()) as Vehicle }
let vehicle = box.resolve() as Vehicle
```
#### 5. Using Keys
Providing ``keys`` is a great way to ``register`` and ``resolve`` individual instances of a ``Type``.
```
box.register() { Engine()) as Transmission }
box.register(key: "sportsCar") { r in Car(engine: r.resolve()) as Car }
box.register(key: "familyCar") { r in Car(engine: r.resolve()) as Car }

let sportsCar = box.resolve(key: "sportsCar") as Car
let familyCar = box.resolve(key: "familyCar") as Car
```
### Circular Dependencies
#### ⚠️ WARNING - Avoid Circular Dependencies In Your Architecture
Circular dependencies can cause retain cycles and are usually caused by poor architectural descisions. 😬

Let's consider a scenario where two ``classes`` reference each other. In the example below we have a ``CrashTestDummy class`` which requires a property reference to an associated ``SafetyTestCar``. Also though, each instance of SafetyTestCar will require a reference to a ``CrashTestDummy``.

How would ``SwincyBox`` handle this scenario?

```
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
First, let's decide to use a ``.permanent`` ``LifeType`` inside our ``Box``. This will immediately create an ``instance`` of each ``Class`` upon registration. Speaking in terms of memory management (Apples ARC system), we know the ``retain count`` of each object will be at least ``1``.

But we immediately run into a problem. 

```
box.register(CrashTestDummy.self, life: .permanent) { r in
    let crashTestDummy = CrashTestDummy(car: SafetyTestCar(driver: ??? ))

...
```
How do we inject our ``instance`` of ``CrashTestDummy`` into ``SafetyTestCar`` when we can never complete the ``instantiation`` process?

🤔💭

Circular dependencies have this problem (amongst many). The solution is of course that we must first complete the instantiation of ``CrashTestDummy`` and then connect any references to it afterwards.

We can use a ``mutable property`` to accomplish this like so:
```
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


Wont This Create A ``Retain Cycle``? 

Yes, both ``classes`` use a ``strong reference`` to each other which creates a ``retain cycle``. This is when both objects increase the ``retain count`` of the other object but never decrement it. As the ``retain count`` never decrements down to ``0``, both objects wont ever be released from memory. This is known as a ``memory leak``. 🚱💦

``Weak`` references can solve this problem as they don't increase the ``retain count``. But be careful! Increasing the ``retain count`` keeps objects in memory! If we didn't use a ``LifeType`` of ``.permanent`` in our ``Box`` then the object without the increment in ``retain count`` would simply be ``deallocated`` from memory and our property would be immediately set to ``nil``!

😭 

Our solution now becomes:
```
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
```
box.register(life: .permanent) { SafetyTestCar() }

box.register(CrashTestDummy.self, life: .permanent) { r in
    let car = r.resolve() as SafetyTestCar
    let dummy = CrashTestDummy(car: car)
    car.dummy = dummy

    return dummy
}
```
### Transient Circular Dependencies
In the previous section we explained ``.permanent`` circular dependencies with a supported solution. However, if we adopt the same approach with ``.transient`` ``LifeType`` ``services`` the ``weak`` reference quickly is set to ``nil`` by the ARC memory management system.  Why is that?

Let's consider the following registration code for our ``Box`` using a ``.transient``  ``LifeType``. The concept is essentially the same as the ``.permanent`` registration except each ``instance`` can't be connected outside the ``factory closure`` which creates new ``instances`` per call to ``resolve``. Therefore we must register the same logic for each ``Type``.

```
box.register(CrashTestDummy.self, life: . transient) {
    let car = SafetyTestCar()
    let dummy = CrashTestDummy(car: car)
    car.dummy = dummy

    return dummy
}
```
```
box.register(SafetyTestCar.self, life: .transient) {
    let car = SafetyTestCar()
    let dummy = CrashTestDummy(car: car)
    car.dummy = dummy

    return car
}
```
Resolving ``CrashTestDummy`` returns a complete circular reference.
```
let dummy = box.resolve() as CrashTestDummy
let circularRef = dummy.car.dummy // ✅
```
Resolving ``SafetyTestCar`` results in a ``nil`` value for the ``dummy`` property.
```
let car = box.resolve() as SafetyTestCar
let circularRef = car.dummy?.car // ❌ is nil
```

If we ``resolve`` ``CrashTestDummy`` no ``strong`` reference is held to the instance of ``SafetyTestCar``. The ``Box`` doesn't increment the ``retain count`` and neither does the ``weak`` reference stored within ``SafetyTestCar``. There is in fact, not even one ``strong`` reference to ``CrashTestDummy`` and the created instance is ``deallocated`` immediately after being returned from the ``resolve`` function.

Essentially the solution here (if any) is to understand our architecture and make good architectural descisions!
### Storyboard ViewController Properties

``Storyboards`` can create ``UIViewControllers`` automatically which can make dependency injection somewhat difficult. 

@propertyWrapper can help! ``SwincyBox`` provides a helper file ``AutoBoxed.swift`` located inside our sample project to easily create property wrappers for automatic dependency injection for stored properties.
```
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
These helper files add more flexibility to ``SwincyBox`` as well as your Xcode project while keeping us (the developers) in control! If we decide to access a shared ``singleton`` and prefer writing simple wrapped properties compared to injecting dependencies through a constructor then this could be a good solution.

Below is an example of a basic implementation using an ``AutoBoxed`` property wrapper inside a ``UIViewController`` named ``ShowroomViewController``.
```
class ShowroomViewController: UIViewController {

    @AutoBoxed var showroom: Showroom

...
```




### Thank You 😃

Thank you to everyone who was a part of this project. This test. And of course, this opportunity.
``SwincyBox`` was a pleasure to create and very enjoyable too.
A great idea by those who suggested it.
# 📦 ``SwincyBox``
### 📚 The Files
⬇ Download the **MattHardingIOCFramework.zip** file.

It contains 3 folders:
```
📘 Development
📙 Framework
📔 SampleProject
```

### 📘 Development
This folder contains a ``IOCFramework.xcworkspace`` file containing both the ``SwincyBox Framework`` and a ``sample app`` dynamically connected to view immediate changes to the framework.
Please open the ``workspace file`` by itself and not the individual project files to view and edit the code. 
### 📙 Framework
This folder contains a ``SwincyBox.xcframework`` file for distribution. It can easily be added to any project simply by dragging and dropping it to the ``Xcode`` project navigator pane.
After adding it to your project, simply import ``SwincyBox`` to the top of any file to start using it. Like so...
```
import UIKit
import SwincyBox // 👈 this imports SwincyBox
```

### 📔 Sample Project
This folder includes a sample project showcasing the easy use of ``SwincyBox``. Simply open the ``SwincyBoxDemo.xcodeproj`` file in ``Xcode`` and run it on the ``Simulator``. 

It may be interesting to look at the ``SwincyBox Helpers`` folder at the top of the project navigator pane. You will find a ``config`` file which can (if you like) be used to register dependencies alongside a property wrapper file to aid automatic dependency injection of ``UIViewController`` stored properties.

### Project Author
**Matthew Harding**

All comments, code suggestions and enhancements are welcome. 





