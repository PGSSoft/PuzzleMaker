//
//  Double+Extensions.swift
//  PuzzleMaker
//
//  Created by Paweł Kania on 09/08/16.
//
//

import Foundation

extension Double {

    // MARK: Properties

    /// Returns random double number between two values
    public static var randomInRange: (_ lower: Double, _ upper: Double) -> Double = { lower, upper in
        return (Double(arc4random()) / 0xffffffff) * (upper - lower) + lower
    }
}
