//
//  Container.swift
//  SwincyBox
//
//  Created by Matthew Paul Harding on 15/06/2022.
//

import Foundation

// MARK: - BoxAPI - Public API
extension Box: BoxApi {
    // MARK: - Registered Services Utilities
    /// The number of services registered within this box excluding the services resgitered on any child boxes.
    public var registeredServiceCount: Int { get { services.count } }
    
    /// The number of services registered within each of the child boxes including the count of all sub child boxes and son and so fourth.
    public var childServiceCount: Int {
        get {
            return registeredServiceCount + childBoxes.reduce(0) { partialResult,entry in partialResult + entry.value.childServiceCount }
        }
    }
    
    /// Calling this function will remove all of the services registered with this current box excluding any child boxes.
    public func clear() {
        services.removeAll()
    }
    
    /// Calling this function will remove all of the services registered with this current box including all child boxes too.
    public func clearAll() {
        clear()
        childBoxes.forEach { $0.value.clear() }
    }
    
    // MARK: - Register Dependecy (without a resolver)
    /// Call register to add a closure which creates a specific type known as a service. The factory method that creates it will be stored for use each time resolve() is called. Specifying the LifeType will dictate if the returned instance is kept and stored for the lifetime of the box. A transient LifeType will create a new instance with each call to resolve(). A permanent type will store the first created instance returned with each subsequent call.
    @discardableResult
    public func register<Service>(_ type: Service.Type = Service.self, key: String? = nil, life: LifeType = .transient, _ factory: @escaping (() -> Service)) -> ServiceStoring {
        return registerServiceStore(wrapServiceFactory(forLife: life, factory), type, key)
    }
    
    // MARK: - Register Dependecy (using a resolver)
    /// Call register to add a closure which creates a specific type known as a service. The factory method that creates it will be stored for use each time resolve() is called. Specifying the LifeType will dictate if the returned instance is kept and stored for the lifetime of the box. A transient LifeType will create a new instance with each call to resolve(). A permanent type will store the first created instance returned with each subsequent call. This particular overload of the register function accepts a resolver type as an argument to the factory method which can be used to resolve any dependencies on the type registered.
    @discardableResult
    public func register<Service>(_ type: Service.Type = Service.self, key: String? = nil, life: LifeType = .transient, _ factory: @escaping ((Resolver) -> Service)) -> ServiceStoring {
        return registerServiceStore(wrapServiceFactory(forLife: life, factory), type, key)
    }
    
    // MARK: - Resolve Dependency
    /// Call this function to resolve (generate or retrieve) an instance of a type of a registered service. If the service has not yet been registered a fatalError() will be thrown. All services must be registered before the first call to resolve for the matching type with a matching key (or nil). Call this method once only within the application lifecycle.
    /// - Returns: An instance of the service requested. The type of the instance returned may only be different from the typecast it was registered for, either through inheritance or protocol adherence. However, it must match the type it was registered with otherwise a fatalError() is thrown.
    public func resolve<Service>(_ type: Service.Type = Service.self, key: String? = nil) -> Service {
        let serviceKey = createServiceKey(for: type, key: key)
        do {
            return try resolveCascadingUp(type, serviceKey: serviceKey) as Service
        }
        catch let e as ResolvingError {
            fatalError("SwincyBox: \(e.description)")
        } catch {
            fatalError("SwincyBox: \(error)")
        }
    }
    
    // MARK: - Childbox
    /// Calling this function creates and embeds a new child box, which can then be used as a first responder for all calls to resolve cascading upwards through parent boxes until the dependency is resolved.
    /// - Parameter key: A unique string key identifier to be used when retrieving each specific box.
    /// - Returns: A newly created child box stored and retrieved by passed in key identifier.
    public func newChildBox(forKey key: String) -> Box {
        let box = Box()
        box.parentBox = self
        box.services = services // copies a snapshot of the existing dictionary. instances remain the same
        if let _ = childBoxes[key] {
            logWarning("Already registerd childBox for key '\(key)'")
        }
        childBoxes[key] = box
        return box
    }
    
    /// Calling this function returns an optional Box for the unique key used to create the box.
    /// - Parameter key: A unique string key identifier to be used when retrieving each specific box.
    /// - Returns: A child box associated and stored with the passed in key.
    public func childBox(forKey key: String) -> Box? {
        guard let childBox = childBoxes[key] else {
            logWarning("Child box not found for key '\(key)'")
            return nil
        }
        return childBox
    }
}

// MARK: - Resolver Type Alias
/// Resolver typealias has been used to aid the documentation and readability of the code by using standardised IOC Framework terminology
public typealias Resolver = Box

// MARK: - Box Declaration
/// A box represents what's known as a container, using terminology often used when discussing the Inversion Of Control principle. Each box is used to register and store dependencies, which are known as services and are either stored or created by the box used during registration. A typical usage of SwincyBox would be accessing one box throughout the application lifecycle. However, multiple boxes can be created with an option to even chain them together as children boxes. Please note that when calling the resolve function on a box it becomes a first responder, cascading up through the parent chain until either a dependency is returned or the end of the chain is found and a fatalError() will be thrown.
public final class Box {
    // MARK: - Properties
    /// A store of each registered service, or rather the wrapper type that encapsulates it.
    private var services: [String : ServiceStoring] = [:]
    /// A weak referenced property linking to the box which created it or nil if it wasn't created by a parent. Parent boxes are used to recursively search upwards to resolve a service.
    private weak var parentBox: Box? = nil
    /// An array of all child boxes created by calling the addChildBox() function.
    private var childBoxes: [String: Box] = [:]
    /// An array of each current call made to resolve()
    private var resolveCallLog: [String] = []
    
