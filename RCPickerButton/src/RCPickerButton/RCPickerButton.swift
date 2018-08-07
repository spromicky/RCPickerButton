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

/// Simple button for marking some items as selected.
@IBDesignable
open class RCPickerButton: UIControl {
    private let backgroundView     = UIImageView()
    private let checkmarkImageView = UIImageView()
    private let checkmarkLayer     = CAShapeLayer()
    private let darkOverlayLayer   = CALayer()
    
    private var checkmarkPathPoints: [CGPoint] {
        return [CGPoint(x: 0.66 * bounds.width, y: 0.4 * bounds.height),
                CGPoint(x: 0.44 * bounds.width, y: 0.59 * bounds.height),
                CGPoint(x: 0.34 * bounds.width, y: 0.5 * bounds.height)]
    }
    
    //MARK: - IBInspectable
    
    /// If `false` never set to `selected` state by user iteraction.
    @IBInspectable open var autoToggle: Bool = true
    /// If `true` show checkmark image (in priority) or draw default, when selected.
    @IBInspectable open var checkmarkEnable: Bool = true {
        didSet {
            setNeedsLayout()
        }
    }
    
    /// If `true` always show border even if `selected` is `false`.
    @IBInspectable open var alwaysShowBorder: Bool = false {
        didSet {
            setNeedsLayout()
        }
    }
    
    
    /// Width of the selected state border.
    @IBInspectable open var borderWidth: CGFloat = 1
    /// Offset between border and button content.
    @IBInspectable open var borderContentOffset: CGFloat = 2
    /// Color of the border in default state.
    @IBInspectable open var borderColor: UIColor = UIColor.white {
        didSet {
            setNeedsLayout()
        }
    }
    /// Color of the border in selected state.
    @IBInspectable open var borderColorSelected: UIColor = UIColor.white {
        didSet {
            setNeedsLayout()
        }
    }
    
    
    /// Color of the drawed checkmark for selected state.
    @IBInspectable open var checkmarkColor: UIColor = UIColor(white: 50 / 255, alpha: 1) {
        didSet {
            checkmarkLayer.strokeColor = checkmarkColor.cgColor
            setNeedsLayout()
        }
    }
    /// Width of the drawed checkmark in selected state.
    @IBInspectable open var checkmarkWidth: CGFloat = 1 {
        didSet {
            checkmarkLayer.lineWidth = checkmarkWidth
            setNeedsLayout()
        }
    }
    /// Image used for display selected state.
    @IBInspectable open var checkmarkImage: UIImage? {
        didSet {
            checkmarkImageView.image = checkmarkImage
            setNeedsLayout()
        }
    }
    /// Image that used as content of the button. Just for example avatar.
    @IBInspectable open var image: UIImage? {
        didSet {
            backgroundView.image = image
            setNeedsLayout()
        }
    }
    /// Color taht used as content of the button. Useful if button used for color select.
    @IBInspectable open var color: UIColor = UIColor.white {
        didSet {
            backgroundView.backgroundColor = color
            setNeedsLayout()
        }
    }
    
    //MARK: - Override
    override open var frame: CGRect {
        didSet {
            let size = frame.size
            guard size.width != size.height else { return }
            
            let minValue = min(size.width, size.height)
            frame = CGRect(x: frame.origin.x + (size.width - minValue) / 2, y: frame.origin.y + (size.height - minValue) / 2, width: minValue, height: minValue)
        }
    }
    
    override open var contentMode: UIViewContentMode {
        didSet {
            backgroundView.contentMode = contentMode
            setNeedsLayout()
        }
    }
    
    override open var isSelected: Bool {
        didSet {
            animate(selected: isSelected)
        }
    }
    
    
    //MARK: - Inits
    override public init(frame: CGRect) {
        super.init(frame: frame)
        configureLayers()
    }
    
    /**
     Create a default RCPickerButton.
     
     - returns: Default instance of the RCPickerButton.
     */
    convenience public init() {
        self.init(frame: CGRect(x: 0, y: 0, width: 44, height: 44))
    }
    
    /**
     Create a button with the `image` as content.
     
     - parameter image: Image that will be used as content for button.
     
     - returns: Instance of the RCPickerButton with `image` as content.
     */
    convenience public init (image: UIImage) {
        self.init()
        backgroundView.image = image
    }
    
