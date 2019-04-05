//
//  PuzzleMaker.swift
//  PuzzleMaker
//
//  Created by Paweł Kania on 09/08/16.
//
//

import UIKit

public typealias AdjustableShadow = (color: UIColor, offset: CGSize, blurRadius: CGFloat)

/**
 Errors which can occur while generating puzzles

 - invalidGridSize:  Occurs when number of rows or columns is less than 2
 - invalidImageSize: Might happen when cropping image in case, when the rect parameter defines an area that is not in the image
 */
public enum PuzzleMakerError: Error {
    case invalidGridSize, invalidImageSize, puzzleUnitUnavailable
}

/**
 *  Ladies and gentlemen, I would like to introduce you to, The PuzzleMaker! The one who creates the puzzles from the image! 🎉
 */
public struct PuzzleMaker {

    // MARK: Properties

    /// Source image
    public let image: UIImage

    /// Number of rows
    public let numRows: Int

    /// Number of columns
    public let numColumns: Int

    // Darkening shadow which will be applied to each puzzle unit individually
    public let darkInnerShadow: AdjustableShadow

    // Lightening shadow which will be applied to each puzzle unit individually
    public let lightInnerShadow: AdjustableShadow

    /// Size of the single puzzle item (not puzzle element!) which is a result of size of the source image and number of rows and columns
    public var puzzleUnitSize: CGSize {
        return CGSize(width: image.size.width / CGFloat(numColumns), height: image.size.height / CGFloat(numRows))
    }

    private let safeQueue = DispatchQueue(label: "com.puzzlemaker.safe-queue")
    private let mainQueue = DispatchQueue(label: "com.puzzlemaker.main-queue", attributes: .concurrent)

    // MARK: Initializers

    public init(image: UIImage,
                numRows: Int,
                numColumns: Int,
                darkInnerShadow: AdjustableShadow = (color: UIColor(red: 0.5, green: 0.5, blue: 0.5, alpha: 0.75), offset: CGSize(width: -1, height: -1), blurRadius: 2),
                lightInnerShadow: AdjustableShadow = (color: UIColor(red: 1, green: 1, blue: 1, alpha: 0.75), offset: CGSize(width: 1, height: 1), blurRadius: 2)) {
        self.image = image
        self.numRows = numRows
        self.numColumns = numColumns
        self.darkInnerShadow = darkInnerShadow
        self.lightInnerShadow = lightInnerShadow
    }

    // MARK: Methods

