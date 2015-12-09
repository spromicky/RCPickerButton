//
//  RCPickerButton.swift
//  RCPickerButton
//
//  Created by Nick on 2/12/15.
//  Copyright © 2015 spromicky. All rights reserved.
//

import Foundation
import UIKit

private let RCPickerButtonTouchAnimationDuration = 0.15
private let RCPickerButtonSelectionAnimationDuration = 0.15

@IBDesignable
public class RCPickerButton: UIControl {
    private let backgroundView     = UIImageView()
    private let checkmarkImageView = UIImageView()
    private let checkmarkLayer     = CAShapeLayer()
    private let darkOverlayLayer   = CALayer()
    
    private var checkmarkPathPoints: [CGPoint] {
        get {
            return [CGPoint(x: 0.66 * bounds.width, y: 0.4 * bounds.height),
                    CGPoint(x: 0.44 * bounds.width, y: 0.59 * bounds.height),
                    CGPoint(x: 0.34 * bounds.width, y: 0.5 * bounds.height)]
        }
    }
    
    //MARK: - IBInspectable
    @IBInspectable public var checkmarkEnable: Bool = true {
        didSet {
            setNeedsLayout()
        }
    }
    @IBInspectable public var alwaysShowBorder: Bool = false {
        didSet {
            setNeedsLayout()
        }
    }
    
    @IBInspectable public var borderWidth: CGFloat = 1
    @IBInspectable public var borderContentOffset: CGFloat = 2
    @IBInspectable public var borderColor: UIColor = UIColor.whiteColor() {
        didSet {
            setNeedsLayout()
        }
    }
    @IBInspectable public var borderColorSelected: UIColor = UIColor.whiteColor() {
        didSet {
            setNeedsLayout()
        }
    }
    
    @IBInspectable public var checkmarkColor: UIColor = UIColor(white: 50 / 255, alpha: 1) {
        didSet {
            checkmarkLayer.strokeColor = checkmarkColor.CGColor
            setNeedsLayout()
        }
    }
    @IBInspectable public var checkmarkImage: UIImage? {
        didSet {
            checkmarkImageView.image = checkmarkImage
            setNeedsLayout()
        }
    }
    @IBInspectable public var checkmarkWidth: CGFloat = 1 {
        didSet {
            checkmarkLayer.lineWidth = checkmarkWidth
            setNeedsLayout()
        }
    }
    @IBInspectable public var image: UIImage? {
        didSet {
            backgroundView.image = image
            setNeedsLayout()
        }
    }
    @IBInspectable public var color: UIColor = UIColor.whiteColor() {
        didSet {
            backgroundView.backgroundColor = color
            setNeedsLayout()
        }
    }
    
    //MARK: - Override
    override public var frame: CGRect {
        didSet {
            let size = frame.size
            guard size.width != size.height else { return }
            
            let minValue = min(size.width, size.height)
            frame = CGRect(x: frame.origin.x + (size.width - minValue) / 2, y: frame.origin.y + (size.height - minValue) / 2, width: minValue, height: minValue)
        }
    }
    
    override public var contentMode: UIViewContentMode {
        didSet {
            backgroundView.contentMode = contentMode
            setNeedsLayout()
        }
    }
    
    override public var selected: Bool {
        didSet {
            selectionAnimation(selected)
        }
    }
    
    
    //MARK: - Inits
    override public init(frame: CGRect) {
        super.init(frame: frame)
        configureLayers()
    }
    
    convenience public init() {
        self.init(frame: CGRect(x: 0, y: 0, width: 44, height: 44))
    }
    
    convenience public init (image: UIImage) {
        self.init()
        backgroundView.image = image
    }
    
