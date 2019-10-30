//
//  PhotoContentView+Crop.swift
//  AnyImageEditor
//
//  Created by 蒋惠 on 2019/10/29.
//  Copyright © 2019 AnyImageProject.org. All rights reserved.
//

import UIKit

// MARK: - Public function
extension PhotoContentView {

    func cropStart() {
        isCrop = true
        UIView.animate(withDuration: 0.25, animations: {
            self.layoutCrop()
        }) { (_) in
            self.setCropHidden(false, animated: true)
        }
    }
    
    func cropCancel() {
        isCrop = false
        setCropHidden(true, animated: false)
        UIView.animate(withDuration: 0.25) {
            self.layout()
        }
    }
    
    func cropDone() {
        isCrop = false
    }
    
    func cropReset() {
        
    }
}

// MARK: - Target
extension PhotoContentView {
    
    @objc func panCropCorner(_ gr: UIPanGestureRecognizer) {
        guard let cornerView = gr.view as? CropCornerView else { return }
        let moveP = gr.translation(in: self)
        gr.setTranslation(.zero, in: self)
        
        let limit: CGFloat = 55
        var rect = cropRect
        switch cornerView.position {
        case .topLeft: // x+ y+
            if rect.size.width - moveP.x > limit && rect.origin.x + moveP.x > scrollView.frame.origin.x {
                rect.origin.x += moveP.x
                rect.size.width -= moveP.x
            }
            if rect.size.height - moveP.y > limit && rect.origin.y + moveP.y > imageView.frame.origin.y {
                rect.origin.y += moveP.y
                rect.size.height -= moveP.y
            }
        case .topRight: // x- y+
            if rect.size.width + moveP.x > limit && rect.size.width + moveP.x < imageView.frame.size.width {
                rect.size.width += moveP.x
            }
            if rect.size.height - moveP.y > limit && rect.origin.y + moveP.y > imageView.frame.origin.y {
                rect.origin.y += moveP.y
                rect.size.height -= moveP.y
            }
        case .bottomLeft: // x+ y-
            if rect.size.width - moveP.x > limit && rect.origin.x + moveP.x > scrollView.frame.origin.x {
                rect.origin.x += moveP.x
                rect.size.width -= moveP.x
            }
            if rect.size.height + moveP.y > limit && rect.size.height + moveP.y < imageView.frame.size.height {
                rect.size.height += moveP.y
            }
        case .bottomRight:// x- y-
            if rect.size.width + moveP.x > limit && rect.size.width + moveP.x < imageView.frame.size.width {
                rect.size.width += moveP.x
            }
            if rect.size.height + moveP.y > limit && rect.size.height + moveP.y < imageView.frame.size.height {
                rect.size.height += moveP.y
            }
        }
        setCropRect(rect)
        
        if gr.state == .ended {
            let tmp = cropRect
            // zoom
            let zoom = imageView.bounds.width / (cropRect.width / scrollView.zoomScale)
            UIView.animate(withDuration: 0.25) {
                let offsetX = self.scrollView.contentOffset.x
                self.scrollView.zoomScale = zoom
                let x = (((self.cropRect.origin.x - 15) / zoom + (offsetX / zoom)) / self.imageView.bounds.width) * self.scrollView.contentSize.width
                // TODO: 计算xy
                self.scrollView.contentOffset = CGPoint(x: 0, y: 0)
            }
            
            // reset
            let scale = scrollView.bounds.width / cropRect.width
            let height = cropRect.height * scale
            let y = (scrollView.bounds.height - height) / 2
            UIView.animate(withDuration: 0.25) {
                self.imageView.frame.origin.y = y
                self.setCropRect(CGRect(x: 15, y: y, width: self.scrollView.bounds.width, height: height))
            }
            
            let bottomInset = bounds.height - cropRect.size.height + 1
            scrollView.contentInset = UIEdgeInsets(top: 0.1, left: 0.1, bottom: bottomInset, right: 0.1)
        }
    }
    
}

// MARK: - Private function
extension PhotoContentView {
    
    internal func cropSetupView() {
//        layer.addSublayer(gridLayer)
        addSubview(topLeftCorner)
        addSubview(topRightCorner)
        addSubview(bottomLeftCorner)
        addSubview(bottomRightCorner)
    }
    
    private func layoutCrop() {
        scrollView.frame = CGRect(x: 15, y: 0, width: bounds.width-30, height: bounds.height)
        scrollView.maximumZoomScale = 15.0
        scrollView.minimumZoomScale = 1.0
        scrollView.zoomScale = 1.0
        
        var cropFrame = cropFrame2
        imageView.frame = cropFrame
        scrollView.contentSize = imageView.bounds.size
        
        cropFrame.origin.x += 15
        setCropRect(cropFrame)
        
        let bottomInset = bounds.height - cropRect.size.height + 1
        scrollView.contentInset = UIEdgeInsets(top: 0.1, left: 0.1, bottom: bottomInset, right: 0.1)
    }
    
    private func setCropRect(_ rect: CGRect) {
        cropRect = rect
        let origin = rect.origin
        let size = rect.size
        topLeftCorner.center = origin
        topRightCorner.center = CGPoint(x: origin.x + size.width, y: origin.y)
        bottomLeftCorner.center = CGPoint(x: origin.x, y: origin.y + size.height)
        bottomRightCorner.center = CGPoint(x: origin.x + size.width, y: origin.y + size.height)
//        gridLayer.frame = rect
//        gridLayer.reload(rect)
    }
    
    private func setCropHidden(_ hidden: Bool, animated: Bool) {
        UIView.animate(withDuration: animated ? 0.25 : 0) {
            self.topLeftCorner.alpha = hidden ? 0 : 1
            self.topRightCorner.alpha = hidden ? 0 : 1
            self.bottomLeftCorner.alpha = hidden ? 0 : 1
            self.bottomRightCorner.alpha = hidden ? 0 : 1
            self.gridLayer.isHidden = hidden
        }
    }
    
    
}
