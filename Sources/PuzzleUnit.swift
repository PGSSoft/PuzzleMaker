//
//  PuzzleUnit.swift
//  PuzzleMaker
//
//  Created by Paweł Kania on 09/08/16.
//
//

import UIKit

/**
 *  Describes single puzzle unit, which is a collection of a cubic bezier curves in fact.
 *  Also, struct provides information about all four segments which represents all edges
 * - warning:
 * To simplify future calculations, all four segments are kept in original orientation. Orientation change occurs when final path is calculated
 */
public struct PuzzleUnit {

    // MARK: Properties

    /// Top segment
    /// - attention:
    /// Never rotated to simplify future calculations
    public let topSegment: Segment

    /// Right segment
    /// - attention:
    /// Never rotated to simplify future calculations
    public let rightSegment: Segment

    /// Bottom segment
    /// - attention:
    /// Never rotated to simplify future calculations
    public let bottomSegment: Segment

    /// Left segment
    /// - attention:
    /// Never rotated to simplify future calculations
    public let leftSegment: Segment

    /// Final path which is a concatenation of all four segments
    /// - attention:
    /// Path is built from rotated segments
    public let path: UIBezierPath
}
