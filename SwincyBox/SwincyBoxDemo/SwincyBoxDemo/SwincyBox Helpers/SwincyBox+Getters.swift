//
//  SwincyBox+Getters.swift
//  SwincyBoxDemo
//
//  Created by Matthew Paul Harding on 24/06/2022.
//

import Foundation
import SwincyBox

// MARK: - Child Boxes
extension Box {
    var bmwBox: Box? {
        get {
            return childBox(forKey: Keys.Box.bmwBox)
        }
    }
    
    var mercedesBox: Box? {
        get {
            return childBox(forKey: Keys.Box.mercedesBox)
        }
    }
}