    convenience public init (color aColor: UIColor) {
        self.init()
        backgroundView.backgroundColor = aColor
    }
    
    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        configureLayers()
    }
    
    internal func configureLayers() {
        clipsToBounds = true
        
        backgroundView.backgroundColor  = color
        backgroundView.frame            = bounds
        backgroundView.contentMode      = contentMode
        backgroundView.autoresizingMask = [.FlexibleBottomMargin, .FlexibleHeight, .FlexibleLeftMargin, .FlexibleRightMargin, .FlexibleTopMargin, .FlexibleWidth]
        backgroundView.clipsToBounds = true
        addSubview(backgroundView)
        
        checkmarkImageView.frame = bounds
        checkmarkImageView.contentMode = .Center
        checkmarkImageView.autoresizingMask = [.FlexibleBottomMargin, .FlexibleHeight, .FlexibleLeftMargin, .FlexibleRightMargin, .FlexibleTopMargin, .FlexibleWidth]
        checkmarkImageView.clipsToBounds = true
        checkmarkImageView.layer.opacity = 0
        
        addSubview(checkmarkImageView)
        layer.addSublayer(checkmarkLayer)
        
        darkOverlayLayer.backgroundColor = UIColor(white: 0, alpha: 0.2).CGColor
        darkOverlayLayer.opacity = 0
        layer.addSublayer(darkOverlayLayer)
        
        if checkmarkImage == nil {
            checkmarkLayer.fillColor = UIColor.clearColor().CGColor
            checkmarkLayer.strokeColor = checkmarkColor.CGColor
            checkmarkLayer.allowsEdgeAntialiasing = true
            checkmarkLayer.strokeEnd = 0
            checkmarkLayer.lineWidth = checkmarkWidth
            
            layer.addSublayer(checkmarkLayer)
        }
    }
    
    //MARK: -
    override public func layoutSubviews() {
        super.layoutSubviews()
        
        layer.cornerRadius = frame.size.height / 2
        checkmarkImageView.layer.cornerRadius = layer.cornerRadius
        backgroundView.layer.cornerRadius = backgroundView.frame.size.height / 2
        
        if checkmarkEnable && checkmarkImage == nil {
            checkmarkLayer.path = checkmarkPath(selected ? checkmarkPathPoints.reverse() : checkmarkPathPoints)
        }
        
        if alwaysShowBorder {
            layer.borderWidth = borderWidth
            
            let offset = borderWidth + borderContentOffset
            backgroundView.layer.frame = CGRect(x: offset, y: offset, width: frame.size.width - 2 * offset, height: frame.size.height - 2 * offset)
            
            layer.borderColor = selected ? borderColorSelected.CGColor : borderColor.CGColor
        }
        
        darkOverlayLayer.frame = bounds
        darkOverlayLayer.removeFromSuperlayer()
        layer.addSublayer(darkOverlayLayer)
    }
    
    private func checkmarkPath(points: [CGPoint]) -> CGMutablePathRef {
        return points.reduce(CGPathCreateMutable()) { (path, point) -> CGMutablePathRef in
            guard !CGPathIsEmpty(path) else { CGPathMoveToPoint(path, nil, point.x, point.y); return path }
            
            CGPathAddLineToPoint(path, nil, point.x, point.y)
            return path
        }
    }
    
    //MARK: - Touches
    override public func beginTrackingWithTouch(touch: UITouch, withEvent event: UIEvent?) -> Bool {
        touchAnimation(false)
        return true
    }
    
    override public func endTrackingWithTouch(touch: UITouch?, withEvent event: UIEvent?) {
        touchAnimation(true)

        if touchInside { selected = !selected }
    }
    
    //MARK: - Animations
    private func touchAnimation(reverse: Bool) {
        let oldScale = layer.transform.m11
        layer.transform = reverse ? CATransform3DIdentity : CATransform3DMakeScale(0.95, 0.95, 1)
        
        let scaleAnimation = CABasicAnimation(keyPath: "transform.scale")
        scaleAnimation.fromValue = oldScale
        scaleAnimation.duration = RCPickerButtonTouchAnimationDuration
        layer.addAnimation(scaleAnimation, forKey: "transform.scale")
        
        let oldOpacity = darkOverlayLayer.opacity
        darkOverlayLayer.opacity = reverse ? 0 : 1
        
        let opacityAnimation = CABasicAnimation(keyPath: "opacity")
        opacityAnimation.fromValue = oldOpacity
        scaleAnimation.duration = RCPickerButtonTouchAnimationDuration
        darkOverlayLayer.addAnimation(opacityAnimation, forKey: "opacity")
    }
    
    private func selectionAnimation(selected: Bool) {
        if !alwaysShowBorder {
            layer.borderColor = borderColorSelected.CGColor
            
            let oldBorderWidth = layer.borderWidth
            layer.borderWidth = selected ? borderWidth : 0
            
            let borderAnimation = CABasicAnimation(keyPath: "borderWidth")
            borderAnimation.fromValue = oldBorderWidth
            borderAnimation.duration = RCPickerButtonSelectionAnimationDuration
            layer.addAnimation(borderAnimation, forKey: "borderWidth")
            
            let offset = borderWidth + borderContentOffset
            let oldFrame = backgroundView.layer.frame
            
            backgroundView.layer.frame = selected ? CGRect(x: offset, y: offset, width: frame.size.width - 2 * offset, height: frame.size.height - 2 * offset) : bounds
            
            let frameAnimation = CABasicAnimation(keyPath: "frame")
            frameAnimation.fromValue = NSValue(CGRect:oldFrame)
            frameAnimation.duration = RCPickerButtonSelectionAnimationDuration
            backgroundView.layer.addAnimation(frameAnimation, forKey: "frame")
        } else {
            layer.borderColor = selected ? borderColorSelected.CGColor : borderColor.CGColor
        }
        
        if checkmarkEnable {
            checkmarkLayer.path = checkmarkPath(selected ? checkmarkPathPoints.reverse() : checkmarkPathPoints)
            
            if let _ = checkmarkImage {
                let oldOpacity = checkmarkImageView.layer.opacity
                checkmarkImageView.layer.opacity = selected ? 1 : 0
                
                let checkmarkAnimation = CABasicAnimation(keyPath: "opacity")
                checkmarkAnimation.fromValue = oldOpacity
                checkmarkAnimation.duration = RCPickerButtonSelectionAnimationDuration
                checkmarkImageView.layer.addAnimation(checkmarkAnimation, forKey: "opacity")
            } else {
                let oldProgress = checkmarkLayer.strokeEnd
                checkmarkLayer.strokeEnd = CGFloat(selected)
                
                let checkmarkAnimation = CABasicAnimation(keyPath: "strokeEnd")
                checkmarkAnimation.fromValue = oldProgress
                checkmarkAnimation.duration = RCPickerButtonSelectionAnimationDuration
                checkmarkLayer.addAnimation(checkmarkAnimation, forKey: "strokeEnd")
            }
        }        
    }
}