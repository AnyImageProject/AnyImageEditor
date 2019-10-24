//
//  TestView.swift
//  AnyImageEditor
//
//  Created by 蒋惠 on 2019/10/23.
//  Copyright © 2019 AnyImageProject.org. All rights reserved.
//

import UIKit

protocol CanvasDelegate: class {
    
    func canvasDidBeginPen()
    func canvasDidEndPen()
}

protocol CanvasDataSource: class {
    
    func canvasGetScale(_ canvas: Canvas) -> CGFloat
}

class Canvas: UIView {

    weak var delegate: CanvasDelegate?
    weak var dataSource: CanvasDataSource?
    
    var brush = Brush()
    
    let data = CanvasData()
    let bezierGenerator = BezierGenerator()
    var lastPoint: CGPoint = .zero
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let touch = touches.first else { return }
        let point = touch.preciseLocation(in: self)
        bezierGenerator.begin(with: point)
        pushPoint(point, to: bezierGenerator, state: .begin)
    }
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard bezierGenerator.points.count > 0 else { return }
        guard let touch = touches.first else { return }
        let point = touch.preciseLocation(in: self)
        if lastPoint == point { return }
        lastPoint = point
        pushPoint(point, to: bezierGenerator, state: .move)
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        defer {
            bezierGenerator.finish()
            lastPoint = .zero
        }
        
        guard bezierGenerator.points.count > 0 else { return }
        guard let touch = touches.first else { return }
        let point = touch.preciseLocation(in: self)
        pushPoint(point, to: bezierGenerator, state: .end)
    }
}

// MARK: - Public function
extension Canvas {
    
    func canUndo() -> Bool {
        data.canUndo()
    }
    
    func undo() {
        data.undo()
    }
}

extension Canvas {
    
    private func pushPoint(_ point: CGPoint, to bezier: BezierGenerator, state: TouchState) {
        if state == .begin {
            data.currentElement = CanvasDataElement()
            data.elements.append(data.currentElement)
        }
        defer {
            if state == .end && data.currentElement.layerList.count > 3 {
                delegate?.canvasDidEndPen()
            }
        }
        
        let points = bezier.pushPoint(point)
        if points.count < 3 { return }
        delegate?.canvasDidBeginPen()
        
        let scale = dataSource?.canvasGetScale(self) ?? 1.0
        let shapeLayer = data.layer(of: points, brush: brush, scale: scale)
        data.currentElement.layerList.append(shapeLayer)
        self.layer.addSublayer(shapeLayer)
    }
    
}

extension Canvas {
    
    enum TouchState {
        case begin
        case move
        case end
    }
    
}