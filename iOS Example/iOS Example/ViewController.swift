//
//  ViewController.swift
//  iOS Example
//
//  Created by Paweł Kania on 09/08/16.
//  Copyright © 2016 Paweł Kania. All rights reserved.
//

import PuzzleMaker
import UIKit

class ViewController: UIViewController {

    static let numRows = 5
    static let numColumns = 7

    override func viewDidLoad() {
        super.viewDidLoad()

        let puzzleMaker = PuzzleMaker(image: UIImage(named: "image")!, numRows: ViewController.numRows, numColumns: ViewController.numColumns)
        puzzleMaker.generatePuzzles { throwableClosure in
            do {
                let puzzleElements = try throwableClosure()
                for row in 0 ..< ViewController.numRows {
                    for column in 0 ..< ViewController.numColumns {
                        guard let puzzleElement = puzzleElements[row][column] else { continue }
                        let position = puzzleElement.position
                        let image = puzzleElement.image
                        let imgView = UIImageView(frame: CGRect(x: position.x, y: position.y, width: image.size.width, height: image.size.height))
                        imgView.image = image
                        self.view.addSubview(imgView)
                    }
                }

            } catch {
                debugPrint(error)
            }
        }
    }

    override var prefersStatusBarHidden: Bool {
        return true
    }
}
