//
//  BoxApi.swift
//  SwincyBox
//
//  Created by Matthew Paul Harding on 07/07/2022.
//

import Foundation

/// The BoxApi exposes the features of the SwincyBox framework. Simply call any of these functions to communicate with your Box
public protocol BoxApi {
    // MARK: - Register Services
    var registeredServiceCount: Int { get }
    func register<Service>(_ type: Service.Type, key: String?, life: LifeType, _ factory: @escaping (() -> Service)) -> ServiceStoring
    func register<Service>(_ type: Service.Type, key: String?, life: LifeType, _ factory: @escaping ((Resolver) -> Service)) -> ServiceStoring
    // MARK: - Resolve Services
    func resolve<Service>(_ type: Service.Type, key: String?) -> Service
    // MARK: - Remove Services
    func clear()
    // MARK: - Child Boxes
    func newChildBox(forKey key: String) -> Box
    func childBox(forKey key: String) -> Box?
}
