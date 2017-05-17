//
//  Bool+Extensions.swift
//  PuzzleMaker
//
//  Created by Paweł Kania on 09/08/16.
//
//

import Foundation

extension Bool {

    // MARK: Properties

    /// Returns random value, true or false
    public static var random: Bool {
        return Double.randomInRange(0, 1) > 0.5
    }
}
