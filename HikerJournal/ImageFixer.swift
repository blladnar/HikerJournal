//
//  ImageFixer.swift
//  HikerJournal
//
//  Created by Randall Brown on 4/20/22.
//

import Foundation
import UIKit

extension UIImage {
    func scaleAndRotateImage(maxSize: CGFloat) -> UIImage
    {
        guard let imgRef = self.cgImage
            else { return self }

        let width = CGFloat(imgRef.width)
        let height = CGFloat(imgRef.height)

        var transform: CGAffineTransform = .identity

        var bounds = CGRect(x: 0, y: 0, width: width, height: height)

        if width > maxSize || height < maxSize {
            let ratio = width / height

            if ratio > 1 {
                bounds.size.width = maxSize
                bounds.size.height = bounds.size.width / ratio
            } else {
                bounds.size.height = maxSize
                bounds.size.width = bounds.size.height * ratio
            }
        }

        let scaleRatio = bounds.size.width / width
        let imageSize = CGSize(width: width, height: height)
        var boundHeight : CGFloat = 0.0

        let ori = self.imageOrientation

        switch(ori) {
        case .up:
            transform = .identity
            break

        case .down:
            transform = CGAffineTransform(translationX: imageSize.width, y: imageSize.height)
            transform = transform.rotated(by: CGFloat(Double.pi))
            break

        case .left:
            boundHeight = bounds.size.height
            bounds.size.height = bounds.size.width
            bounds.size.width = boundHeight
            transform = CGAffineTransform(translationX: 0.0, y: imageSize.width)
            transform = transform.rotated(by: CGFloat(3.0 * Double.pi / 2.0))
            break

        case .right:
            boundHeight = bounds.size.height
            bounds.size.height = bounds.size.width
            bounds.size.width = boundHeight
            transform = CGAffineTransform(translationX: imageSize.height, y: 0.0)
            transform = transform.rotated(by: CGFloat(Double.pi / 2.0))
            break

        case .upMirrored:
            transform = CGAffineTransform(translationX: imageSize.width, y: 0.0)
            transform = transform.scaledBy(x: -1.0, y: -1.0)
            break

        case .downMirrored:
            transform = CGAffineTransform(translationX: 0.0, y: imageSize.height)
            transform = transform.scaledBy(x: 1.0, y: -1.0)
            break

        case .leftMirrored:
            boundHeight = bounds.size.height
            bounds.size.height = bounds.size.width
            bounds.size.width = boundHeight
            transform = CGAffineTransform(translationX: imageSize.height, y: imageSize.width)
            transform = transform.scaledBy(x: -1.0, y: 1.0)
            transform = transform.rotated(by: CGFloat(3.0 * Double.pi / 2.0))
            break

        case .rightMirrored:
            boundHeight = bounds.size.height
            bounds.size.height = bounds.size.width
            bounds.size.width = boundHeight
            transform = CGAffineTransform(scaleX: -1.0, y: 1.0)
            transform = transform.rotated(by: CGFloat(Double.pi / 2.0))
            break
        @unknown default:
            transform = .identity
        }

        UIGraphicsBeginImageContext(bounds.size)

        guard let context = UIGraphicsGetCurrentContext()
            else { return self }

        if ori == UIImage.Orientation.right || ori == UIImage.Orientation.left {
            context.scaleBy(x: -scaleRatio, y: scaleRatio)
            context.translateBy(x: -height, y: 0.0)
        } else {
            context.scaleBy(x: scaleRatio, y: -scaleRatio)
            context.translateBy(x: 0.0, y: -height)
        }

        context.concatenate(transform)
        context.draw(imgRef, in: CGRect(x: 0, y: 0, width: width, height: height))

        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()

        return image ?? self
    }

}