    // MARK: - Init
    /// The constructor used to instantiate an instance of a box. After the class has been initialised the class will then be ready to register each service creation factory.
    public init () { }
}

// MARK: - Register A Service
extension Box {
    /// Call this function to store the wrapped service within the dictionary of registered services.
    @discardableResult
    private func registerServiceStore<Service>(_ serviceStore: ServiceStoring, _ type: Service.Type, _ key: String?) -> ServiceStoring {
        let serviceKey = createServiceKey(for: type, key: key)
        if let _ = services[serviceKey] {
            logWarning("Already registerd '\(type)' for key '\(String(describing: key))'")
        }
        services[serviceKey] = serviceStore
        return serviceStore
    }
}

// MARK: - Resolve A Service
extension Box {
    /// The root method for resolving a registered service. If the box cannot resolve the service then we recursively search each parent box until the type is resolved or we reach the end of the parent chain, in which case a ResolvingError is thrown.
    /// - Returns: an instance of the registered type associated with both the generically assigned type (using Swift Generics) and the supplied key identifier.
    private func resolveCascadingUp<Service>(_ type: Service.Type = Service.self, serviceKey: String) throws -> Service {
        defer { popCallToResolve() }
        do {
            try logCallToResolve(serviceKey)
            let service = try attempToResolve(type, serviceKey: serviceKey) ?? parentBox?.resolveCascadingUp(type, serviceKey: serviceKey)
            guard let typecastService = service else {
                throw ResolvingError.unregisteredType(key: serviceKey)
            }
            return typecastService
        } catch {
            throw error
        }
    }
    
    /// The first method to be called within the lightly recursive approach of cascading upwards through the chain of parent boxes. Similar to becoming a first responder, each child box is given an opportunity to return the service requested using this method attempToResolve().
    /// - Returns: An optional value representing the registered service. Nil if no such service could be resolved by this box.
    private func attempToResolve<Service>(_ type: Service.Type = Service.self, serviceKey: String) throws -> Service? {
        guard let storage = services[serviceKey] else { return nil }
        guard let typecastService = storage.service(self) as? Service else {
            throw ResolvingError.typeMismatch(key: serviceKey)
        }
        return typecastService
    }
    
    // MARK: - Resolving Dependency Call Log
    /// Call this method each time a request is made to resolve a service. With each function call we will add the service key to a stack of service keys representing the call stack to resolve.
    private func logCallToResolve(_ serviceKey: String) throws {
        if resolveCallLog.contains(serviceKey) {
            throw ResolvingError.infinateRecurrsionDetected(stack: resolveCallLog)
        }
        resolveCallLog.append(serviceKey)
    }
    
    /// Call thsi function when the call to resolve a service exits. It will remove the last entry pushed ontop of the call stack to resolve.
    private func popCallToResolve() {
        resolveCallLog.removeLast()
    }
}

// MARK: - Service Storage
extension Box {
    /// A centralised location used to generate a unique key from both the service type and associated key used for service retrieval. The returned key will then be used to store and retrieve the associated service.
    /// - Returns: A unique key generated from both the service type and associated key used for service retrieval.
    private func createServiceKey<Service>(for type: Service, key: String?) -> String {
        guard let key = key else { return "\(type)" }
        return "\(type) - \(key)"
    }
    
    /// A function to encapsulate a factory method used to generate some instance of a service. This method will return a different type of wrapper for each different life cycle supported by SwincyBox. The passed in factory method accepts a resolver object as an argument, which should be used to resolve any dependencies before returning the service itself.
    /// - Returns: An type adhering to the service storage protocol which can then be asked to return the service it encapsulates.
    private func wrapServiceFactory<Service>(forLife life: LifeType, _ factory: @escaping ((Resolver) -> Service)) -> ServiceStoring {
        switch life {
        case .transient: return TransientStore(factory)
        case .permanent: return PermanentStore(factory)
        }
    }
    
    /// A function to encapsulate a factory method used to generate some instance of a service. This method will return a different type of wrapper for each different life cycle supported by SwincyBox. The passed in factory method accepts no arguments and simply returns an instance of the service.
    /// - Returns: An type adhering to the service storage protocol which can then be asked to return the service it encapsulates.
    private func wrapServiceFactory<Service>(forLife life: LifeType, _ factory: @escaping (() -> Service)) -> ServiceStoring {
        return wrapServiceFactory(forLife: life) { _ in factory() }
    }
}

// MARK: - Logging
/// Logging will only occur during a development build and not within a release build to ensure the performance of client apps is maintained and supported
extension Box {
    /// A wrapper for the Swift print() command adding a SwincyBox title to each message, whilst also ensuring that no logging occurs during a live release build. Messages will only be logged during a DEBUG Xcode build.
    /// - Parameter string: The string printed to the console. Each call to log prints the framework name first followed by the string parameter on a new line.
    private func log(_ string: String) {
        // NOTE: Printing to the console slows down performance of the app and device. We never want to negatively affect the performance of our client apps even for logging warnings
        #if DEBUG
        print("Swincy Framework")
        print(string)
        #endif
    }
    
    /// A method to print the passed in string message to the console log (within a DEBUG build) also prefixing the text, "Warning: ".
    /// - Parameter string: The string printed to the console with the added warning prefix.
    private func logWarning(_ string: String) {
        log("Warning: " + string)
    }
}
