//
//  NSImage.swift
//  Spotibar
//
//  Created by Viktor Strate Kløvedal on 25/11/2019.
//  Copyright © 2019 viktorstrate. All rights reserved.
//

import Cocoa

extension NSImage {
    func asThumbnail() -> NSImage {
        let targetSize = NSMakeSize(16, 16)
        let img = NSImage(size: targetSize)

        img.lockFocus()
        let ctx = NSGraphicsContext.current
        let cgCtx = ctx?.cgContext
        
        let targetRect = NSMakeRect(0, 0, targetSize.width, targetSize.height)
        
        let borderRadius: CGFloat = 2.0
        let roundedMask = NSBezierPath(roundedRect: targetRect, xRadius: borderRadius, yRadius: borderRadius)
        roundedMask.setClip()
        
        ctx?.imageInterpolation = .none
        self.draw(in: targetRect, from: NSMakeRect(0, 0, size.width, size.height), operation: .copy, fraction: 1)
        img.unlockFocus()
        
        cgCtx?.setLineWidth(0.5)
        cgCtx?.setStrokeColor(CGColor.black)
        
        let borderPath = CGMutablePath()
        borderPath.addRoundedRect(in: targetRect.insetBy(dx: 0.2, dy: 0.2), cornerWidth: borderRadius, cornerHeight: borderRadius)
        
        cgCtx?.addPath(borderPath)
        cgCtx?.drawPath(using: .stroke)

        return img
    }
}
