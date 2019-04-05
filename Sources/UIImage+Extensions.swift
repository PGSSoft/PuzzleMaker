//
//  UIImage+Extensions.swift
//  PuzzleMaker
//
//  Created by Paweł Kania on 09/08/16.
//
//

import UIKit

extension UIImage {

    // MARK: Methods

    /**
     Crops image to a rect

     - parameter rect: Rect of the cropped image

     - returns: Cropped image. Might be nil if the rect parameter defines an area that is not in the image
     */
    public func cropImage(toRect rect: CGRect) -> UIImage? {
        if let cgImage = cgImage, let croppedImage = cgImage.cropping(to: rect) {
            return UIImage(cgImage: croppedImage, scale: scale, orientation: imageOrientation)
        }
        return nil
    }

    /**
     Clips image to a bezier path

     - parameter path: Bezier path

     - returns: Clipped image
     */
    public func clipImage(toPath path: UIBezierPath) -> UIImage? {
        UIGraphicsBeginImageContextWithOptions(size, false, scale)

        guard let cgImage = cgImage, let context = UIGraphicsGetCurrentContext() else {
            UIGraphicsEndImageContext()
            return nil
        }

        context.scaleBy(x: 1, y: -1)
        context.translateBy(x: 0, y: -size.height)

        path.addClip()

        context.draw(cgImage, in: CGRect(x: 0, y: 0, width: size.width, height: size.height))

        let clippedImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return clippedImage
    }

    /**
     Adds inner shadow to the image

     - parameter path:             Path on which shadow should be routed
     - parameter shadowColor:      Color used for the shadow
     - parameter shadowOffset:     Offset in user space of the shadow from the original drawing
     - parameter shadowBlurRadius: Blur radius of the shadow

     - returns: New image with inner shadow
     */
    public func applyInnerShadow(forPath path: UIBezierPath, shadowColor: UIColor, shadowOffset: CGSize, shadowBlurRadius: CGFloat) -> UIImage? {
        UIGraphicsBeginImageContextWithOptions(size, false, scale)

        guard let cgImage = cgImage, let context = UIGraphicsGetCurrentContext() else {
            UIGraphicsEndImageContext()
            return nil
        }

        context.scaleBy(x: 1, y: -1)
        context.translateBy(x: 0, y: -size.height)

        context.draw(cgImage, in: CGRect(x: 0, y: 0, width: size.width, height: size.height))
        UIColor(red: 0, green: 0, blue: 0, alpha: 0).setFill()
        path.fill()

        context.saveGState()
        context.clip(to: path.bounds)
        context.setShadow(offset: .zero, blur: 0)
        context.setAlpha(shadowColor.cgColor.alpha)
        context.beginTransparencyLayer(auxiliaryInfo: nil)
        let ovalOpaqueShadow = shadowColor.withAlphaComponent(1)
        context.setShadow(offset: shadowOffset, blur: shadowBlurRadius, color: ovalOpaqueShadow.cgColor)
        context.setBlendMode(.sourceOut)
        context.beginTransparencyLayer(auxiliaryInfo: nil)

        ovalOpaqueShadow.setFill()
        path.fill()

        context.endTransparencyLayer()
        context.endTransparencyLayer()
        context.restoreGState()

        let clippedImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return clippedImage
    }
}
