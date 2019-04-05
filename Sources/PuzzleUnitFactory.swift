//
//  PuzzleUnitFactory.swift
//  PuzzleMaker
//
//  Created by Paweł Kania on 09/08/16.
//
//

import UIKit

/**
 Forces proper action which should be performed for specific edge (segment), in order to generate complete puzzle unit

 - missing: Edge is missing, so factory will select inner or outer edge randomly
 - flat:    Edge should be a straight line
 - mirror:  Edge should be a mirror of a provided segment
 */
public enum PuzzleEdge {
    case missing, flat, mirror(Segment)
}

/**
 *  Factory responsible for generating complete puzzle unit for indicated size and desired edges
 */
public struct PuzzleUnitFactory {

    // MARK: Properties

    /// Segment pattern which is used to generate all edges
    ///
    /// At the later stage, it will be transformed in some ways, like scaling, rotating, flattening
    public static var segmentPattern: Segment {
        let cubicBezierCurve1 = CubicBezierCurve(point: CGPoint(x: 0.4, y: 0), controlPoint1: CGPoint(x: 1.0 / 9, y: 0), controlPoint2: CGPoint(x: 2.0 / 9, y: 0))
        let cubicBezierCurve2 = CubicBezierCurve(point: CGPoint(x: 0.5, y: 1.0 / 3), controlPoint1: CGPoint(x: 0.4, y: 0), controlPoint2: CGPoint(x: 1.0 / 5, y: 1.0 / 3))
        let cubicBezierCurve3 = CubicBezierCurve(point: CGPoint(x: 0.6, y: 0), controlPoint1: CGPoint(x: 0.8, y: 1.0 / 3), controlPoint2: CGPoint(x: 0.6, y: 0))
        let cubicBezierCurve4 = CubicBezierCurve(point: CGPoint(x: 1.0, y: 0), controlPoint1: CGPoint(x: 7.0 / 9, y: 0), controlPoint2: CGPoint(x: 8.0 / 9, y: 0))
        return Segment(cubicBezierCurves: [cubicBezierCurve1, cubicBezierCurve2, cubicBezierCurve3, cubicBezierCurve4])
    }

    // MARK: Methods

    /**
     Generates complete puzzle unit for indicated size and desired edges

     - parameter size:       Size of the puzzle unit (final value might be bigger, due to outer edges)
     - parameter topEdge:    Desired top edge
     - parameter rightEdge:  Desired right edge
     - parameter bottomEdge: Desired bottom edge
     - parameter leftEdge:   Desired left edge

     - returns: Complete puzzle unit with individual segments (edges) and path (concatenation of all segments)
     */
    public static func generatePuzzleUnit(forSize size: CGSize, topEdge: PuzzleEdge, rightEdge: PuzzleEdge, bottomEdge: PuzzleEdge, leftEdge: PuzzleEdge) -> PuzzleUnit {
        // Segments which will be held by puzzle unit and these segments will be used to generate next units
        var topSegment: Segment!
        var rightSegment: Segment!
        var bottomSegment: Segment!
        var leftSegment: Segment!

        // Original segments with additional modification - rotation. Will be used to create final path
        var topSegmentRotated: Segment! = topSegment
        var rightSegmentRotated: Segment! = rightSegment
        var bottomSegmentRotated: Segment! = bottomSegment
        var leftSegmentRotated: Segment! = leftSegment

        // Generating top segment
        topSegment = segmentPattern
        switch topEdge {
        case .flat:
            topSegment.makeFlat()
            fallthrough
        case .missing:
            topSegment.scale(size.width, syFactor: size.height)
        case var .mirror(segment):
            segment.mirror()
            topSegment = segment
        }
        // Top segment should never be rotated
        topSegmentRotated = topSegment

        // Generating right segment
        rightSegment = segmentPattern
        switch rightEdge {
        case .flat:
            rightSegment.makeFlat()
            fallthrough
        case .missing:
            rightSegment.scale(size.height, syFactor: size.height)
            if Bool.random() { // Pick up randomly whether segment should be 'outer' or 'inner'
                rightSegment.mirror()
            }
        case var .mirror(segment):
            segment.mirror()
            rightSegment = segment
        }
        rightSegmentRotated = rightSegment
        // Only one rotation is required
        rightSegmentRotated.rotate(forYValue: size.width)

        // Generating bottom segment
        bottomSegment = segmentPattern
        switch bottomEdge {
        case .flat:
            bottomSegment.makeFlat()
            fallthrough
        case .missing:
            bottomSegment.scale(size.width, syFactor: size.width)
            if Bool.random() {
                bottomSegment.mirror()
            }
        case var .mirror(segment):
            segment.mirror()
            bottomSegment = segment
        }
        bottomSegmentRotated = bottomSegment
        // Two rotations required
        bottomSegmentRotated.rotate(forYValue: size.height)
        bottomSegmentRotated.rotate(forYValue: size.width)

        // Generating left segment
        leftSegment = segmentPattern
        switch leftEdge {
        case .flat:
            leftSegment.makeFlat()
            fallthrough
        case .missing:
            leftSegment.scale(size.height, syFactor: size.height)
        case var .mirror(segment):
            segment.mirror()
            leftSegment = segment
        }
        leftSegmentRotated = leftSegment
        // Three rotations required
        leftSegmentRotated.rotate(forYValue: size.height)
        leftSegmentRotated.rotate(forYValue: size.height)
        leftSegmentRotated.rotate(forYValue: size.height)

        // Concatenating all cubic bezier curves from all segments
        let pathMaker = UIBezierPath.pathMaker(forFirstPoint: .zero)
        var path: UIBezierPath
        path = pathMaker(topSegmentRotated.cubicBezierCurves)
        path = pathMaker(rightSegmentRotated.cubicBezierCurves)
        path = pathMaker(bottomSegmentRotated.cubicBezierCurves)
        path = pathMaker(leftSegmentRotated.cubicBezierCurves)
        path.close() // Here is the place where path can be finally closed

        path.apply(CGAffineTransform(translationX: -path.bounds.minX, y: -path.bounds.minY)) // Zeroing x, y positions

        return PuzzleUnit(topSegment: topSegment, rightSegment: rightSegment, bottomSegment: bottomSegment, leftSegment: leftSegment, path: path)
    }
}