    /**
     Asynchronously generates set of the puzzles

     - parameter completion: Throwable closure so you need 'try catch' it. On success it returns [[PuzzleElement]], otherwise handle error. See attached example
     */
    public func generatePuzzles(_ completion: @escaping (_ throwableClosure: () throws -> [[PuzzleElement?]]) -> Void) {
        // Number of rows or columns cannot be less than 2
        if numRows < 2 || numColumns < 2 {
            completion { throw PuzzleMakerError.invalidGridSize }
            return
        }

        // We will print execution time
        let start = Date()

        // Any operation related to core graphics might be time consuming, so it should be done asynchronous
        let group = DispatchGroup()

        // Multidimensional array for final puzzle elements
        var puzzleElements = [[PuzzleElement?]](repeating: [PuzzleElement?](repeating: nil, count: numColumns), count: numRows)

        // First, all puzzle units must be generated and stored somewhere
        var puzzleUnits = [[PuzzleUnit?]](repeating: [PuzzleUnit?](repeating: nil, count: numColumns), count: numRows)
        var puzzleUnit: PuzzleUnit?

        // Flag which indicates if there was a problem in generating at least one puzzle element. True means total failure and raises exception
        var invalidImageSize = false
        // Flag which indicates that for some reason, puzzle unit could not be created
        var puzzleUnitUnavailable = false

        // The order matters (row and column) - top and left edge of each puzzle unit must be known before generating next item

        /*

         Cheatsheet:

         ┌───┬───┬───┐
         │ 0 │ 1 │ 2 │
         ├───┼───┼───┤
         │ 3 │ 4 │ 5 │
         ├───┼───┼───┤
         │ 6 │ 7 │ 8 │
         └───┴───┴───┘

         */

        let throwException = { completion { throw PuzzleMakerError.puzzleUnitUnavailable } }

        func getPuzzleUnit(_ row: Int, _ col: Int) -> PuzzleUnit? {
            if puzzleUnits.count > row - 1, row >= 0 {
                let rows = puzzleUnits[row]
                if rows.count > col - 1, col >= 0 {
                    return puzzleUnits[row][col]
                } else {
                    return nil
                }
            } else {
                return nil
            }
        }

        for row in 0 ..< numRows {
            for column in 0 ..< numColumns {
                switch (row, column) {
                // Cheatsheet: 0
                case (0, 0):
                    puzzleUnit = PuzzleUnitFactory.generatePuzzleUnit(forSize: puzzleUnitSize, topEdge: .flat, rightEdge: .missing, bottomEdge: .missing, leftEdge: .flat)
                // Cheatsheet: 2
                case let (r, c) where r == 0 && c == numColumns - 1:
                    guard let leftNeighbor = getPuzzleUnit(r, c - 1) else { return throwException() }
                    puzzleUnit = PuzzleUnitFactory.generatePuzzleUnit(forSize: puzzleUnitSize, topEdge: .flat, rightEdge: .flat, bottomEdge: .missing, leftEdge: .mirror(leftNeighbor.rightSegment))
                // Cheatsheet: 6
                case let (r, c) where r == numRows - 1 && c == 0:
                    guard let topNeighbor = getPuzzleUnit(r - 1, c) else { return throwException() }
                    puzzleUnit = PuzzleUnitFactory.generatePuzzleUnit(forSize: puzzleUnitSize, topEdge: .mirror(topNeighbor.bottomSegment), rightEdge: .missing, bottomEdge: .flat, leftEdge: .flat)
                // Cheatsheet: 8
                case let (r, c) where r == numRows - 1 && c == numColumns - 1:
                    guard let topNeighbor = getPuzzleUnit(r - 1, c), let leftNeighbor = getPuzzleUnit(r, c - 1) else { return throwException() }
                    puzzleUnit = PuzzleUnitFactory.generatePuzzleUnit(forSize: puzzleUnitSize, topEdge: .mirror(topNeighbor.bottomSegment), rightEdge: .flat, bottomEdge: .flat, leftEdge: .mirror(leftNeighbor.rightSegment))
                // Cheatsheet: 1
                case let (r, c) where r == 0:
                    guard let leftNeighbor = getPuzzleUnit(r, c - 1) else { return throwException() }
                    puzzleUnit = PuzzleUnitFactory.generatePuzzleUnit(forSize: puzzleUnitSize, topEdge: .flat, rightEdge: .missing, bottomEdge: .missing, leftEdge: .mirror(leftNeighbor.rightSegment))
                // Cheatsheet: 5
                case let (r, c) where c == numColumns - 1:
                    guard let topNeighbor = getPuzzleUnit(r - 1, c), let leftNeighbor = getPuzzleUnit(r, c - 1) else { return throwException() }
                    puzzleUnit = PuzzleUnitFactory.generatePuzzleUnit(forSize: puzzleUnitSize, topEdge: .mirror(topNeighbor.bottomSegment), rightEdge: .flat, bottomEdge: .missing, leftEdge: .mirror(leftNeighbor.rightSegment))
                // Cheatsheet: 7
                case let (r, c) where r == numRows - 1:
                    guard let topNeighbor = getPuzzleUnit(r - 1, c), let leftNeighbor = getPuzzleUnit(r, c - 1) else { return throwException() }
                    puzzleUnit = PuzzleUnitFactory.generatePuzzleUnit(forSize: puzzleUnitSize, topEdge: .mirror(topNeighbor.bottomSegment), rightEdge: .missing, bottomEdge: .flat, leftEdge: .mirror(leftNeighbor.rightSegment))
                // Cheatsheet: 3
                case let (r, c) where c == 0:
                    guard let topNeighbor = getPuzzleUnit(r - 1, c) else { return throwException() }
                    puzzleUnit = PuzzleUnitFactory.generatePuzzleUnit(forSize: puzzleUnitSize, topEdge: .mirror(topNeighbor.bottomSegment), rightEdge: .missing, bottomEdge: .missing, leftEdge: .flat)
                // Cheatsheet: 4
                case let (r, c):
                    guard let topNeighbor = getPuzzleUnit(r - 1, c), let leftNeighbor = getPuzzleUnit(r, c - 1) else { return throwException() }
                    puzzleUnit = PuzzleUnitFactory.generatePuzzleUnit(forSize: puzzleUnitSize, topEdge: .mirror(topNeighbor.bottomSegment), rightEdge: .missing, bottomEdge: .missing, leftEdge: .mirror(leftNeighbor.rightSegment))
                }

                puzzleUnits[row][column] = puzzleUnit

                // Only operations related to core graphics should be done asynchronous
                group.enter()
                mainQueue.async {
                    if invalidImageSize { // If at least one puzzle is invalid, every next operation should be canceled
                        group.leave()
                        return
                    }

                    guard let puzzleUnit = puzzleUnits[row][column] else {
                        puzzleUnitUnavailable = true
                        group.leave()
                        return
                    }

                    let path = puzzleUnit.path

                    // Because we must fix X and Y position, we need to know offset. Outer height for top and left segment will be useful
                    let topSegmentHeight = puzzleUnit.topSegment.outerHeight
                    let leftSegmentHeight = puzzleUnit.leftSegment.outerHeight

                    // Visual position is how the human eye will interpret position of the puzzle on the board
                    let visualPosition = CGPoint(x: CGFloat(column) * self.puzzleUnitSize.width, y: CGFloat(row) * self.puzzleUnitSize.height)

                    // Real position is exact X and Y position on the board, including outer offsets
                    let realPosition = CGPoint(x: visualPosition.x - leftSegmentHeight, y: visualPosition.y - topSegmentHeight)

                    // Crop rect which includes outer offset multiplied by proper scale of the image
                    let scale = self.image.scale
                    let cropRect = CGRect(x: realPosition.x * scale, y: realPosition.y * scale, width: path.bounds.width * scale, height: path.bounds.height * scale)

                    // Because method CGImageCreateWithImageInRect(...) can fail, we need to hadle it somehow
                    if let croppedImage = self.image.cropImage(toRect: cropRect),
                        // Clipping image using previously generated path
                        let clippedImage = croppedImage.clipImage(toPath: path),
                        // Now it's time to cheat human eye by adding two inner shadows (most time consuming part...)
                        let imageWithDarkInnerShadow = clippedImage.applyInnerShadow(forPath: path, shadowColor: self.darkInnerShadow.color, shadowOffset: self.darkInnerShadow.offset, shadowBlurRadius: self.darkInnerShadow.blurRadius),
                        let imageWithLightInnerShadow = imageWithDarkInnerShadow.applyInnerShadow(forPath: path, shadowColor: self.lightInnerShadow.color, shadowOffset: self.lightInnerShadow.offset, shadowBlurRadius: self.lightInnerShadow.blurRadius) {

                        // Finally! We got it! 🙌
                        let puzzleElement = PuzzleElement(image: imageWithLightInnerShadow, position: realPosition, puzzleUnit: puzzleUnit)

                        // Secure access to array
                        // It will probably cause performance drops, so this is a area for improvements (e.g. use N x Row arrays to store data)
                        self.safeQueue.sync {
                            puzzleElements[row][column] = puzzleElement
                        }
                    } else {
                        // Oh no... 😖
                        invalidImageSize = true
                    }
                    group.leave()
                }
            }
        }

        // Once everything is done, we can finish whole process
        _ = group.wait(timeout: DispatchTime.distantFuture)
        mainQueue.async {
            let executionTime = Date().timeIntervalSince(start)
            debugPrint("Puzzles generated in: \(executionTime) second(s)")

            DispatchQueue.main.async {
                if invalidImageSize {
                    completion { throw PuzzleMakerError.invalidImageSize }
                } else if puzzleUnitUnavailable {
                    completion { throw PuzzleMakerError.puzzleUnitUnavailable }
                } else {
                    completion { puzzleElements }
                }
            }
        }
    }
}
