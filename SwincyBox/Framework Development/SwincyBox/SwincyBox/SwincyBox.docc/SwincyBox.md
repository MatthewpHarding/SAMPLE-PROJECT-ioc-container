# ``SwincyBox`` 

📦 A light-weight Swift dependency injection framework built for iOS. Also known as an IOC Container.

## Overview
 
This small yet powerful iOS framework operates within 201 lines of code applying principles from Swift Generics and light recursion for dependency resolution. A simple ``Box`` is all that is required to first register any dependencies (`Services`), followed by repeated calls to resolve.

This framework supports the Swift type `Any` supporting the registration and resolution of both `Classes` and `Structs`.  

For a basic example let's consider using a new ``Box`` for a car creation factory. First, we'll need to declare a `Car` class and immediatey register a factory method to generate new instances with each call.

```swift
class Car { }
let box = Box()
box.register() { Car() }
```
Now we are ready to create our `Car` objects by simply telling our ``Box`` what `Type` we need to create.
```swift
let car = box.resolve() as Car
```
It's that simple!

## Topics

- <!--@START_MENU_TOKEN@-->``Symbol``<!--@END_MENU_TOKEN@-->
