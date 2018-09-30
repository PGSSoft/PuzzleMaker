//
//  ViewController.swift
//  iOS Example
//
//  Created by Paweł Kania on 09/08/16.
//  Copyright © 2016 Paweł Kania. All rights reserved.
//

import UIKit
import PuzzleMaker

class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        let bounds = self.view.bounds
        let imgDim = CGFloat(100.0)
        let numColumns = Int(round(bounds.width/imgDim))
        let numRows = Int(round(bounds.height/imgDim))
        var image = UIImage(named: "image")!
        // Resize image for given device.
        UIGraphicsBeginImageContextWithOptions(bounds.size, _: false, _: 0.0)
        image.draw(in: CGRect(x: 0, y: 0, width: bounds.width, height: bounds.height))
        image = UIGraphicsGetImageFromCurrentImageContext()!
        UIGraphicsEndImageContext()
        // Make puzzle.
        let puzzleMaker = PuzzleMaker(image: image, numRows: numRows, numColumns: numColumns)
        puzzleMaker.generatePuzzles { (throwableClosure) in
            do {
                let puzzleElements = try throwableClosure()
                for row in 0 ..< numRows {
                    for column in 0 ..< numColumns {
                        let puzzleElement = puzzleElements[row][column]
                        let position = puzzleElement.position
                        let image = puzzleElement.image
                        let imgView = UIImageView(frame: CGRect(x: position.x, y: position.y, width: image.size.width, height: image.size.height))
                        imgView.image = image
                        self.view.addSubview(imgView)
                    }
                }

            } catch let error {
                debugPrint(error)
            }
        }
    }

    override var prefersStatusBarHidden: Bool {
        return true
    }
}
