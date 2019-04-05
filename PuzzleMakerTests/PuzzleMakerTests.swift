//
//  PuzzleMakerTests.swift
//  PuzzleMakerTests
//
//  Created by Paweł Kania on 11/08/16.
//
//

@testable import PuzzleMaker
import XCTest

class PuzzleMakerTests: XCTestCase {

    var image: UIImage!

    override func setUp() {
        super.setUp()

        let bundle = Bundle(for: PuzzleMakerTests.self)
        image = UIImage(named: "image", in: bundle, compatibleWith: nil)
    }

    func testPuzzleMaker() {
        let numRows = 5
        let numColumns = 7

        let puzzleMaker = PuzzleMaker(image: image, numRows: numRows, numColumns: numColumns)

        XCTAssertTrue(puzzleMaker.puzzleUnitSize.width == image.size.width / CGFloat(numColumns))
        XCTAssertTrue(puzzleMaker.puzzleUnitSize.height == image.size.height / CGFloat(numRows))

        let asyncExpectation = expectation(description: "Asynchronously generating puzzles")

        puzzleMaker.generatePuzzles { throwableClosure in
            let puzzleElements = try! throwableClosure()

            XCTAssertTrue(puzzleElements.count == numRows)

            XCTAssertTrue(puzzleElements[0].count == numColumns)
            XCTAssertTrue(puzzleElements[1].count == numColumns)
            XCTAssertTrue(puzzleElements[2].count == numColumns)
            XCTAssertTrue(puzzleElements[3].count == numColumns)
            XCTAssertTrue(puzzleElements[4].count == numColumns)

            asyncExpectation.fulfill()
        }

        waitForExpectations(timeout: 3, handler: nil)
    }

    func testInvalidGridSize() {
        let numRows = 1
        let numColumns = 1

        let puzzleMaker = PuzzleMaker(image: image, numRows: numRows, numColumns: numColumns)

        let asyncExpectation = expectation(description: "Asynchronously generating puzzles")

        puzzleMaker.generatePuzzles { throwableClosure in
            do {
                _ = try throwableClosure()
                XCTFail("Should throw exception")
            } catch {
                XCTAssertTrue(error as! PuzzleMakerError == PuzzleMakerError.invalidGridSize)
            }
            asyncExpectation.fulfill()
        }

        waitForExpectations(timeout: 3, handler: nil)
    }

    func testInvalidImageSize() {
        let numRows = 2
        let numColumns = 2

        /// 😅
        class WeirdImage: UIImage {
            override var size: CGSize {
                return .zero
            }
        }

        let puzzleMaker = PuzzleMaker(image: WeirdImage(), numRows: numRows, numColumns: numColumns)

        let asyncExpectation = expectation(description: "Asynchronously generating puzzles")

        puzzleMaker.generatePuzzles { throwableClosure in
            do {
                _ = try throwableClosure()
                XCTFail("Should throw exception")
            } catch {
                XCTAssertTrue(error as! PuzzleMakerError == PuzzleMakerError.invalidImageSize)
            }
            asyncExpectation.fulfill()
        }

        waitForExpectations(timeout: 3, handler: nil)
    }

    func testSegment() {
        let segmentPattern = PuzzleUnitFactory.segmentPattern
        XCTAssertTrue(segmentPattern.cubicBezierCurves.count == 4)
        XCTAssertTrue(segmentPattern.path.contains(CGPoint(x: 0.4, y: 0)))
        XCTAssertTrue(segmentPattern.path.contains(CGPoint(x: 0.5, y: 1.0 / 3)))
        XCTAssertTrue(segmentPattern.path.contains(CGPoint(x: 0.6, y: 0)))
        XCTAssertTrue(segmentPattern.path.contains(CGPoint(x: 1.0, y: 0)))
    }

    func testFlattenedSegment() {
        var flattenedSegment = PuzzleUnitFactory.segmentPattern
        flattenedSegment.makeFlat()
        checkFlattenedSegment(flattenedSegment)
    }

    func testMirroredSegment() {
        var mirroredSegment = PuzzleUnitFactory.segmentPattern
        mirroredSegment.mirror()
        checkMirroredSegment(mirroredSegment)
    }

    func testScaledSegment() {
        var scaledSegment = PuzzleUnitFactory.segmentPattern
        let scale = CGSize(width: 100, height: 150)
        scaledSegment.scale(scale.width, syFactor: scale.height)
        checkScaledSegment(scaledSegment, scale: scale)
    }

    func testRotatedSegment() {
        var rotatedSegment = PuzzleUnitFactory.segmentPattern
        let ty: CGFloat = 225
        // Rotation of 360 degrees should give original segment pattern
        rotatedSegment.rotate(forYValue: ty)
        rotatedSegment.rotate(forYValue: ty)
        rotatedSegment.rotate(forYValue: ty)
        rotatedSegment.rotate(forYValue: ty)
        checkRotatedSegment(rotatedSegment, ty: ty)
    }

