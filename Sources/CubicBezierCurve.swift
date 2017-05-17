//
//  CubicBezierCurve.swift
//  PuzzleMaker
//
//  Created by Paweł Kania on 09/08/16.
//
//

import UIKit

/**
 *  Describes single cubic Bézier curve
 */
public struct CubicBezierCurve {

    // MARK: Properties

    /// The end point of the curve
    public let point: CGPoint

    /// The first control point to use when computing the curve
    public let controlPoint1: CGPoint

    /// The second control point to use when computing the curve
    public let controlPoint2: CGPoint
}
