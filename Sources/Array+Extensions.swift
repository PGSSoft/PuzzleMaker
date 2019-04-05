//
//  Array+Extensions.swift
//  PuzzleMaker iOS
//
//  Created by Pawel Kania on 04/04/2019.
//

import Foundation

// MARK: - Array

extension Array {

    // MARK: Subscripts

    public subscript(safe index: Int) -> Element? {
        return index < count && index >= 0 ? self[index] : nil
    }
}
