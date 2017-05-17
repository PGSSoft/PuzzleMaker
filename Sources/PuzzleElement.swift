//
//  PuzzleElement.swift
//  PuzzleMaker
//
//  Created by Paweł Kania on 09/08/16.
//
//

import UIKit

/**
 *  Describes single puzzle element, which holds prepared image, position on the board and puzzle unit which provides detailed information about path
 */
public struct PuzzleElement {

    // MARK: Properties

    /// Cropped and clipped image with additional effects: two inner shadows (light and dark to make it "more real")
    public let image: UIImage

    /// Exact position on the board. Includes offset and additional size added due to outer edges
    public let position: CGPoint

    /// Holds information about path and segments. For information purposes only
    public let puzzleUnit: PuzzleUnit
}
