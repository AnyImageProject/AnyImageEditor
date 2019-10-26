//
//  _PhotoEditorController.swift
//  AnyImageEditor
//
//  Created by 蒋惠 on 2019/10/23.
//  Copyright © 2019 AnyImageProject.org. All rights reserved.
//

import UIKit

final class PhotoEditorController: UIViewController {
    
    private lazy var canvasView: CanvasContentView = {
        let view = CanvasContentView(frame: self.view.bounds, image: manager.image, config: manager.config)
        view.delegate = self
        view.canvas.brush.color = manager.config.penColors[manager.config.defaultPenIdx]
        return view
    }()
    private lazy var toolView: PhotoToolView = {
        let view = PhotoToolView(frame: self.view.bounds, config: PhotoManager.shared.config)
        view.delegate = self
        return view
    }()
    private lazy var backButton: UIButton = {
        let view = UIButton(type: .custom)
        view.setImage(BundleHelper.image(named: "ReturnBackButton"), for: .normal)
        view.addTarget(self, action: #selector(backButtonTapped(_:)), for: .touchUpInside)
        return view
    }()
    private lazy var singleTap: UITapGestureRecognizer = {
        return UITapGestureRecognizer(target: self, action: #selector(onSingleTap(_:)))
    }()
    
    private let manager = PhotoManager.shared
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupView()
        navigationController?.navigationBar.isHidden = true
    }
    
    private func setupView() {
        view.addSubview(canvasView)
        view.addSubview(toolView)
        view.addSubview(backButton)
        view.addGestureRecognizer(singleTap)
        
        backButton.snp.makeConstraints { (maker) in
            if #available(iOS 11.0, *) {
                maker.top.equalTo(view.safeAreaLayoutGuide).offset(20)
            } else {
                maker.top.equalToSuperview().offset(40)
            }
            maker.left.equalToSuperview().offset(20)
            maker.width.height.equalTo(30)
        }
    }
    
    override var prefersStatusBarHidden: Bool {
        return true
    }
}

// MARK: - Target
extension PhotoEditorController {
    
    @objc private func backButtonTapped(_ sender: UIButton) {
        dismiss(animated: true, completion: nil)
    }
    
    @objc private func onSingleTap(_ tap: UITapGestureRecognizer) {
        let point = tap.location(in: toolView)
        toolView.responseTouch(point)
    }
}

// MARK: - CanvasContentViewDelegate
extension PhotoEditorController: CanvasContentViewDelegate {
    
    func canvasDidBeginPen() {
        UIView.animate(withDuration: 0.25) {
            self.toolView.alpha = 0
            self.backButton.alpha = 0
        }
    }
    
    func canvasDidEndPen() {
        toolView.penToolView.undoButton.isEnabled = true
        UIView.animate(withDuration: 0.25) {
            self.toolView.alpha = 1
            self.backButton.alpha = 1
        }
    }
    
    func mosaicDidCreated() {
        // hide hud
        guard let option = toolView.currentOption else { return }
        if option == .mosaic {
            canvasView.mosaic?.isUserInteractionEnabled = true
        }
    }
}

// MARK: - PhotoToolViewDelegate
extension PhotoEditorController: PhotoToolViewDelegate {
    
    func toolView(_ toolView: PhotoToolView, optionDidChange option: ImageEditorController.PhotoEditOption?) {
        canvasView.canvas.isUserInteractionEnabled = false
        canvasView.mosaic?.isUserInteractionEnabled = false
        canvasView.scrollView.isScrollEnabled = option == nil
        guard let option = option else { return }
        switch option {
        case .pen:
            canvasView.canvas.isUserInteractionEnabled = true
        case .text:
            break
        case .crop:
            break
        case .mosaic:
            if canvasView.mosaic == nil {
                // show hud
            }
            canvasView.mosaic?.isUserInteractionEnabled = true
        }
    }
    
    func toolView(_ toolView: PhotoToolView, colorDidChange idx: Int) {
        canvasView.canvas.brush.color = PhotoManager.shared.config.penColors[idx]
    }
    
    func toolViewUndoButtonTapped(_ toolView: PhotoToolView) {
        canvasView.canvasUndo()
        toolView.penToolView.undoButton.isEnabled = canvasView.canvasCanUndo()
    }
}
