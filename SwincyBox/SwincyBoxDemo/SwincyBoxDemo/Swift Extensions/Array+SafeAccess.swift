//
//  Array+SafeAccess.swift
//  SwincyBoxDemo
//
//  Created by Matthew Paul Harding on 23/06/2022.
//

import Foundation

extension Array {
    
    subscript (safe index: Int) -> Element? {
        return self.indices ~= index ? self[index] : nil
    }
}