    func testPuzzleUnitFactoryWithFlattenedSegments() {
        let puzzleUnitSize = CGSize(width: 100, height: 100)
        let puzzleUnit = PuzzleUnitFactory.generatePuzzleUnit(forSize: puzzleUnitSize, topEdge: .flat, rightEdge: .flat, bottomEdge: .flat, leftEdge: .flat)
        checkFlattenedSegment(puzzleUnit.topSegment)
        checkFlattenedSegment(puzzleUnit.rightSegment)
        checkFlattenedSegment(puzzleUnit.bottomSegment)
        checkFlattenedSegment(puzzleUnit.leftSegment)
    }

    func testPuzzleUnitFactoryWithMirroredSegments() {
        let puzzleUnitSize = CGSize(width: 100, height: 100)
        let segmentPattern = PuzzleUnitFactory.segmentPattern
        let puzzleUnit = PuzzleUnitFactory.generatePuzzleUnit(forSize: puzzleUnitSize, topEdge: .mirror(segmentPattern), rightEdge: .mirror(segmentPattern), bottomEdge: .mirror(segmentPattern), leftEdge: .mirror(segmentPattern))
        checkMirroredSegment(puzzleUnit.topSegment)
        checkMirroredSegment(puzzleUnit.rightSegment)
        checkMirroredSegment(puzzleUnit.bottomSegment)
        checkMirroredSegment(puzzleUnit.leftSegment)
    }

    func testPuzzleUnitFactoryWithMissingSegments() {
        let puzzleUnitSize = CGSize(width: 100, height: 100)
        let puzzleUnit = PuzzleUnitFactory.generatePuzzleUnit(forSize: puzzleUnitSize, topEdge: .missing, rightEdge: .missing, bottomEdge: .missing, leftEdge: .missing)
        // The absolute value of missing segment and pattern * scale should be the same
        checkScaledSegmentWithAbsoluteOption(puzzleUnit.topSegment, scale: puzzleUnitSize)
        checkScaledSegmentWithAbsoluteOption(puzzleUnit.rightSegment, scale: puzzleUnitSize)
        checkScaledSegmentWithAbsoluteOption(puzzleUnit.bottomSegment, scale: puzzleUnitSize)
        checkScaledSegmentWithAbsoluteOption(puzzleUnit.leftSegment, scale: puzzleUnitSize)
    }

    func testDoubleExtensions() {
        let lower = 0.3333
        let upper = 0.9999

        let random0 = Double.random(in: lower ... upper)
        XCTAssertTrue(random0 >= lower && random0 <= upper)

        let random1 = Double.random(in: lower ... upper)
        XCTAssertTrue(random1 >= lower && random1 <= upper)

        let random2 = Double.random(in: lower ... upper)
        XCTAssertTrue(random2 >= lower && random2 <= upper)

        let random3 = Double.random(in: lower ... upper)
        XCTAssertTrue(random3 >= lower && random3 <= upper)

        let random4 = Double.random(in: lower ... upper)
        XCTAssertTrue(random4 >= lower && random4 <= upper)

        let random5 = Double.random(in: lower ... upper)
        XCTAssertTrue(random5 >= lower && random5 <= upper)

        let random6 = Double.random(in: lower ... upper)
        XCTAssertTrue(random6 >= lower && random6 <= upper)

        let random7 = Double.random(in: lower ... upper)
        XCTAssertTrue(random7 >= lower && random7 <= upper)

        let random8 = Double.random(in: lower ... upper)
        XCTAssertTrue(random8 >= lower && random8 <= upper)

        let random9 = Double.random(in: lower ... upper)
        XCTAssertTrue(random9 >= lower && random9 <= upper)
    }

    func testArrayExtension() {
        let array = [1, 2, 3]
        XCTAssertTrue(array[safe: 0] != nil)
        XCTAssertTrue(array[safe: 1] != nil)
        XCTAssertTrue(array[safe: 2] != nil)
        XCTAssertTrue(array[safe: 3] == nil)
        XCTAssertTrue(array[safe: 999_999] == nil)
        XCTAssertTrue(array[safe: -1] == nil)
        XCTAssertTrue(array[safe: -999_999] == nil)
    }

    // MARK: - Helpers

    func checkFlattenedSegment(_ segment: Segment) {
        XCTAssertTrue(segment.cubicBezierCurves.count == 4)
        segment.cubicBezierCurves.forEach { cubicBezierCurve in
            XCTAssertTrue(cubicBezierCurve.point.y == 0)
            XCTAssertTrue(cubicBezierCurve.controlPoint1.y == 0)
            XCTAssertTrue(cubicBezierCurve.controlPoint2.y == 0)
        }
    }

    func checkMirroredSegment(_ segment: Segment) {
        let segmentPattern = PuzzleUnitFactory.segmentPattern
        XCTAssertTrue(segment.cubicBezierCurves.count == 4)
        for (idx, cubicBezierCurve) in segment.cubicBezierCurves.enumerated() {
            XCTAssertTrue(abs(cubicBezierCurve.point.y) - abs(segmentPattern.cubicBezierCurves[idx].point.y) == 0.0)
            XCTAssertTrue(abs(cubicBezierCurve.controlPoint1.y) - abs(segmentPattern.cubicBezierCurves[idx].controlPoint1.y) == 0.0)
            XCTAssertTrue(abs(cubicBezierCurve.controlPoint2.y) - abs(segmentPattern.cubicBezierCurves[idx].controlPoint2.y) == 0.0)
        }
    }

