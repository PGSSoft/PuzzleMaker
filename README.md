![pgssoft-logo.png](pgssoft-logo.png)

# PuzzleMaker

`PuzzleMaker` is a library written in Swift, which dynamically generates set of puzzles from the image.

[![Swift 4.0](https://img.shields.io/badge/Swift-4.0-green.svg?style=flat)](https://swift.org/)
[![Travis](https://travis-ci.org/PGSSoft/PuzzleMaker.svg?branch=master)](https://travis-ci.org/PGSSoft/PuzzleMaker.svg?branch=master)
[![CocoaPods Compatible](https://img.shields.io/cocoapods/v/PuzzleMaker.svg)](https://cocoapods.org/pods/PuzzleMaker)
[![Carthage Compatible](https://img.shields.io/badge/Carthage-compatible-4BC51D.svg?style=flat)](https://github.com/Carthage/Carthage)
[![Platform](https://img.shields.io/cocoapods/p/PuzzleMaker.svg)](http://cocoadocs.org/docsets/PuzzleMaker)
[![License](https://img.shields.io/cocoapods/l/PuzzleMaker.svg)](https://github.com/PGSSoft/PuzzleMaker)

![PuzzleMaker.gif](PuzzleMaker.gif)

## Installation

The most convenient way to install it is by using [Cocoapods](https://cocoapods.org/) with Podfile:

```ruby
pod 'PuzzleMaker'
```

or using [Carthage](https://github.com/Carthage/Carthage) and add a line to `Cartfile`:

```
github "PGSSoft/PuzzleMaker"
```

## Requirements

iOS 8.0

## Usage

```swift
import PuzzleMaker
```

```swift
let puzzleMaker = PuzzleMaker(image: UIImage(named: "image")!, numRows: 3, numColumns: 5)
puzzleMaker.generatePuzzles { (throwableClosure) in
	do {
		let puzzleElements = try throwableClosure()
		for row in 0 ..< 3 {
			for column in 0 ..< 5 {
				let puzzleElement = puzzleElements[row][column]!
				// Do something with the single puzzle
			}
		}
	} catch let error {
		// Handle error
	}
}
```

## Contributing

Bug reports and pull requests are welcome on GitHub at [https://github.com/PGSSoft/PuzzleMaker](https://github.com/PGSSoft/PuzzleMaker).

## License

The project is available as open source under the terms of the [MIT License](http://opensource.org/licenses/MIT).

## About

The project maintained by [software development agency](https://www.pgs-soft.com/) [PGS Software](https://www.pgs-soft.com/).
See our other [open-source projects](https://github.com/PGSSoft) or [contact us](https://www.pgs-soft.com/contact-us/) to develop your product.

## Follow us

[![Twitter URL](https://img.shields.io/twitter/url/http/shields.io.svg?style=social)](https://twitter.com/intent/tweet?text=https://github.com/PGSSoft/PuzzleMaker)  
[![Twitter Follow](https://img.shields.io/twitter/follow/pgssoftware.svg?style=social&label=Follow)](https://twitter.com/pgssoftware)