    /**
     Create a button with the `color` as content.
     
     - parameter color: Color that will be used as content for button.
     
     - returns: Instance of the RCPickerButton with `color` as content.
     */
    convenience public init (color: UIColor) {
        self.init()
        backgroundView.backgroundColor = color
    }
    
    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        configureLayers()
    }
    
    private func configureLayers() {
        clipsToBounds = true
        
        backgroundView.backgroundColor  = color
        backgroundView.frame            = bounds
        backgroundView.contentMode      = contentMode
        backgroundView.autoresizingMask = [.flexibleBottomMargin, .flexibleHeight, .flexibleLeftMargin, .flexibleRightMargin, .flexibleTopMargin, .flexibleWidth]
        backgroundView.clipsToBounds = true
        addSubview(backgroundView)
        
        checkmarkImageView.frame = bounds
        checkmarkImageView.contentMode = .center
        checkmarkImageView.autoresizingMask = [.flexibleBottomMargin, .flexibleHeight, .flexibleLeftMargin, .flexibleRightMargin, .flexibleTopMargin, .flexibleWidth]
        checkmarkImageView.clipsToBounds = true
        checkmarkImageView.layer.opacity = 0
        
        addSubview(checkmarkImageView)
        layer.addSublayer(checkmarkLayer)
        
        darkOverlayLayer.backgroundColor = UIColor(white: 0, alpha: 0.2).cgColor
        darkOverlayLayer.opacity = 0
        layer.addSublayer(darkOverlayLayer)
        
        if checkmarkImage == nil {
            checkmarkLayer.fillColor = UIColor.clear.cgColor
            checkmarkLayer.strokeColor = checkmarkColor.cgColor
            checkmarkLayer.allowsEdgeAntialiasing = true
            checkmarkLayer.strokeEnd = 0
            checkmarkLayer.lineWidth = checkmarkWidth
            
            layer.addSublayer(checkmarkLayer)
        }
    }
    
    //MARK: -
    override open func layoutSubviews() {
        super.layoutSubviews()
        
        layer.cornerRadius = frame.size.height / 2
        checkmarkImageView.layer.cornerRadius = layer.cornerRadius
        backgroundView.layer.cornerRadius = backgroundView.frame.size.height / 2
        
        if checkmarkEnable && checkmarkImage == nil {
            checkmarkLayer.path = checkmarkPath(isSelected ? checkmarkPathPoints.reversed() : checkmarkPathPoints)
        }
        
        if alwaysShowBorder {
            layer.borderWidth = borderWidth
            
            let offset = borderWidth + borderContentOffset
            backgroundView.layer.frame = CGRect(x: offset, y: offset, width: frame.size.width - 2 * offset, height: frame.size.height - 2 * offset)
            
            layer.borderColor = isSelected ? borderColorSelected.cgColor : borderColor.cgColor
        }
        
        darkOverlayLayer.frame = bounds
        darkOverlayLayer.removeFromSuperlayer()
        layer.addSublayer(darkOverlayLayer)
    }
    
    private func checkmarkPath(_ points: [CGPoint]) -> CGMutablePath {
        return points.reduce(CGMutablePath()) { (path, point) -> CGMutablePath in
            guard !path.isEmpty else { path.move(to: point); return path }
            
            path.addLine(to: point)
            return path
        }
    }
    
    //MARK: - Touches
    override open func beginTracking(_ touch: UITouch, with event: UIEvent?) -> Bool {
        touchAnimation(false)
        return true
    }
    
    override open func endTracking(_ touch: UITouch?, with event: UIEvent?) {
        touchAnimation(true)

        if autoToggle && isTouchInside { isSelected = !isSelected }
    }
    
    //MARK: - Animations
    private func touchAnimation(_ reverse: Bool) {
        let oldScale = layer.transform.m11
        layer.transform = reverse ? CATransform3DIdentity : CATransform3DMakeScale(0.95, 0.95, 1)
        
        let scaleAnimation = CABasicAnimation(keyPath: "transform.scale")
        scaleAnimation.fromValue = oldScale
        scaleAnimation.duration = RCPickerButtonTouchAnimationDuration
        layer.add(scaleAnimation, forKey: "transform.scale")
        
        let oldOpacity = darkOverlayLayer.opacity
        darkOverlayLayer.opacity = reverse ? 0 : 1
        
        let opacityAnimation = CABasicAnimation(keyPath: "opacity")
        opacityAnimation.fromValue = oldOpacity
        scaleAnimation.duration = RCPickerButtonTouchAnimationDuration
        darkOverlayLayer.add(opacityAnimation, forKey: "opacity")
    }
    
    private func animate(selected: Bool) {
        if !alwaysShowBorder {
            layer.borderColor = borderColorSelected.cgColor
            
            let oldBorderWidth = layer.borderWidth
            layer.borderWidth = selected ? borderWidth : 0
            
            let borderAnimation = CABasicAnimation(keyPath: "borderWidth")
            borderAnimation.fromValue = oldBorderWidth
            borderAnimation.duration = RCPickerButtonSelectionAnimationDuration
            layer.add(borderAnimation, forKey: "borderWidth")
            
            let offset = borderWidth + borderContentOffset
            let oldFrame = backgroundView.layer.frame
            
            backgroundView.layer.frame = selected ? CGRect(x: offset, y: offset, width: frame.size.width - 2 * offset, height: frame.size.height - 2 * offset) : bounds
            
            let frameAnimation = CABasicAnimation(keyPath: "frame")
            frameAnimation.fromValue = NSValue(cgRect:oldFrame)
            frameAnimation.duration = RCPickerButtonSelectionAnimationDuration
            backgroundView.layer.add(frameAnimation, forKey: "frame")
        } else {
            layer.borderColor = selected ? borderColorSelected.cgColor : borderColor.cgColor
        }
        
        if checkmarkEnable {
            checkmarkLayer.path = checkmarkPath(selected ? checkmarkPathPoints.reversed() : checkmarkPathPoints)
            
            if let _ = checkmarkImage {
                let oldOpacity = checkmarkImageView.layer.opacity
                checkmarkImageView.layer.opacity = selected ? 1 : 0
                
                let checkmarkAnimation = CABasicAnimation(keyPath: "opacity")
                checkmarkAnimation.fromValue = oldOpacity
                checkmarkAnimation.duration = RCPickerButtonSelectionAnimationDuration
                checkmarkImageView.layer.add(checkmarkAnimation, forKey: "opacity")
            } else {
                let oldProgress = checkmarkLayer.strokeEnd
                checkmarkLayer.strokeEnd = selected ? 1 : 0
                
                let checkmarkAnimation = CABasicAnimation(keyPath: "strokeEnd")
                checkmarkAnimation.fromValue = oldProgress
                checkmarkAnimation.duration = RCPickerButtonSelectionAnimationDuration
                checkmarkLayer.add(checkmarkAnimation, forKey: "strokeEnd")
            }
        }        
    }
}
