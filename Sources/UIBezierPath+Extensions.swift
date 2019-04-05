//
//  UIBezierPath+Extensions.swift
//  PuzzleMaker
//
//  Created by Paweł Kania on 09/08/16.
//
//

import UIKit

extension UIBezierPath {

    // MARK: Methods

    /**
     Initializes new bezier path with start point and returns function which can be used to add more points to the path

     - attention:
     At the end, path must be closed manually

     - parameter firstPoint: First point of the entire path

     - returns: Function which can be used to add more points to the path
     */
    public static func pathMaker(forFirstPoint firstPoint: CGPoint) -> ([CubicBezierCurve]) -> UIBezierPath {
        let path = UIBezierPath()
        path.move(to: firstPoint)
        return { cubicBeziers in
            cubicBeziers.forEach { cubicBezier in
                path.addCurve(to: cubicBezier.point, controlPoint1: cubicBezier.controlPoint1, controlPoint2: cubicBezier.controlPoint2)
            }
            return path
        }
    }
}
