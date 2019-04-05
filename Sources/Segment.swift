//
//  Segment.swift
//  PuzzleMaker
//
//  Created by Paweł Kania on 09/08/16.
//
//

import UIKit

/**
 *  Describes single edge of the puzzle unit, which is a concatenation of many cubic Bézier curves
 */
public struct Segment {

    // MARK: Properties

    /// Collection of cubic bezier curves that take part in creation of segment (which is a bezier path in fact)
    public var cubicBezierCurves: [CubicBezierCurve]

    /// Joins all cubic bezier curves into one path, which is a representation of segment
    /// - attention:
    /// Path must stay "open", because it will be used later to create complete puzzle unit
    public var path: UIBezierPath {
        return UIBezierPath.pathMaker(forFirstPoint: .zero)(cubicBezierCurves)
    }

    /// If segment is recognized as outer then proper height will be returned
    ///
    /// The height will be needed to calculate real size of the puzzle unit
    ///
    /// In any other cases (inner or flat) value 0 will be returned
    public var outerHeight: CGFloat {
        if path.bounds.origin.y < 0 || path.bounds.size.height == 0 {
            return 0
        }
        return path.bounds.size.height
    }

    // MARK: Methods

    /**
     Loops through all cubic bezier curves and set all y positions to 0
     */
    public mutating func makeFlat() {
        var cubicBezierCurvesTmp = [CubicBezierCurve]()
        cubicBezierCurves.forEach { cubicBezier in
            let point = CGPoint(x: cubicBezier.point.x, y: 0)
            let controlPoint1 = CGPoint(x: cubicBezier.controlPoint1.x, y: 0)
            let controlPoint2 = CGPoint(x: cubicBezier.controlPoint2.x, y: 0)
            cubicBezierCurvesTmp.append(CubicBezierCurve(point: point, controlPoint1: controlPoint1, controlPoint2: controlPoint2))
        }
        cubicBezierCurves = cubicBezierCurvesTmp
    }

    /**
     Loops through all cubic bezier curves and set all y positions to -y (horizontal mirror)
     */
    public mutating func mirror() {
        var cubicBezierCurvesTmp = [CubicBezierCurve]()
        cubicBezierCurves.forEach { cubicBezier in
            let point = CGPoint(x: cubicBezier.point.x, y: -cubicBezier.point.y)
            let controlPoint1 = CGPoint(x: cubicBezier.controlPoint1.x, y: -cubicBezier.controlPoint1.y)
            let controlPoint2 = CGPoint(x: cubicBezier.controlPoint2.x, y: -cubicBezier.controlPoint2.y)
            cubicBezierCurvesTmp.append(CubicBezierCurve(point: point, controlPoint1: controlPoint1, controlPoint2: controlPoint2))
        }
        cubicBezierCurves = cubicBezierCurvesTmp
    }

    /**
     Loops through all cubic bezier curves and apply scale transform

     - parameter sxFactor: The factor by which to scale the x-axis of the coordinate system
     - parameter syFactor: The factor by which to scale the y-axis of the coordinate system
     */
    public mutating func scale(_ sxFactor: CGFloat, syFactor: CGFloat) {
        var cubicBezierCurvesTmp = [CubicBezierCurve]()
        cubicBezierCurves.forEach { cubicBezier in
            let transform = CGAffineTransform(scaleX: sxFactor, y: syFactor)
            let point = CGPoint(x: cubicBezier.point.x, y: cubicBezier.point.y).applying(transform)
            let controlPoint1 = CGPoint(x: cubicBezier.controlPoint1.x, y: cubicBezier.controlPoint1.y).applying(transform)
            let controlPoint2 = CGPoint(x: cubicBezier.controlPoint2.x, y: cubicBezier.controlPoint2.y).applying(transform)
            cubicBezierCurvesTmp.append(CubicBezierCurve(point: point, controlPoint1: controlPoint1, controlPoint2: controlPoint2))
        }
        cubicBezierCurves = cubicBezierCurvesTmp
    }

    /**
     Loops through all cubic bezier curves and apply rotation transform (only y value, x is permanently set to 0)

     - parameter tyValue: The value by which to move y values with the affine transform
     */
    public mutating func rotate(forYValue tyValue: CGFloat) {
        var cubicBezierCurvesTmp = [CubicBezierCurve]()
        cubicBezierCurves.forEach { cubicBezier in
            let transform = CGAffineTransform(rotationAngle: CGFloat(-Double.pi / 2)).translatedBy(x: 0, y: tyValue)
            let point = cubicBezier.point.applying(transform)
            let controlPoint1 = cubicBezier.controlPoint1.applying(transform)
            let controlPoint2 = cubicBezier.controlPoint2.applying(transform)
            cubicBezierCurvesTmp.append(CubicBezierCurve(point: point, controlPoint1: controlPoint1, controlPoint2: controlPoint2))
        }
        cubicBezierCurves = cubicBezierCurvesTmp
    }
}