    func checkScaledSegment(_ segment: Segment, scale: CGSize) {
        let segmentPattern = PuzzleUnitFactory.segmentPattern
        XCTAssertTrue(segment.cubicBezierCurves.count == 4)
        for (idx, cubicBezierCurve) in segment.cubicBezierCurves.enumerated() {
            XCTAssertTrue(cubicBezierCurve.point.x == segmentPattern.cubicBezierCurves[idx].point.x * scale.width)
            XCTAssertTrue(cubicBezierCurve.point.y == segmentPattern.cubicBezierCurves[idx].point.y * scale.height)
            XCTAssertTrue(cubicBezierCurve.controlPoint1.x == segmentPattern.cubicBezierCurves[idx].controlPoint1.x * scale.width)
            XCTAssertTrue(cubicBezierCurve.controlPoint1.y == segmentPattern.cubicBezierCurves[idx].controlPoint1.y * scale.height)
            XCTAssertTrue(cubicBezierCurve.controlPoint2.x == segmentPattern.cubicBezierCurves[idx].controlPoint2.x * scale.width)
            XCTAssertTrue(cubicBezierCurve.controlPoint2.y == segmentPattern.cubicBezierCurves[idx].controlPoint2.y * scale.height)
        }
    }

    func checkScaledSegmentWithAbsoluteOption(_ segment: Segment, scale: CGSize) {
        let segmentPattern = PuzzleUnitFactory.segmentPattern
        XCTAssertTrue(segment.cubicBezierCurves.count == 4)
        for (idx, cubicBezierCurve) in segment.cubicBezierCurves.enumerated() {
            XCTAssertTrue(abs(cubicBezierCurve.point.x) == abs(segmentPattern.cubicBezierCurves[idx].point.x * scale.width))
            XCTAssertTrue(abs(cubicBezierCurve.point.y) == abs(segmentPattern.cubicBezierCurves[idx].point.y * scale.height))
            XCTAssertTrue(abs(cubicBezierCurve.controlPoint1.x) == abs(segmentPattern.cubicBezierCurves[idx].controlPoint1.x * scale.width))
            XCTAssertTrue(abs(cubicBezierCurve.controlPoint1.y) == abs(segmentPattern.cubicBezierCurves[idx].controlPoint1.y * scale.height))
            XCTAssertTrue(abs(cubicBezierCurve.controlPoint2.x) == abs(segmentPattern.cubicBezierCurves[idx].controlPoint2.x * scale.width))
            XCTAssertTrue(abs(cubicBezierCurve.controlPoint2.y) == abs(segmentPattern.cubicBezierCurves[idx].controlPoint2.y * scale.height))
        }
    }

    func checkRotatedSegment(_ segment: Segment, ty: CGFloat) {
        let segmentPattern = PuzzleUnitFactory.segmentPattern
        XCTAssertTrue(segment.cubicBezierCurves.count == 4)
        for (idx, cubicBezierCurve) in segment.cubicBezierCurves.enumerated() {
            // Workaround due to issues when comparing two decimal numbers
            func compareCGFloats(_ first: CGFloat, _ second: CGFloat) -> Bool {
                let handler = NSDecimalNumberHandler(roundingMode: NSDecimalNumber.RoundingMode.down, scale: 2, raiseOnExactness: false, raiseOnOverflow: false, raiseOnUnderflow: false, raiseOnDivideByZero: false)
                let firstNum = NSDecimalNumber(value: Float(first) as Float).rounding(accordingToBehavior: handler)
                let secondNum = NSDecimalNumber(value: Float(second) as Float).rounding(accordingToBehavior: handler)
                return firstNum.compare(secondNum) == .orderedSame
            }
            XCTAssertTrue(compareCGFloats(cubicBezierCurve.point.x, segmentPattern.cubicBezierCurves[idx].point.x))
            XCTAssertTrue(compareCGFloats(cubicBezierCurve.point.y, segmentPattern.cubicBezierCurves[idx].point.y))
            XCTAssertTrue(compareCGFloats(cubicBezierCurve.controlPoint1.x, segmentPattern.cubicBezierCurves[idx].controlPoint1.x))
            XCTAssertTrue(compareCGFloats(cubicBezierCurve.controlPoint1.x, segmentPattern.cubicBezierCurves[idx].controlPoint1.x))
            XCTAssertTrue(compareCGFloats(cubicBezierCurve.controlPoint2.x, segmentPattern.cubicBezierCurves[idx].controlPoint2.x))
            XCTAssertTrue(compareCGFloats(cubicBezierCurve.controlPoint2.x, segmentPattern.cubicBezierCurves[idx].controlPoint2.x))
        }
    }
}
